# Window Width State: Separate Component with Override-Only Bridge

Width state (ratio1/ratio2/full/custom) lives in a separate Sheaf component
(`window-width-state`) with its own trait and shape, not in the existing
`window-state` component. This follows P1 (facts vs choices) and P3 (precise
coeffects): the golden overlay behavior needs only width state, not full window
metadata, and `build-inputs` returns component state wholesale without
projection — only a separate component delivers a narrow input.

`paper-wm.fnl`'s `tile-space!` does NOT read width state. Only Sheaf commands
compute widths from state and pass them as `?anchor-frame-override`. The
C-boundary path (`window-event-handler` → `tile-space!`) always uses the
current frame width (existing behavior). This avoids fighting the user during
live mouse drags: `move-window!` stops the AX uielement watcher during
`setFrame`, so `AXWindowResized` does not fire during animation. After the
watcher restarts, the frame is at the target width, so the C-boundary
`tile-space!` reads the correct final frame.

Ratios are computed against `canvas.h`, not `canvas.w`, to produce consistent
window proportions (aspect-ratio aesthetic) across screens. Width cycling is a
simple toggle (ratio1 ↔ ratio2), not directional — from any other state, the
first toggle always goes to ratio1.

## Removed Functionality

Height cycling (Alt+Cmd+Shift+R, Ctrl+Alt+Cmd+Shift+R) is removed. Width
cycling (Ctrl+Alt+Cmd+R) is removed. Width cycling (Alt+Cmd+R) is replaced by
a simple toggle. Users who relied on height cycling should use full-width
(Alt+Cmd+F) or manual resize instead.

## Breaking Change: Ratio Computation

Ratios change from `canvas.w`-based to `canvas.h`-based computation. The
existing `config.window-ratios [0.421875 0.843750]` were tuned for `canvas.w`.
With `canvas.h`, the same values produce significantly different pixel widths
(e.g., on a 16:9 display, ratio1 × canvas.h ≈ 820px vs ratio1 × canvas.w ≈
1458px). Users must recalibrate `config.window-ratios` after this change.

## Considered Options

- **Extend `window-state` component**: simpler but violates P1 (fact/choice
  co-location), P2 (coarse trait), and P3 (bloated coeffect for overlay).
  Rejected.
- **Mutable global var in paper-wm.fnl**: a `(var width-states nil)` + setter
  written by commands before tiling. Eliminated — commands read
  `component.state.widths` directly and pass computed widths as
  `anchor-frame-override`. No mutable global, no setter, no stale-var problem.
- **`paper-wm.fnl` imports Sheaf component**: creates circular dependency and
  reads stale state (dispatcher captures after command returns). Rejected.
- **Debounce timer in owned event source**: source `start-fn` receives `emit`,
  but there is no API for commands to dynamically control (cancel/restart) a
  timer in source state. Source state is less accessible to commands than
  component state. Rejected.
- **Full migration of event path to Sheaf**: correct end state but too large
  for one step. The override-only approach enables incremental progress.

## Architecture

### paper-wm.fnl Exports

`tile-space!` and `get-canvas` must be exported from paper-wm.fnl (currently
private). Commands call `tile-space!(space, anchor-frame-override)` with
computed widths. A new `retile-with-width-overrides!(width-map)` function is
added for screen-change retiling: it iterates all spaces, finds the anchor
window in each, computes the override frame from the width map, and calls
`tile-space!` per space. This keeps `window-list`/`index-table` private while
enabling multi-space retiling.

### Components

