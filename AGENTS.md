# AGENTS.md — Coding Agent Guidelines

Shared guide for coding agents. `CLAUDE.md` is a symlink to this file.

A **Hammerspoon configuration** written in **Fennel** (a Lisp that compiles to Lua), heavily rewritten from [spacehammer](https://github.com/agzam/spacehammer/). Data-oriented and event-driven, organized around the **Sheaf** architecture.

**`DESIGN.md` is the architecture source of truth** — read it before changing how components, commands, behaviors, traits, tags, or subscriptions work. This file is the practical complement: build, layout, and conventions.

## Build

```bash
./compile.sh   # Compile Fennel → Lua. Required after editing any .fnl file.
```

`compile.sh` runs the `deps` tool (via `mise x --`) with `--require-as-include`, which inlines every `require`d Fennel module into a single Lua file. It first compiles `lib/cljlib-shim.fnl → lib/cljlib-shim.lua`, then compiles `core.fnl → init.lua`, skipping the pre-compiled shim.

- **`init.lua` is generated output — never hand-edit it.** Edit `core.fnl` (or a module it requires) and re-run `./compile.sh`.
- Reload after compiling: `Cmd+Ctrl+Q`, or `hs.reload()` in the Hammerspoon console. The `config-watcher` component also watches the config dir — `.fnl` changes trigger a recompile and `init.lua` changes trigger a reload.

**Requirements:** [mise](https://mise.jdx.dev/) for tooling, plus the `deps` tool (from the deps.fnl project). **No test framework** — test manually via the Hammerspoon console. **No linter** — rely on Fennel compiler errors.

### Shell / Tooling Notes

- The interactive shell is `zsh`; if a tool is missing in a non-interactive command, retry with `zsh -ic '<cmd>'` before investigating PATH or mise.
- Prefer project scripts directly (`./compile.sh`). Do not install tools, edit shell startup files, or change mise/env config unless explicitly asked.

## Project Structure

```
core.fnl            # Entry point → compiles to init.lua; defines boot order
init.lua            # COMPILED OUTPUT — DO NOT EDIT
compile.sh          # Build script
deps.fnl            # Fennel dependencies (fennel-cljlib)
DESIGN.md           # Sheaf architecture — source of truth
paper-wm.fnl        # PaperWM tiling port (started directly in core.fnl)
notify.fnl          # On-screen notification helper

sheaf/              # The ENGINE — generic, domain-agnostic
  {event,trait,source,component,command,behavior,subscription,tag}-registry.fnl
  dispatcher.fnl    # Event-time: resolves candidates by tag, runs behaviors
  event-loop.fnl    # Event processing loop

lib/
  hierarchy.fnl     # Clojure-style keyword hierarchies (the *-kind trees)
  cljlib-shim.fnl   # Re-exports cljlib.core (.lua is pre-compiled)

# CONTENT — each dir's init.fnl builds that domain's registry:
events/init.fnl        # Event definitions + event-kind hierarchy
traits/init.fnl        # Trait definitions (state contracts) + trait-kind hierarchy
event_sources/         # Source types (file/window/app/space/screen/hotkey watchers)
components/            # Component types + instance startup + tag attachment
commands/              # Commands (actions on components; declare :requires-traits)
behaviors/             # Behaviors (rules: event + candidates → commands)
subscriptions/init.fnl # Wiring: source-tag + behavior + target-tag + event-selector
```

## Architecture (Sheaf)

See `DESIGN.md` for the concepts (Events, Commands, Components, Traits, Shapes, Behaviors, Tags, Subscriptions). Practical notes for working in the code:

**Two layers.** `sheaf/` is the generic engine (registry factories + dispatcher + event loop). The content dirs define *this* config's behavior on top of it.

**Registration pattern.** A leaf file exports **pure data** built with a `make-*` constructor and has no registry dependency. The dir's `init.fnl` is the **aggregator**: it creates the registry via the matching `sheaf.*-registry` factory (passing in any registries it depends on), registers each leaf, and exports the registry.

**Boot order** (`core.fnl`), each registry feeding the next:

```
events → traits → event_sources → components → commands → behaviors → subscriptions
       → start-dispatcher! → start-event-loop!
```

Starting a component (`start-component!` in `components/init.fnl`) auto-creates its owned event-source instances and attaches its tags — there is no standalone source management.

**Wiring is by tag.** Components are context-blind; subscriptions connect them. A subscription names a `:behavior`, a `:source-tag` (who emits), a `:target-tag` (command candidates), and an `:event-selector`. At event time the dispatcher resolves all target-tagged components as candidates (grouped by command alias, filtered by each command's `:requires-traits`), invokes the behavior `(fn [event candidates send-cmd])`, and captures the state each command returns back onto the target instance. (Behaviors may also declare shaped state `:inputs` — see `DESIGN.md`.)

The `reload-hammerspoon` feature, end to end across the four files:

```fennel
;; components/reload-hammerspoon.fnl — type: lifecycle + declared traits
(make-component-type :component.type/reload-hammerspoon "..."
  {:traits [:trait/has-delayed-timer]
   :start-fn (fn [config] {:timer (hs.timer.delayed.new 0.5 hs.reload) :reloading? false})
   :stop-fn  (fn [state] (state.timer:stop))})

;; commands/reload-hammerspoon.fnl — action run on a component; returns new state
(make-command :reload-hammerspoon.commands/reload "..."
  {:requires-traits [:trait/has-delayed-timer]
   :fn (fn [component params] ... {:timer component.state.timer :reloading? true})})

;; behaviors/reload-hammerspoon.fnl — rule: event → command on a candidate
(make-behavior
  {:name :reload-hammerspoon.behaviors/reload-hammerspoon
   :respond-to [:event.kind.fs/file-change]
   :commands {:reload :reload-hammerspoon.commands/reload}
   :fn (fn [event candidates send-cmd]
         (let [target (. candidates.reload 1)]
           (when (and target ...) (send-cmd target :reload {}))))})

;; subscriptions/init.fnl — tag wiring (the only place the roles meet)
(define-subscription! subscription-registry :sub/reload-on-config-change
  {:behavior :reload-hammerspoon.behaviors/reload-hammerspoon
   :source-tag :tag/config-watcher
   :target-tag :tag/reload-hammerspoon
   :event-selector :event.kind.fs/file-change})
```

**Hierarchies.** Event kinds, trait kinds, and component kinds are keyword hierarchies built with `lib/hierarchy.fnl` (`derive!`), enabling hierarchical selectors — a selector on `:event.kind.window/any` matches `:event.kind.window/focused`, etc.

## Code Style Guidelines

### Imports

Always use destructuring imports at the top of the file:

```fennel
;; Destructuring imports (preferred)
(local {: some : seq : hash-set} (require :lib.cljlib-shim))
(local {: define-event!} (require :sheaf.event-registry))

;; Plain require for single-export modules
(local notify (require :notify))
```

### Naming Conventions

| Type | Convention | Examples |
|------|------------|----------|
| Functions | `kebab-case` | `define-behavior`, `dispatch-event!` |
| Predicates | End with `?` | `event-defined?`, `empty?`, `isa?` |
| Mutating functions | End with `!` | `derive!`, `add-trait!`, `dispatch-event!` |
| Keywords | `:kebab-case` | `:window-move`, `:file-change` |
| Namespaced keywords | `:namespace/name` | `:event.kind.fs/file-change`, `:tag/window-border` |
| Optional parameters | Prefix with `?` | `?init-pairs`, `?config` |
| Registries | `*-registry` | `event-registry`, `behavior-registry` |

### Module Pattern

```fennel
;; Imports at top
(local {: func1 : func2} (require :some-module))

;; Private state
(local internal-register {})
(var mutable-state false)

;; Private helpers, then public functions, each with a docstring
(fn public-function [args]
  "Docstring describing the function."
  ...)

;; Export public API (or pure data) as a table at end of file
{: public-function}
```

### Comments and Formatting

```fennel
;; Single-line comments use double semicolon

;; ============================================================================
;; Section headers use separator lines
;; ============================================================================

;; Use (comment ...) for example data structures
(comment example-event
  {:timestamp 0 :event-name :window-move :event-data {:x 10 :y 20}})
```

### Error Handling

```fennel
;; Critical errors — use (error ...) to halt execution
(when (= child parent)
  (error "Cannot derive a keyword from itself"))

;; Non-fatal warnings — use (print "[WARN] ...")
(when (= nil (. events-register event-name))
  (print (.. "[WARN] event '" (tostring event-name) "' not defined")))

;; Guard clauses with (when ...) for nil checks
(when child-entry
  (tset child-entry :parents (disj (. child-entry :parents) parent)))
```

### Cljlib Utilities (Clojure-style)

```fennel
(hash-set)              ; Create empty set
(conj set item)         ; Add item to set (returns new set)
(disj set item)         ; Remove item from set
(contains? set x)       ; Check membership
(into coll items)       ; Add all items to collection
(mapv f coll)           ; Map returning vector
(filter pred coll)      ; Filter collection
(some pred coll)        ; Find first truthy result
(seq coll)              ; Convert to sequence (nil if empty)
(empty? coll)           ; Check if empty
(assoc tbl k v)         ; Associate key-value in table
(string? x)             ; Type predicate
```

## Hammerspoon APIs

Common APIs used in this codebase:

- `hs.configdir` — config directory path (use this, not a hardcoded `~/.hammerspoon`)
- `hs.timer.secondsSinceEpoch` / `hs.timer.delayed` — timestamps / debounced timers
- `hs.inspect` — pretty-print tables for debugging
- `hs.reload()` — reload Hammerspoon config
- `hs.alert` / `hs.notify` — on-screen alerts / system notifications
- `hs.pathwatcher` — file system watcher
- `hs.window.filter` — window event subscriptions
- `hs.execute` — run shell commands

See the [Hammerspoon API docs](https://www.hammerspoon.org/docs/) for the full reference.
