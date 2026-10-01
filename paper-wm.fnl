;; PaperWM effect interpreter over explicit component state.

(local {: empty-state
        :valid? layout-valid?
        :slurp-window layout-slurp-window
        :barf-window layout-barf-window
        :swap-window layout-swap-window
        : focus-target
        : set-focused-window} (require :paper-wm.layout))
(local {: plan-membership} (require :paper-wm.membership))
(local {: plan-column} (require :paper-wm.frames))
(local {: next-observation : consume-latest} (require :paper-wm.observations))
(local {:start start-space-operation
        :advance advance-space-operation} (require :paper-wm.space-conversation))
(local {: some} (require :lib.cljlib-shim))

(local Window hs.window)
(local Screen hs.screen)
(local Spaces hs.spaces)
(local Timer hs.timer)
(local Watcher hs.uielement.watcher)
(local Rect hs.geometry.rect)

(local default-config {:window-gap 35
                       :screen-margin 16
                       :window-ratios [0.421875 0.843750]
                       :min-window-height 80})

;; Retries poll at the window animation cadence; with animations disabled
;; (animationDuration 0) this floor keeps them from becoming a busy loop.
(local space-retry-min-delay 0.05)


(fn runtime-epoch [config]
  (or config.epoch
      (and Timer.absoluteTime (Timer.absoluteTime))
      (* 1000000 (Timer.secondsSinceEpoch))))

(fn make-runtime [config]
  "Create independent PaperWM component state."
  (let [config (or config {})]
    {:active? true
     :epoch (runtime-epoch config)
     :config {:window-gap (or config.window-gap default-config.window-gap)
              :screen-margin (or config.screen-margin default-config.screen-margin)
              :window-ratios (or config.window-ratios default-config.window-ratios)
              :min-window-height (or config.min-window-height
                                     default-config.min-window-height)}
     :tiling-state (empty-state)
     :resources {:windows {}
                 :ui-watchers {}
                 :watcher-generations {}
                 :watcher-restart-timers {}
                 :frame-observations {:sequences {} :latest {} :timers {}}
                 :outbox nil
                 :space-focus {:next-generation 0 :active nil}
                 :space-focus-timer nil}
     :last-reconcile-report nil}))

(fn copy-table [source]
  (let [result {}]
    (each [key value (pairs source)]
      (tset result key (if (= :table (type value)) (copy-table value) value)))
    result))

(fn table-count [source]
  (var count 0)
  (each [_ _ (pairs (or source {}))] (set count (+ count 1)))
  count)

(fn diagnostic-snapshot [runtime]
  "Return logical state and bounded resource counts without handles."
  {:active? runtime.active?
   :epoch runtime.epoch
   :window-list (copy-table runtime.tiling-state.spaces)
   :index-table (copy-table runtime.tiling-state.index)
   :focused-window-id runtime.tiling-state.focused-window-id
   :last-reconcile-report (copy-table (or runtime.last-reconcile-report {}))
   :resources {:ui-watcher-count (table-count runtime.resources.ui-watchers)
               :watcher-restart-timer-count
               (table-count runtime.resources.watcher-restart-timers)
               :frame-timer-count
               (table-count runtime.resources.frame-observations.timers)
               :space-focus-timer? (not= nil runtime.resources.space-focus-timer)}})

(fn invariant-report [runtime]
  "Return the logical layout invariant status."
  (let [(ok reason) (layout-valid? runtime.tiling-state)]
    {:ok? ok :reason reason :epoch runtime.epoch}))

(fn commit-state! [runtime next-state]
  (let [(ok reason) (layout-valid? next-state)]
    (when (not ok)
      (error (.. "PaperWM layout invariant failed: " (tostring reason))))
    (tset runtime :tiling-state next-state)
    next-state))

(fn resolve-window [window-id]
  (let [(ok window) (pcall Window.get window-id)]
    (when ok window)))

(fn get-space [index]
  (let [layout (Spaces.allSpaces)]
    (var remaining index)
    (var result nil)
    (each [_ screen (ipairs (Screen.allScreens)) &until result]
      (let [screen-spaces (. layout (screen:getUUID))]
        (if (<= remaining (length screen-spaces))
            (set result (. screen-spaces remaining))
            (set remaining (- remaining (length screen-spaces))))))
    result))