1. **window-width-state** (new): `:trait/has-width-state`, `:shape/width-state`.
   State: `{:widths {window-id → {:width-state :width-ratio}}
           :pending-timers {window-id → hs.timer}
           :suppress-resize-until number}`.
   - `:widths` — per-window width state (the trait-required field).
   - `:pending-timers` — debounce timers, stored in component state because
     commands can mutate component state (return new state to dispatcher).
     The timer callback calls a module-level `dispatch-event!` reference to
     emit `:width-state.events/debounce-complete`. This follows the
     `reload-hammerspoon` component pattern (stores `hs.timer.delayed` in
     component state) but emits a Sheaf event via a captured event-registry
     reference instead of calling `hs.reload` directly.
   - `:suppress-resize-until` — timestamp (seconds since epoch) until which
     `set-custom-on-resize` should be suppressed. Set by commands before
     calling paper-wm functions to prevent WindowFilter.windowResized (which
     fires for programmatic `setFrame`, not just user drags) from overwriting
     the state just set by the command. Cleared after `animationDuration +
     padding + 100ms` margin.

   Commands: `set-width-state`, `remove-width-state`, `initialize-width-states`,
   `recompute-widths`.

2. **window-width-config** (new): `:trait/has-width-config`, `:shape/width-config`.
   Static config (url-routing-rules pattern). State:
   `{:rules [...] :fallback :ratio1}`.
   Rules: `{bundle-id → :ratio1/:ratio2/:full/:custom/:unspecified}`.
   Fallback: `:ratio1` (default for unmatched apps). `:unspecified` = no
   auto-resize (the behavior skips the `set-width-state` command).
   References `paper-wm.config.window-ratios` for ratio values during
   migration (single source of truth, no duplication).

3. **window-overlay** (new): `:trait/has-canvas`. Golden overlay canvas
   (window-border pattern). Starts hidden (`canvas:hide` in `start-fn`).
   Commands: `show-overlay`, `hide-overlay`.
   Shows briefly on resize release as a snap confirmation flash, not a live
   guide during drag. Auto-hides after 500ms failsafe timeout in
   `show-overlay` command if `hide-overlay` doesn't fire.

### Events

4. **`:window-watcher.events/resized`** (new concrete event): added to
   `event_sources/window-watcher.fnl` via `WindowFilter.windowResized`.
   Derived under `:event.kind.window/resized` (which already exists in
   `events/init.fnl`). Note: WindowFilter uses internal polling and fires for
   BOTH user drags and programmatic `setFrame`. The suppress flag
   (`:suppress-resize-until`) prevents programmatic resizes from triggering
   `set-custom-on-resize`.

5. **`:event.kind.width-state/any`** (new event kind): derived from
   `:event.kind/any` in `events/init.fnl`.

6. **`:width-state.events/debounce-complete`** (new concrete event): schema
   `{:window-id number?}`. Derived under `:event.kind.width-state/any`.
   Emitted by the debounce timer callback (stored in component state) via a
   module-level `dispatch-event!` reference captured at component start.

### Module-Level Event Dispatch Reference

The width-state component's `start-fn` captures a reference to
`dispatch-event!` (from `sheaf.event-registry`) at module load time. This
reference is stored in a module-level var (not component state) and used by
debounce timer callbacks to emit `:width-state.events/debounce-complete`.
This is necessary because component `start-fn` does not receive `emit` (only
source `start-fn` does), and the timer callback runs asynchronously outside
Sheaf dispatch. The module-level reference is set once during module
initialization in `commands/window-width-state.fnl` (or a shared lib) before
any commands run. This follows ADR-0001's conversations pattern: async
outcomes re-enter the system as new events.

### Behaviors

7. **toggle-width**: responds to Alt+Cmd+R hotkey.
   `:inputs {:width-state :shape/width-state :window-state :shape/window-state}`.
   Subscription uses shared `:input-tag :tag/window-info`. Reads
   `focused-window-id` from `inputs.window-state.focused-window-id`, looks up
   current width state in `inputs.width-state.widths`, toggles ratio1↔ratio2
   (from any other state → ratio1). Sends `set-width-state` command to
   `:tag/window-width-state` target. The command: (1) updates
   `component.state.widths[window-id]`, (2) sets `:suppress-resize-until` to
   `now + animationDuration + padding + 100ms`, (3) computes width =
   `ratio × canvas.h` (clamped to `canvas.w`), (4) calls
   `tile-space!(space, frame)` with the computed width as
   `anchor-frame-override`. Returns new state including updated widths,
   suppress flag, and preserved pending-timers.

