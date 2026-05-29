# Sheaf

A design pattern for composable desktop automation.

## Why "Sheaf"?

The name resonates at three levels:

1. **Mathematical (sheaf theory)** — A sheaf is a structure for building
   consistent global data from local pieces. Local data lives on
   independent regions; gluing conditions ensure they compose into a
   coherent whole. In this system, components are the local regions
   (each self-contained), and subscriptions are the gluing — they
   produce global behavior from locally-defined parts.

2. **Physical (sheaf of wheat)** — Independent stalks, each complete on
   its own, bound together without merging or losing identity. The
   binding (subscriptions) holds them together. The value (the system's
   behavior) emerges from the bundle, not from any single stalk.

3. **Software pattern** — Context-blind components wired by subscriptions
   into a coherent system. No component knows about any other. The
   global behavior is a property of the gluing, not the parts.

## Core Insight

Components are context-blind units with lifecycle. Behaviors are
rules that receive candidate targets and select which to act on.
Commands declare which traits they require on target components. Behaviors
may declare shaped component-state inputs they need. Tags select which
components participate as sources, targets, and inputs. Subscriptions
wire those tags to a behavior — the only place these roles meet.

## Atoms

### Event

A fact about something that happened.

- **name** — unique identifier (e.g., `:file-watcher.events/file-change`)
- **schema** — expected shape of event data
- **kind-hierarchy** — position in the event kind tree (enables hierarchical matching)

### Command

A named action that runs on a component.

- **name** — unique identifier (e.g., `:space-indicator.commands/update-menubar`)
- **schema** — expected parameters
- **requires-traits** — list of traits the target component must implement
- **fn** — receives the resolved component and params, returns new state.
  The dispatcher injects the component and captures the returned
  state — the command itself never touches the registry.

### Component

A concrete unit of functionality with lifecycle. Context-blind. Reusable.
Follows a type/instance split. Components subsume event sources — every
event source belongs to a component, and components create their source
instances as part of their lifecycle.

- **type** — a blueprint defining lifecycle (start/stop), config schema,
  state, event sources, and which traits it implements
- **instance** — a running component with config, mutable state, and
  zero or more running event source instances
- **kind** — position in the component kind hierarchy

Components do NOT own commands. Commands declare `:requires-traits`
to specify which components they can target. Tags select which
components participate in source, target, or input roles. Subscriptions
wire those tagged roles to behaviors.

#### Component Kind Hierarchy

Component types form a hierarchy using the same `lib/hierarchy.fnl`
infrastructure as events. This enables hierarchical selectors — a
command declaring `:operates-on [:component.kind/any]` can target any
component.

```
:component.kind/any
├── :component.kind/space-indicator
├── :component.kind/expose
├── :component.kind/emacs
├── :component.kind/reload-hammerspoon
└── ...
```

Types derive from kinds:

```
:component.type/space-indicator  derives from  :component.kind/space-indicator
:component.type/expose           derives from  :component.kind/expose
```

A component type is a blueprint: it defines lifecycle (start/stop) and
optionally declares which event source types it composes. When a component
starts, it creates its owned source instances automatically. When it stops,
owned sources are torn down first. This is how event sources fold into
components — no separate source management needed.

### Trait

A named atomic contract over component state attributes. Traits say
"this state has this property"; components declare which traits they
implement. Commands require traits on targets.

### Shape

A named logical composition of traits. A shape describes acceptable
component-state inputs as alternatives: each alternative is a set of
traits that must all hold. Shapes let behaviors ask for "state matching
this role" without binding to a specific component.

### Behavior

