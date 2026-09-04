# Cosmic Hammer Config (Sheaf)

A Hammerspoon configuration built on Sheaf — a pattern of composable
atoms (events, commands, traits, shapes, components, behaviors, tags,
subscriptions) glued into a system by subscriptions.

## Language

**Behavior invocation**:
One run of a behavior in response to one event. Bounded by that event —
it never outlives it. Commands sent during it execute synchronously.
_Avoid_: transaction (implies parking/awaiting async results)

**Conversation**:
A chain of behavior invocations linked by events, where an asynchronous
outcome (chooser selection, timer, watcher) re-enters as a new event
triggering the next invocation. The Sheaf way to express long-running
interactions.

**Definition**:
A timeless vocabulary entry — event, trait, shape, command,
event-source type, component type, behavior, hierarchy derivation.
Contributed by modules. Contains no instance configuration.

**Instantiation**:
A concrete configured occurrence of a definition in this system —
component instance, event-source instance, subscription, tag
attachment. Contributed by layers.
_Avoid_: instance config, wiring config (as separate notions)

**Params**:
Per-wiring, static, one-reader configuration carried by a
subscription and passed to the behavior. A choice, not a fact.
_Avoid_: config (too broad), options

**Input**:
Shared, live, many-reader context — component state resolved by
input-tag and shape at event time, passed read-only to a behavior.
A fact, not a choice.

**Effect type (of a behavior)**:
The set of commands a behavior declares. Fixed in the definition;
not parameterizable. Runtime selection among declared commands is
ordinary behavior logic.

**Module**:
A prospective bundle contributing definitions (vocabulary).
Mechanism undecided.

**Layer**:
A prospective bundle contributing instantiations (configuration).
Mechanism undecided.

**Builder**:
A pure function from a spec (data) to the Sheaf atoms it expands into
(data). Builders never touch runtime, registries, or `hs.*`.
_Avoid_: macro, framework (both imply hidden execution)

**Interpreter**:
The component of the engine that gives inert data meaning by executing
it (dispatcher for events, send-cmd for commands, assembler for specs).
Descriptions never execute themselves.

## Window Width State

**Width state**:
The desired width policy for a tiled window. One of :ratio1, :ratio2,
:full, or :custom. Determines how the tiling engine computes the
window's pixel width.
_Avoid_: width mode, size mode

**Width ratio**:
A float expressing a window's width as a fraction of canvas height.
For :ratio1 and :ratio2, the configured constants (0.421875, 0.843750).
For :custom, the measured width / canvas.h at the moment of mouse resize.
For :full, irrelevant — width is always canvas.w.
_Avoid_: width fraction, size ratio

**Golden ratio snap**:
During a mouse width-resize, when the window's width ratio is within
tolerance (default ±0.01) of a configured ratio or full width, a
transparent golden overlay is drawn over the window. On mouse release
(debounced, default 1200ms), the width snaps to the exact ratio and the
width state is set accordingly.
_Avoid_: magnetic snap, ratio lock

**Width config**:
A static rule table mapping bundle-ids to default width states for new
windows. Follows the url-routing-rules pattern: a config component with
its own trait and shape, consumed as a shaped input by the behavior
that applies defaults on window-appear. "Unspecified" means the window
is not auto-resized on open.
_Avoid_: width rules, sizing config

**Width toggle**:
The single action (Alt+Cmd+R) that flips between :ratio1 and :ratio2.
From any other state (:full, :custom, or new window), the first toggle
always goes to :ratio1. There is no directional cycling — it is a
simple toggle. Previous state is always forgotten.
_Avoid_: cycle width, resize cycle

**Debounce timer**:
A per-window hs.timer stored in the width-state component's
:pending-timers field. Delays committing a mouse-resize width state
until the user stops dragging. Default 1200ms, configurable. On each
resize event, the previous timer is cancelled and a new one started.
When it fires, it calls a module-level dispatch-event! reference to
emit :width-state.events/debounce-complete, re-entering Sheaf as a
conversation (ADR-0001) to evaluate the golden snap. Stored in
component state (not an event source) because commands can mutate
component state but cannot control source state.
_Avoid_: resize timer, drag timer

**Suppress flag**:
A timestamp (:suppress-resize-until) in the width-state component state
that prevents set-custom-on-resize from firing on programmatic setFrame
calls. WindowFilter.windowResized fires for both user drags and
programmatic resizes; the suppress flag distinguishes them. Commands
set it before calling paper-wm functions; set-custom-on-resize checks
it and skips if current time is before the deadline.
_Avoid_: resize guard, programmatic filter