8. **set-full-width-state**: responds to Alt+Cmd+F hotkey. Same shared input
   pattern. Sends `set-width-state` with `:full`. The command: (1) updates
   state to `:full`, (2) sets suppress flag, (3) calls
   `set-window-full-width!` (which handles focused-window lookup, canvas
   computation, and calls `tile-space!` with the override internally — no
   separate `tile-space!` call needed). Returns new state.

9. **initialize-width-states**: responds to `:event.kind.window/initial`.
   Reads width-config as input. For each window in the initial-windows batch,
   sets width state to the configured default (or `:ratio1` fallback, or
   skip if `:unspecified`). Sends `initialize-width-states` command with the
   full window list. This closes the startup gap — existing windows get width
   state on boot.

10. **apply-default-on-appear**: responds to `:event.kind.window/visible`.
    Reads width-config as input. Checks if the window-id already has width
    state (e.g., preserved across fullscreen). If yes, skips. If no, sets to
    configured default. This prevents overwriting preserved state on
    unfullscreen.

11. **set-custom-on-resize** (targets `:tag/window-width-state`): responds to
    `:event.kind.window/resized`. Checks the `:suppress-resize-until` field in
    the width-state input — if current time is before the deadline, skips
    (this is a programmatic resize, not a user drag). Otherwise, sends
    `set-width-state` with `:custom` and the current width ratio
    (`width / canvas.h`). The command: (1) updates state to `:custom` with
    stored ratio, (2) cancels any previous debounce timer for this window-id,
    (3) creates a new `hs.timer.doAfter(debounce-delay, callback)` and stores
    it in `:pending-timers[window-id]`. The callback emits
    `:width-state.events/debounce-complete`. Returns new state.

12. **show-overlay-on-resize** (targets `:tag/window-overlay`): responds to
    `:event.kind.window/resized`. A SEPARATE subscription with
    `:target-tag :tag/window-overlay`, same event-selector. Reads width-state
    as input (`:input-tag :tag/window-width-state`). Computes whether the
    current width is near a ratio (within ±0.01). If yes, sends `show-overlay`
    with the window frame and ratio label. If no, sends `hide-overlay`.
    This is a second subscription on the same event — the Sheaf model supports
    multiple subscriptions for the same event with different target-tags.
    Also checks the suppress flag and skips if suppressed.

13. **evaluate-snap**: responds to `:width-state.events/debounce-complete`.
    Reads width-state as input. Evaluates whether the window's current width
    is within ±0.01 of a ratio or full. If yes, sends `set-width-state` to
    snap to the exact ratio (which retiles with the snapped width via the
    command's override mechanism). Sends `hide-overlay` to dismiss the
    confirmation flash. The `set-width-state` command for a snap also sets
    the suppress flag (since snapping is a programmatic resize).

14. **recompute-on-screen-change**: responds to
    `:event.kind.screen/layout-changed`. Reads width-state as input. Sends
    `recompute-widths` command to `:tag/window-width-state`. The command:
    (1) iterates all width states, recomputes widths for the new canvas
    (ratio states use `ratio × new_canvas.h`, custom uses
    `stored_ratio × new_canvas.h`, full uses `canvas.w`), (2) sets suppress
    flag, (3) calls `retile-with-width-overrides!(width-map)` (the new
    paper-wm.fnl function that retiles all spaces with per-space overrides).
    Single command handles both recompute and retile — eliminates the
    ordering problem.

15. **remove-width-on-disappear**: responds to
    `:event.kind.window/not-visible`. Sends `remove-width-state` to clean
    up. The command also cancels any pending debounce timer for the
    window-id.

### Hotkey Changes

16. Drop 3 hotkeys (Ctrl+Alt+Cmd+R, Alt+Cmd+Shift+R, Ctrl+Alt+Cmd+Shift+R).
    Alt+Cmd+R = single toggle. Remove WIDTH/HEIGHT/ASCENDING/DESCENDING from
    Direction enum. Remove `cycle-window-size!` and `find-new-size` from
    paper-wm.fnl.

### Ratio Computation

17. Ratios computed against `canvas.h` (not `canvas.w`). The fallback
    (`config.window-ratios`) is also changed to compute against `canvas.h`
    so cold-start widths match state-driven widths. `config.window-ratios`
    remains the single source of truth for ratio values during migration.
    The width-config component references `paper-wm.config.window-ratios`
    for ratio values rather than duplicating them.

### Multi-Window Columns

18. All windows in a column share the column's width (existing behavior).
    The anchor window's width state determines the anchor column's width.
    Non-anchor columns use the first window's current frame width (existing
    behavior). Width state is per-window but column width is shared — the
    anchor's state wins for the anchor column, and non-anchor columns keep
    their current width. This matches current behavior and avoids complexity.