A rule with logic that maps events to commands. Receives the set of
candidate target components (resolved by the dispatcher from the
subscription's target tag) and decides which to send commands to. May
also receive shaped input state from components selected by the
subscription's input tag.

- **name** — unique identifier
- **responds-to** — which event kinds trigger this behavior
- **commands** — aliases mapping to registered command names
- **inputs** — optional aliases mapping to shape names
- **fn** — the handler function

The handler receives the event, a set of candidate target components
(resolved by the dispatcher from the subscription's target tag, grouped
by command alias), a send-cmd function, and optional input state keyed
by input alias. The behavior selects which candidates to act on and
sends commands to them. For simple 1:1 cases it picks the first
candidate. For fan-out, it iterates. For context-dependent selection,
it inspects event data, candidate state, or shaped inputs.

### Tag

A contextual label attached to component instances. Tags are the
primary wiring mechanism — they determine which component instances
play source, target, or input roles for a subscription. Tags are
assigned to instances, not to types or kinds.

### Subscription

The wiring between source components, behaviors, and target components.
Uses tags to select source, target, and optional input sets.

- **behavior** — which behavior to invoke
- **source** — tag selecting which components provide events
- **target** — tag selecting which components are command candidates
- **input** — optional tag selecting components whose state can satisfy
  the behavior's input shapes

At event-time, the dispatcher:
1. Matches the event's source component against subscriptions by source tag
2. Resolves all components with the target tag as candidates
3. Groups candidates by command alias (filtered by `:requires-traits`)
4. Resolves input components by input tag and filters them by shape
5. Invokes the behavior with `(fn [event candidates send-cmd inputs] ...)`

The dispatcher validates `:requires-traits` when the behavior calls
`send-cmd`, validates behavior inputs by shape, and captures returned
command state back on the target instance.

## Composition

Built bottom-up from orthogonal primitives:

```
Events, Commands, Traits, Shapes   (atoms — facts, actions, state contracts)
  → Components                     (runtime units — emit events, hold state)
    → Behaviors                    (rules: event + inputs → commands)
      → Tags                       (labels — select source, target, input sets)
        → Subscriptions            (wiring: tags → behavior)
          → System Map             (the complete value)
```

Each concept is independent. Commands declare `:requires-traits` for
affinity with component capabilities, but they never reference specific
instances. Shapes describe behavior input needs. Tags select which
components participate. Subscriptions wire tags to behaviors. The system
is the composition of these values.

## Event Flow

```
Component A (tagged :src) emits Event via owned source
    │
Subscription: source=:src, behavior=X, target=:tgt, input=:cfg
    │
Dispatcher:
    │  1. Matches: A has tag :src → subscription fires
    │  2. Resolves behavior X
    │  3. Finds all components tagged :tgt → [C, D]
    │  4. Groups by command alias (filtered by :requires-traits)
    │     candidates = {:update-menubar [C D]}
    │  5. Finds components tagged :cfg whose state conforms to input shapes
    │  6. Builds send-cmd (validates :requires-traits, captures state)
    │
Behavior X: fn [event candidates send-cmd inputs]
    │  (let [target (. candidates.update-menubar 1)]
    │    (send-cmd target :update-menubar {:active-spaces [1 3]}))
    │
Dispatcher captures returned state → updates target component
    ▼
```

## System Map

The complete value describing the running system:
component instance tree + subscriptions + tags.

The entire system is a value — inspectable, serializable, queryable.

## Key Properties

- Components don't know about each other
- Behaviors receive candidate targets and select via send-cmd
- Commands declare `:requires-traits` but never reference instances
- Behaviors declare shaped inputs but never own input components
- All commands run on a component — no standalone commands
- Event sources belong to components — no standalone source concept
- Subscriptions wire source, target, and input tags to behaviors
- Tags are the universal wiring mechanism for component roles
- Every concept is a simple, independent value
- The system is the composition of these values

## Open Questions

- **System map structure** — what defines parent-child relationships
  in the component instance tree? Explicit nesting in the system map,
  or derived?

- **Command execution model** — does `send-cmd!` execute synchronously?
  Can behaviors chain commands?

## Inspirations

- **LightTable BOT** — behavior-object-tag architecture
- **Clojure / Integrant** — system as a value, declarative config
- **Emacs** — modes, hooks, keymaps as composable layers
- **Datomic** — facts, time, queryability
- **Linear algebra** — orthogonal decomposition of a system into independent basis vectors
- **Sheaf theory** — local data glued consistently into a global whole
