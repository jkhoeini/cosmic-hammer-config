# AGENTS.md - Coding Agent Guidelines

A **Hammerspoon configuration** using **Fennel** (Lisp that compiles to Lua). Data-oriented, event-driven architecture inspired by Clojure.

## Build Commands

```bash
# Compile all Fennel to Lua (required after any .fnl file changes)
./compile.sh

# What it does:
# 1. Compiles lib/cljlib-shim.fnl -> lib/cljlib-shim.lua
# 2. Compiles core.fnl -> init.lua (main entry point)

# Reload Hammerspoon after compilation: Cmd+Ctrl+Q or hs.reload() in console
```

**Requirements:** [mise](https://mise.jdx.dev/) for tool management, `deps` tool (from deps.fnl project)

### Shell / Tooling Notes

- The user's interactive shell is `zsh`; if a tool is missing in a non-interactive command, retry with `zsh -ic '<cmd>'` before investigating PATH or mise.
- Prefer project scripts directly, especially `./compile.sh`. Do not install tools, edit shell startup files, or change mise/env config unless the user explicitly asks.

**No test framework.** Testing done manually via Hammerspoon console.
**No linter.** Use Fennel compiler errors for feedback.

## Project Structure

```
.hammerspoon/
├── core.fnl              # Entry point -> compiles to init.lua
├── init.lua              # COMPILED OUTPUT - DO NOT EDIT
├── compile.sh            # Build script
├── deps.fnl              # Fennel dependencies (fennel-cljlib)
├── config.fnl            # App keybindings and menus
├── lib/                  # Core library modules
│   ├── cljlib-shim.fnl   # Re-exports cljlib.core
│   ├── hierarchy.fnl     # Clojure-style keyword hierarchies
│   ├── event-registry.fnl    # Event definitions and dispatch
│   ├── behavior-registry.fnl # Behavior definitions
│   ├── subscription-registry.fnl  # Connects behaviors to events
│   ├── source-registry.fnl   # Event source types
│   ├── dispatcher.fnl        # Routes events to behaviors
│   └── event-loop.fnl        # Event processing loop
├── events/init.fnl       # Event hierarchy and definitions
├── event_sources/        # Event source implementations
├── behaviors/            # Behavior implementations
└── *.fnl                 # Feature modules (windows, slack, chrome, etc.)
```

## Code Style Guidelines

### Imports

Always use destructuring imports at the top of the file:

```fennel
;; Destructuring imports (preferred)
(local {: some : seq : hash-set} (require :lib.cljlib-shim))
(local {: define-event! : dispatch-event!} (require :lib.event-registry))

;; Plain require for single-export modules
(local notify (require :notify))
```

### Naming Conventions

| Type | Convention | Examples |
|------|------------|----------|
| Functions | `kebab-case` | `define-behavior`, `dispatch-event!` |
| Predicates | End with `?` | `event-defined?`, `empty?`, `isa?` |
| Mutating functions | End with `!` | `derive!`, `underive!`, `dispatch-event!` |
| Keywords | `:kebab-case` | `:window-move`, `:file-change` |
| Namespaced keywords | `:namespace/name` | `:event.kind.fs/file-change` |
| Optional parameters | Prefix with `?` | `?init-pairs`, `?config` |
| Internal registers | `*-register` suffix | `events-register`, `behavior-register` |

### Module Pattern

```fennel
;; Imports at top
(local {: func1 : func2} (require :some-module))

;; Private state
(local internal-register {})
(var mutable-state false)

;; Private helper functions (not exported)
(fn private-helper [args]
  "Docstring describing the function."
  ...)

;; Public functions
(fn public-function [args]
  "Docstring describing the function."
  ...)

;; Export public API as table at end of file
{: public-function
 : another-public-fn}
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
;; Critical errors - use (error ...) to halt execution
(when (= child parent)
  (error "Cannot derive a keyword from itself"))

;; Non-fatal warnings - use (print "[WARN] ...")
(when (= nil (. events-register event-name))
  (print (.. "[WARN] dispatch-event!: event '" (tostring event-name) "' not defined")))

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

## Architecture Overview

Event-driven architecture with these components:

1. **Event Sources** - Emit events (file watchers, app monitors)
2. **Events** - Named occurrences with structured data, organized in hierarchy
3. **Behaviors** - Named handlers that respond to events
4. **Subscriptions** - Connect behaviors to source+event pairs
5. **Hierarchies** - Enable hierarchical event matching (like Clojure multimethods)

### Common Patterns

```fennel
;; Defining an Event (in events/init.fnl)
(define-event! event-registry
               :file-watcher.events/file-change
               "File change detected"
               {:file-path string?})
(derive! event-hierarchy :file-watcher.events/file-change :event.kind.fs/file-change)

;; Defining a Behavior
(define-behavior :reload-on-change
                 "Reloads Hammerspoon when config files change"
                 [:event.kind.fs/file-change]  ; event selectors
                 (fn [event] ...))

;; Defining a Subscription
(define-subscription :sub/reload-on-config-change
  {:description "Reload when config changes"
   :behavior :reload-on-change
   :event-selector :event.kind.fs/file-change
   :source-selector :source/config-watcher})

;; Defining an Event Source Type
(define-source-type :event-source.type/file-watcher
  "Watches directory for changes"
  {:config-schema {:path string?}
   :emits [:file-watcher.events/file-change]
   :start-fn start-file-watcher
   :stop-fn stop-file-watcher})
```

## Hammerspoon APIs

Common APIs used in this codebase:
- `hs.timer.secondsSinceEpoch` - Current timestamp
- `hs.inspect` - Pretty-print tables for debugging
- `hs.reload()` - Reload Hammerspoon config
- `hs.alert()` - Show on-screen alert
- `hs.notify` - System notifications
- `hs.pathwatcher` - File system watcher
- `hs.execute` - Run shell commands

See [Hammerspoon API docs](https://www.hammerspoon.org/docs/) for full reference.