(fn space-index-after-direction [direction]
  "Return an absolute Space index for a relative subscription choice."
  (let [offset (if (= direction :left) -1 (= direction :right) 1 nil)]
    (when (= nil offset) (lua "return nil"))
    (let [focused-space (Spaces.focusedSpace)
          layout (Spaces.allSpaces)]
      (var focused-index -1)
      (var count 0)
      (each [_ screen (ipairs (Screen.allScreens))]
        (let [screen-spaces (. layout (screen:getUUID))]
          (when (< focused-index 0)
            (each [index space-id (ipairs screen-spaces)]
              (when (= focused-space space-id)
                (set focused-index (+ count index))
                (lua :break))))
          (set count (+ count (length screen-spaces)))))
      (when (and (>= focused-index 0) (> count 0))
        (+ (% (+ (- focused-index 1) offset) count) 1)))))

(fn live-frame [window]
  "Return a window's frame, or nil when its handle is torn down. A dead AX
   element reports an empty 0x0 frame rather than raising."
  (let [(ok frame) (pcall #(window:frame))]
    (when (and ok frame (> frame.w 0) (> frame.h 0)) frame)))

(fn get-first-visible-window [runtime columns screen]
  "Return the first live column head at or right of the screen's left edge,
   with its frame."
  (let [left-edge (. (screen:frame) :x)]
    (var (result result-frame) nil)
    (each [_ window-ids (ipairs (or columns {})) &until result]
      (let [window (. runtime.resources.windows (. window-ids 1))
            frame (and window (live-frame window))]
        (when (and frame (>= frame.x left-edge))
          (set (result result-frame) (values window frame)))))
    (values result result-frame)))

(fn get-column [runtime space column]
  "Return {:window :frame} for the live members of one column; a dead handle
   is skipped until its ineligible snapshot drops it from the layout."
  (let [result []]
    (each [_ window-id (ipairs (. (or (. runtime.tiling-state.spaces space) {}) column))]
      (let [window (. runtime.resources.windows window-id)
            frame (and window (live-frame window))]
        (when frame (table.insert result {: window : frame}))))
    result))

(fn get-canvas [runtime screen]
  (let [frame (screen:frame)
        gap runtime.config.window-gap]
    (Rect (+ frame.x gap) (+ frame.y gap)
          (- frame.w (* 2 gap)) (- frame.h (* 2 gap)))))

(fn move-window! [runtime window frame ?current]
  (let [id (window:id)
        watcher (. runtime.resources.ui-watchers id)
        current (or ?current (live-frame window))]
    (when (or (= nil watcher) (= nil current) (= frame current)) (lua "return"))
    (let [pending (. runtime.resources.watcher-restart-timers id)]
      (when pending (pending:stop)))
    (watcher:stop)
    (pcall #(window:setFrame frame))
    (let [generation (. runtime.resources.watcher-generations id)]
      (tset runtime.resources.watcher-restart-timers id
            (Timer.doAfter
             (+ Window.animationDuration 0.02)
             (fn []
               (tset runtime.resources.watcher-restart-timers id nil)
               (let [live-watcher (. runtime.resources.ui-watchers id)]
                 (when (and runtime.active?
                            live-watcher
                            (= generation (. runtime.resources.watcher-generations id)))
                   (live-watcher:start [Watcher.windowMoved Watcher.windowResized])))))))))

(fn tile-column! [runtime column bounds height width anchor-id anchor-height]
  (let [members (collect [_ member (ipairs column)] (member.window:id) member)
        entries (icollect [_ member (ipairs column)]
                  {:window-id (member.window:id) :frame member.frame})
        (plan column-width)
        (plan-column entries bounds
                     {:gap runtime.config.window-gap
                      :min-height runtime.config.min-window-height
                      :height height
                      :width width
                      :anchor-window-id anchor-id
                      :anchor-height anchor-height})]
    (each [_ intent (ipairs plan)]
      (let [member (. members intent.window-id)]
        (move-window! runtime member.window intent.frame member.frame)))
    column-width))

(fn tracked-window-on-space [runtime window-id space]
  (let [entry (and window-id (. runtime.tiling-state.index window-id))]
    (when (and entry (= entry.space space))
      (. runtime.resources.windows window-id))))

(fn live-tracked-window [runtime window-id space]
  "Return a tracked window on space and its live frame, or nil if dead."
  (let [window (tracked-window-on-space runtime window-id space)
        frame (and window (live-frame window))]
    (when frame (values window frame))))

(fn copy-frame [frame]
  (Rect frame.x frame.y frame.w frame.h))

(fn resolve-anchor [runtime space screen ?anchor]
  "Return the anchor window and a private copy of the frame to tile around.
   An explicit {:window-id :frame} anchor wins only when that window is live
   and tracked on this Space; otherwise the recorded focused window when it is
   live on this Space, then the first visible column head. Only when no focus
   is recorded (the focused member just closed, before its successor's focus
   fact arrives) is the live focused window consulted, so the successor stays
   in place."
  (let [explicit (and ?anchor ?anchor.frame
                      (live-tracked-window runtime ?anchor.window-id space))
        recorded-id runtime.tiling-state.focused-window-id
        live-focused (when (and (not explicit) (= nil recorded-id))
                       (Window.focusedWindow))
        focused-id (or recorded-id (and live-focused (live-focused:id)))
        (focused-window focused-frame)
        (when (not explicit)
          (live-tracked-window runtime focused-id space))]
    (if explicit (values explicit (copy-frame ?anchor.frame))
        focused-window (values focused-window (copy-frame focused-frame))
        (let [(window frame) (get-first-visible-window
                              runtime (. runtime.tiling-state.spaces space) screen)]
          (when window (values window (copy-frame frame)))))))

(fn tile-space! [runtime space ?anchor]
  "Interpret current layout into window frame effects around one anchor."
  (when (or (= nil space) (not= (Spaces.spaceType space) :user)) (lua "return"))
  (let [screen (Screen (Spaces.spaceDisplay space))]
    (when (= nil screen) (lua "return"))
    (let [(anchor frame) (resolve-anchor runtime space screen ?anchor)]
      (when (= nil anchor) (lua "return"))
      (let [anchor-index (. runtime.tiling-state.index (anchor:id))
            screen-frame (screen:frame)
            left-margin (+ screen-frame.x runtime.config.screen-margin)
            right-margin (- screen-frame.x2 runtime.config.screen-margin)
            canvas (get-canvas runtime screen)]
        (set frame.x (math.max frame.x canvas.x))
        (set frame.w (math.min frame.w canvas.w))
        (set frame.h (math.min frame.h canvas.h))
        (when (> frame.x2 canvas.x2) (set frame.x (- canvas.x2 frame.w)))
        (let [column (get-column runtime space anchor-index.col)]
          (when (= 0 (length column)) (lua "return"))
          (if (= 1 (length column))
              (do
                (set frame.y canvas.y)
                (set frame.h canvas.h)
                (move-window! runtime anchor frame))
              (let [remaining (- (length column) 1)
                    height (math.floor
                            (/ (math.max 0 (- canvas.h frame.h
                                              (* remaining runtime.config.window-gap)))
                               remaining))]
                (tile-column! runtime column
                              {:x frame.x :x2 nil :y canvas.y :y2 canvas.y2}
                              height frame.w (anchor:id) frame.h)))
          (var x (math.min (+ frame.x2 runtime.config.window-gap) right-margin))
          (for [column-index (+ anchor-index.col 1)
                             (length (. runtime.tiling-state.spaces space))]
            (let [width (tile-column! runtime
                                      (get-column runtime space column-index)
                                      {:x x :x2 nil :y canvas.y :y2 canvas.y2})]
              (when width
                (set x (math.min (+ x width runtime.config.window-gap) right-margin)))))
          (var x2 (math.max (- frame.x runtime.config.window-gap) left-margin))
          (for [column-index (- anchor-index.col 1) 1 -1]
            (let [width (tile-column! runtime
                                      (get-column runtime space column-index)
                                      {:x nil :x2 x2 :y canvas.y :y2 canvas.y2})]
              (when width
                (set x2 (math.max (- x2 width runtime.config.window-gap)
                                  left-margin))))))))))

(fn emit! [runtime event-name data]
  "Publish an asynchronous outcome through the component-owned outbox source."
  (let [emit runtime.resources.outbox]
    (when (and runtime.active? emit) (emit event-name data))))

(fn observe-frame! [runtime window-id event-kind frame generation]
  "Coalesce one window's AX frame changes to the latest observation and publish
   it at display cadence."
  (let [observations runtime.resources.frame-observations]
    (next-observation observations window-id event-kind frame generation)
    (when (= nil (. observations.timers window-id))
      (tset observations.timers window-id
            (Timer.doAfter
             (/ 1 60)
             (fn []
               (tset observations.timers window-id nil)
               (let [latest (. observations.latest window-id)]
                 (when latest
                   (emit! runtime :paper-wm.events/frame-observed latest)))))))))

(fn attach-window! [runtime window-id]
  (let [window (resolve-window window-id)]
    (when window
      (tset runtime.resources.windows window-id window)
      (when (= nil (. runtime.resources.ui-watchers window-id))
        (let [generation (+ 1 (or (. runtime.resources.watcher-generations window-id) 0))
              watcher (window:newWatcher
                       (fn [observed-window event-kind]
                         (let [(ok frame) (pcall #(: observed-window :frame))]
                           (when (and runtime.active? ok)
                             (observe-frame! runtime window-id (tostring event-kind)
                                             frame generation)))))]
          (tset runtime.resources.watcher-generations window-id generation)
          (watcher:start [Watcher.windowMoved Watcher.windowResized])
          (tset runtime.resources.ui-watchers window-id watcher))))))

(fn stop-handle! [handle]
  (when handle (handle:stop)))

(fn detach-window! [runtime window-id]
  (let [observations runtime.resources.frame-observations]
    (stop-handle! (. runtime.resources.ui-watchers window-id))
    (stop-handle! (. runtime.resources.watcher-restart-timers window-id))
    (stop-handle! (. observations.timers window-id))
    (tset runtime.resources.ui-watchers window-id nil)
    (tset runtime.resources.watcher-restart-timers window-id nil)
    (tset observations.timers window-id nil)
    (tset observations.latest window-id nil)
    (tset observations.sequences window-id nil)
    (tset runtime.resources.windows window-id nil)))

(fn apply-membership! [runtime facts opts]
  "Plan and validate membership, then attach/detach handles and tile each
   touched Space once. opts.observed-spaces makes facts a snapshot of those
   Spaces; opts.anchor ({:window-id :frame}) anchors tiling where it applies.
   Returns the plan."
  (let [plan (plan-membership runtime.tiling-state facts
                              {:live? #(not= nil (resolve-window $1))
                               :observed-spaces opts.observed-spaces})]
    (commit-state! runtime plan.state)
    (each [_ window-id (ipairs plan.detach)] (detach-window! runtime window-id))
    (each [_ window-id (ipairs plan.attach)] (attach-window! runtime window-id))
    (each [_ space (ipairs plan.touched-spaces)]
      (when (. runtime.tiling-state.spaces space)
        (tile-space! runtime space opts.anchor)))
    plan))

(fn reconcile-window-fact! [runtime fact opts]
  "Reconcile one shared fact; stale runtime epochs are inert."
  (when (or (= nil opts.runtime-epoch) (= opts.runtime-epoch runtime.epoch))
    (apply-membership! runtime [fact] {}))
  runtime)

(fn reconcile-layout! [runtime window-facts observed-spaces]
  "Reconcile a snapshot of the observed Spaces and retain an inspectable report."
  (let [plan (apply-membership! runtime window-facts
                                {:observed-spaces (or observed-spaces [])})]
    (tset runtime :last-reconcile-report plan.report)
    (values runtime plan.report)))

(fn record-focus! [runtime fact]
  "Reconcile the focused window's fact (joins, Space moves), then record it as
   PaperWM's focus and tile its Space around the focused frame. Focusing an
   untracked window clears recorded focus. A fact without a Space ID is a
   transient lookup failure, not ineligibility, so it skips reconciliation."
  (let [anchor {:window-id fact.window-id :frame fact.frame}
        plan (if fact.space-id
                 (apply-membership! runtime [fact] {: anchor})
                 {:touched-spaces []})
        entry (. runtime.tiling-state.index fact.window-id)
        focused-id (when entry fact.window-id)]
    (when (not= focused-id runtime.tiling-state.focused-window-id)
      (commit-state! runtime (set-focused-window runtime.tiling-state focused-id)))
    (when (and entry (not (some #(= $ entry.space) plan.touched-spaces)))
      (tile-space! runtime entry.space anchor)))
  runtime)

(fn retile-observed-frame! [runtime params]
  "Retile around a frame observation only if it is the latest one for a live watcher."
  (let [entry (. runtime.tiling-state.index params.window-id)
        current? (= params.generation
                    (. runtime.resources.watcher-generations params.window-id))]
    (when (and entry current?
               (consume-latest runtime.resources.frame-observations
                               params.window-id params.generation params.sequence))
      (tile-space! runtime entry.space
                   {:window-id params.window-id :frame params.frame})))
  runtime)

(fn focused-window [runtime]
  "Return the recorded focused window's live handle and index entry."
  (let [window-id runtime.tiling-state.focused-window-id
        window (and window-id (. runtime.resources.windows window-id))
        entry (and window-id (. runtime.tiling-state.index window-id))]
    (when (and window entry (live-frame window)) (values window entry))))

(fn retile-around! [runtime focused entry frame]
  (tile-space! runtime entry.space {:window-id (focused:id) :frame frame}))

(fn focus-window! [runtime direction]
  "Focus the neighbor in direction and record it as PaperWM's intended focus,
   so a hotkey queued before the window/focused fact acts on the new window;
   that fact then confirms or corrects it."
  (let [focused (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [target-id (focus-target runtime.tiling-state (focused:id) direction)
          target (. runtime.resources.windows target-id)]
      (when target
        (target:focus)
        (commit-state! runtime (set-focused-window runtime.tiling-state target-id))))
    runtime))

(fn swap-windows! [runtime direction]
  (let [(focused entry) (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [next-state (layout-swap-window runtime.tiling-state (focused:id) direction)]
      (when (not= next-state runtime.tiling-state)
        (commit-state! runtime next-state)
        (retile-around! runtime focused entry (focused:frame))))
    runtime))

(fn center-window! [runtime]
  (let [(focused entry) (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [frame (focused:frame)
          screen-frame (: (focused:screen) :frame)]
      (set frame.x (- (+ screen-frame.x (math.floor (/ screen-frame.w 2)))
                      (math.floor (/ frame.w 2))))
      (retile-around! runtime focused entry frame))
    runtime))

(fn set-window-full-width! [runtime]
  (let [(focused entry) (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [canvas (get-canvas runtime (focused:screen))
          frame (focused:frame)]
      (set frame.x canvas.x)
      (set frame.w canvas.w)
      (retile-around! runtime focused entry frame))
    runtime))

(fn cycle-value [candidates current direction]
  (if (= direction :ascending)
      (or (some #(and (> $ (+ current 10)) $) candidates) (. candidates 1))
      (do
        (var result (. candidates (length candidates)))
        (for [index (length candidates) 1 -1]
          (when (< (. candidates index) (- current 10))
            (set result (. candidates index))
            (lua :break)))
        result)))

(fn cycle-window-size! [runtime dimension direction]
  (let [(focused entry) (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [canvas (get-canvas runtime (focused:screen))
          frame (focused:frame)
          sizes (icollect [_ ratio (ipairs runtime.config.window-ratios)]
                  (- (* ratio (+ (if (= dimension :width) canvas.w canvas.h)
                                 runtime.config.window-gap))
                     runtime.config.window-gap))]
      (if (= dimension :width)
          (let [size (cycle-value sizes frame.w direction)]
            (set frame.x (+ frame.x (math.floor (/ (- frame.w size) 2))))
            (set frame.w size))
          (let [size (cycle-value sizes frame.h direction)]
            (set frame.y (math.max canvas.y
                                   (+ frame.y (math.floor (/ (- frame.h size) 2)))))
            (set frame.h size)
            (set frame.y (- frame.y (math.max 0 (- frame.y2 canvas.y2))))))
      (retile-around! runtime focused entry frame))
    runtime))

(fn slurp-window! [runtime]
  (let [(focused entry) (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [next-state (layout-slurp-window runtime.tiling-state (focused:id))]
      (when (not= next-state runtime.tiling-state)
        (commit-state! runtime next-state)
        (retile-around! runtime focused entry (focused:frame))))
    runtime))

(fn barf-window! [runtime]
  (let [(focused entry) (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [next-state (layout-barf-window runtime.tiling-state (focused:id))]
      (when (not= next-state runtime.tiling-state)
        (commit-state! runtime next-state)
        (retile-around! runtime focused entry (focused:frame))))
    runtime))

(fn schedule-space-retry! [runtime generation]
  (stop-handle! runtime.resources.space-focus-timer)
  (tset runtime.resources :space-focus-timer
        (Timer.doAfter (math.max Window.animationDuration space-retry-min-delay)
                       (fn []
                         (tset runtime.resources :space-focus-timer nil)
                         (emit! runtime :paper-wm.events/space-focus-retry
                                {:generation generation})))))

(fn attempt-space-focus! [runtime operation]
  "Focus the target window, or for an empty-Space operation click the target
   screen's menu bar (upstream PaperWM's way to move focus onto that display).
   A window-targeted operation whose window vanished never clicks."
  (if operation.target-window-id
      (let [target (. runtime.resources.windows operation.target-window-id)]
        (when target (target:focus)))
      (let [screen (Screen (Spaces.spaceDisplay operation.target-space))]
        (when screen
          (let [point (screen:frame)]
            (set point.x (+ point.x (math.floor (/ point.w 2))))
            (set point.y (- point.y 4))
            (hs.eventtap.leftClick point))))))

(fn start-space-focus! [runtime index]
  (let [space (get-space index)]
    (when (= nil space) (lua "return runtime"))
    (let [screen (Screen (Spaces.spaceDisplay space))
          target (and screen
                      (get-first-visible-window runtime
                                                (. runtime.tiling-state.spaces space)
                                                screen))
          operation (start-space-operation runtime.resources.space-focus space
                                           (and target (target:id))
                                           (Timer.secondsSinceEpoch) 4)]
      (Spaces.gotoSpace space)
      (attempt-space-focus! runtime operation)
      (schedule-space-retry! runtime operation.generation)))
  runtime)

(fn retry-space-focus! [runtime generation]
  (let [operation runtime.resources.space-focus.active]
    (when (= nil operation) (lua "return runtime"))
    (let [target (. runtime.resources.windows operation.target-window-id)
          result (advance-space-operation
                  runtime.resources.space-focus generation
                  (Timer.secondsSinceEpoch)
                  (= (Spaces.focusedSpace) operation.target-space)
                  (or (= nil operation.target-window-id)
                      (= (Window.focusedWindow) target)))]
      ;; Re-act only on an unstable observation; a stable one is just counted.
      (if (= result.outcome :retry)
          (do
            (when (= 0 result.operation.stable-count)
              (attempt-space-focus! runtime result.operation))
            (schedule-space-retry! runtime generation))
          (= result.outcome :complete)
          (let [screen (Screen (Spaces.spaceDisplay result.operation.target-space))]
            (when screen
              (hs.mouse.absolutePosition
               (hs.geometry.rectMidPoint (screen:frame))))))))
  runtime)

(fn stop-runtime! [runtime]
  "Stop every resource owned by one PaperWM component state."
  (tset runtime :active? false)
  (each [_ watcher (pairs runtime.resources.ui-watchers)] (watcher:stop))
  (each [_ timer (pairs runtime.resources.watcher-restart-timers)] (timer:stop))
  (each [_ timer (pairs runtime.resources.frame-observations.timers)] (timer:stop))
  (when runtime.resources.space-focus-timer
    (runtime.resources.space-focus-timer:stop))
  (tset runtime.resources :windows {})
  (tset runtime.resources :ui-watchers {})
  (tset runtime.resources :watcher-restart-timers {})
  (tset runtime.resources.frame-observations :timers {})
  (tset runtime.resources :space-focus-timer nil))

{: default-config
 : make-runtime
 : stop-runtime!
 : diagnostic-snapshot
 : invariant-report
 : reconcile-layout!
 : reconcile-window-fact!
 : record-focus!
 : retile-observed-frame!
 : space-index-after-direction
 : start-space-focus!
 : retry-space-focus!
 : focus-window!
 : swap-windows!
 : center-window!
 : set-window-full-width!
 : cycle-window-size!
 : slurp-window!
 : barf-window!}