### Shared Input Tag

19. Both `window-width-state` and `window-state` components carry
    `:tag/window-info` in addition to their individual tags
    (`:tag/window-width-state` and `:tag/window-state`). Behaviors that need
    both width state and focused-window-id use `:input-tag :tag/window-info`.
    `build-inputs` iterates all components with the input-tag and resolves
    each input alias to the first component whose state conforms to the
    declared shape. Width-state conforms to `:shape/width-state` (requires
    `:widths`); window-state conforms to `:shape/window-state` (requires
    `:windows`). Cross-conformance is clean — no component has both fields.

### Fullscreen Transition

20. `apply-default-on-appear` checks if the window-id already exists in the
    widths table before setting a default. If it exists (preserved from
    before fullscreen), skip. This prevents overwriting the user's width
    preference on unfullscreen.

### Window Move (Not Resize)

21. The C-boundary path (`AXWindowMoved` → `tile-space!`) uses the current
    frame width (existing behavior). Width state is not consulted. A window
    move does not change the window's width. This is correct — the user
    repositioned, not resized.

### Suppress Flag

22. WindowFilter.windowResized fires for BOTH user drags and programmatic
    `setFrame` (it uses internal polling, not AX watchers). Without a guard,
    every toggle/set-full-width/snap would trigger `set-custom-on-resize`,
    immediately overwriting the state to `:custom`. The suppress flag
    (`:suppress-resize-until` in component state) prevents this: commands
    set it to `now + animationDuration + padding + 100ms` before calling
    paper-wm functions. `set-custom-on-resize` and `show-overlay-on-resize`
    check it and skip if current time is before the deadline. The flag is
    per-component (not per-window) because programmatic resizes affect one
    window at a time and the suppress window is short (~300ms).

## Consequences

- New Sheaf atoms: `:trait/has-width-state`, `:shape/width-state`,
  `window-width-state` component. `:trait/has-width-config`,
  `:shape/width-config`, `window-width-config` component.
  `:trait/has-canvas` (already exists, reused by overlay component).
- New events: `:window-watcher.events/resized` (derived under
  `:event.kind.window/resized`), `:width-state.events/debounce-complete`
  (derived under new `:event.kind.width-state/any`).
- New `window-overlay` component (mirrors `window-border`, starts hidden).
- New shared `:tag/window-info` tag on width-state and window-state
  components.
- `paper-wm.fnl` exports `tile-space!` and `get-canvas` (currently private).
  Adds `retile-with-width-overrides!` function. Loses `cycle-window-size!`,
  `find-new-size`, 3 hotkey sources, and 4 Direction enum values.
- `config.window-ratios` remains single source of truth for ratio values.
  Fallback computation changes from `canvas.w` to `canvas.h` (breaking
  change — users recalibrate ratios).
- Debounce timer stored in component state (`:pending-timers`), not in an
  event source. Timer callback uses a module-level `dispatch-event!`
  reference to emit the debounce-complete event (conversations pattern,
  ADR-0001).
- Suppress flag (`:suppress-resize-until`) in component state prevents
  WindowFilter.windowResized from overwriting state on programmatic resizes.
- `set-custom-on-resize` and `show-overlay-on-resize` are separate
  subscriptions on the same event with different target-tags (Sheaf supports
  multiple subscriptions per event).
- Three hotkeys dropped. Alt+Cmd+R becomes a single toggle.
- Width state is not persisted across Hammerspoon reloads (known gap,
  documented).
