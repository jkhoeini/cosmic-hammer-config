;; PaperWM effect interpreter over explicit component state.

(local {: empty-state
        :valid? layout-valid?
        :add-window layout-add-window
        :remove-window layout-remove-window
        :move-window layout-move-window
        :slurp-window layout-slurp-window
        :barf-window layout-barf-window
        :swap-window layout-swap-window
        : focus-target
        : set-focused-window} (require :paper-wm.layout))
(local {: eligible?} (require :paper-wm.eligibility))
(local {: plan-column} (require :paper-wm.frames))
(local {: observe!} (require :event_sources.paper-wm-frame-watcher))
(local {: consume-latest} (require :paper-wm.observations))
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
                       :window-ratios [0.421875 0.843750]})


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
              :window-ratios (or config.window-ratios default-config.window-ratios)}
     :tiling-state (empty-state)
     :resources {:windows {}
                 :ui-watchers {}
                 :watcher-generations {}
                 :watcher-restart-timers {}
                 :frame-observations {:sequences {} :latest {} :timers {}}
                 :frame-source nil
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
    (and ok window)))

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

(fn get-first-visible-window [runtime columns screen]
  (let [left-edge (. (screen:frame) :x)]
    (var result nil)
    (each [_ window-ids (ipairs (or columns {})) &until result]
      (let [window (. runtime.resources.windows (. window-ids 1))]
        (when (and window (>= (. (window:frame) :x) left-edge))
          (set result window))))
    result))

(fn get-column [runtime space column]
  (let [result []]
    (each [_ window-id (ipairs (. (or (. runtime.tiling-state.spaces space) {}) column))]
      (let [window (. runtime.resources.windows window-id)]
        (when window (table.insert result window))))
    result))

(fn get-canvas [runtime screen]
  (let [frame (screen:frame)
        gap runtime.config.window-gap]
    (Rect (+ frame.x gap) (+ frame.y gap)
          (- frame.w (* 2 gap)) (- frame.h (* 2 gap)))))

(fn move-window! [runtime window frame]
  (let [id (window:id)
        watcher (. runtime.resources.ui-watchers id)]
    (when (or (= nil watcher) (= frame (window:frame))) (lua "return"))
    (let [pending (. runtime.resources.watcher-restart-timers id)]
      (when pending (pending:stop)))
    (watcher:stop)
    (window:setFrame frame)
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
  (let [entries (icollect [_ window (ipairs column)]
                  {:window-id (window:id) :frame (window:frame)})
        (plan column-width)
        (plan-column entries bounds
                     {:gap runtime.config.window-gap
                      :height height
                      :width width
                      :anchor-window-id anchor-id
                      :anchor-height anchor-height})]
    (each [_ intent (ipairs plan)]
      (let [window (. runtime.resources.windows intent.window-id)]
        (when window (move-window! runtime window intent.frame))))
    column-width))

(fn tracked-window-on-space [runtime window-id space]
  (let [entry (and window-id (. runtime.tiling-state.index window-id))]
    (when (and entry (= entry.space space))
      (. runtime.resources.windows window-id))))

(fn copy-frame [frame]
  (Rect frame.x frame.y frame.w frame.h))

(fn resolve-anchor [runtime space screen ?anchor]
  "Return the anchor window and a private copy of the frame to tile around.
   An explicit {:window-id :frame} anchor wins only when that window is tracked
   on this Space; otherwise the tracked focused window, then the first visible."
  (let [explicit (and ?anchor
                      (tracked-window-on-space runtime ?anchor.window-id space))]
    (if explicit
        (values explicit (copy-frame ?anchor.frame))
        (let [focused (Window.focusedWindow)
              window (or (and focused
                              (tracked-window-on-space runtime (focused:id) space))
                         (get-first-visible-window
                          runtime (. runtime.tiling-state.spaces space) screen))]
          (when window
            (values window (copy-frame (window:frame))))))))

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
              (set x (math.min (+ x width runtime.config.window-gap) right-margin))))
          (var x2 (math.max (- frame.x runtime.config.window-gap) left-margin))
          (for [column-index (- anchor-index.col 1) 1 -1]
            (let [width (tile-column! runtime
                                      (get-column runtime space column-index)
                                      {:x nil :x2 x2 :y canvas.y :y2 canvas.y2})]
              (set x2 (math.max (- x2 width runtime.config.window-gap)
                                left-margin)))))))))

(fn attach-window! [runtime window-id]
  (let [window (resolve-window window-id)]
    (when window
      (tset runtime.resources.windows window-id window)
      (when (= nil (. runtime.resources.ui-watchers window-id))
        (let [generation (+ 1 (or (. runtime.resources.watcher-generations window-id) 0))
              watcher (window:newWatcher
                       (fn [observed-window event-kind]
                         (let [source runtime.resources.frame-source
                               (ok frame) (pcall #(: observed-window :frame))]
                           (when (and runtime.active? source ok)
                             (observe! source window-id (tostring event-kind)
                                       frame generation)))))]
          (tset runtime.resources.watcher-generations window-id generation)
          (watcher:start [Watcher.windowMoved Watcher.windowResized])
          (tset runtime.resources.ui-watchers window-id watcher))))))

(fn detach-window! [runtime window-id]
  (let [watcher (. runtime.resources.ui-watchers window-id)
        timer (. runtime.resources.watcher-restart-timers window-id)]
    (when watcher (watcher:stop))
    (when timer (timer:stop))
    (tset runtime.resources.ui-watchers window-id nil)
    (tset runtime.resources.watcher-restart-timers window-id nil)
    (tset runtime.resources.frame-observations.latest window-id nil)
    (tset runtime.resources.frame-observations.sequences window-id nil)
    (tset runtime.resources.windows window-id nil)))

(fn reconcile-window-fact! [runtime fact opts]
  "Reconcile one shared fact; stale runtime epochs are inert."
  (when (and opts.runtime-epoch (not= opts.runtime-epoch runtime.epoch))
    (lua "return runtime"))
  (let [window-id fact.window-id
        entry (. runtime.tiling-state.index window-id)
        tracked? (not= nil entry)]
    (if (eligible? fact)
        (do
          (if (not tracked?)
              (commit-state! runtime
                             (layout-add-window
                              runtime.tiling-state window-id fact.space-id
                              (+ 1 (length (or (. runtime.tiling-state.spaces
                                                 fact.space-id) [])))))
              (not= entry.space fact.space-id)
              (let [old-space entry.space]
                (commit-state! runtime
                               (layout-move-window
                                runtime.tiling-state window-id fact.space-id
                                (+ 1 (length (or (. runtime.tiling-state.spaces
                                                   fact.space-id) [])))))
                (when (. runtime.tiling-state.spaces old-space)
                  (tile-space! runtime old-space))))
          (attach-window! runtime window-id)
          (when (. runtime.resources.windows window-id)
            (tile-space! runtime fact.space-id)))
        tracked?
        (let [space (. runtime.tiling-state.index window-id :space)]
          (detach-window! runtime window-id)
          (commit-state! runtime
                         (layout-remove-window runtime.tiling-state window-id))
          (when (. runtime.tiling-state.spaces space)
            (tile-space! runtime space))))
    runtime))

(fn reconcile-layout! [runtime window-facts]
  "Reconcile an explicit snapshot and retain an inspectable report."
  (let [before (copy-table runtime.tiling-state.index)
        seen {}
        report {:added [] :removed [] :moved [] :rejected []}]
    (each [_ fact (ipairs window-facts)]
      (tset seen fact.window-id true)
      (let [prior (. before fact.window-id)]
        (if (eligible? fact)
            (do
              (when (= nil prior) (table.insert report.added fact.window-id))
              (when (and prior (not= prior.space fact.space-id))
                (table.insert report.moved fact.window-id)))
            (table.insert report.rejected fact.window-id)))
      (reconcile-window-fact! runtime fact {:runtime-epoch runtime.epoch}))
    (each [window-id _ (pairs before)]
      (when (= nil (. seen window-id))
        (let [space (. runtime.tiling-state.index window-id :space)]
          (detach-window! runtime window-id)
          (commit-state! runtime
                         (layout-remove-window runtime.tiling-state window-id))
          (table.insert report.removed window-id)
          (when (and space (. runtime.tiling-state.spaces space))
            (tile-space! runtime space)))))
    (tset runtime :last-reconcile-report report)
    (values runtime report)))

(fn record-focus! [runtime window-id space-id frame]
  (when (. runtime.tiling-state.index window-id)
    (commit-state! runtime
                   (set-focused-window runtime.tiling-state window-id))
    (when (. runtime.resources.windows window-id)
      (tile-space! runtime space-id {:window-id window-id :frame frame})))
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
  "Return the live focused window and its index entry when PaperWM tracks it."
  (let [focused (Window.focusedWindow)
        entry (and focused (. runtime.tiling-state.index (focused:id)))]
    (when entry (values focused entry))))

(fn retile-around! [runtime focused entry frame]
  (tile-space! runtime entry.space {:window-id (focused:id) :frame frame}))

(fn focus-window! [runtime direction]
  (let [focused (focused-window runtime)]
    (when (= nil focused) (lua "return runtime"))
    (let [target-id (focus-target runtime.tiling-state (focused:id) direction)
          target (. runtime.resources.windows target-id)]
      (when target (target:focus)))
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

(fn schedule-space-retry! [runtime generation emit-retry]
  (when runtime.resources.space-focus-timer
    (runtime.resources.space-focus-timer:stop))
  (tset runtime.resources :space-focus-timer
        (Timer.doAfter Window.animationDuration
                       (fn []
                         (tset runtime.resources :space-focus-timer nil)
                         (when runtime.active? (emit-retry generation))))))

(fn attempt-space-focus! [runtime operation]
  (let [target (. runtime.resources.windows operation.target-window-id)
        screen (Screen (Spaces.spaceDisplay operation.target-space))]
    (if target
        (target:focus)
        screen
        (let [point (screen:frame)]
          (set point.x (+ point.x (math.floor (/ point.w 2))))
          (set point.y (- point.y 4))
          (hs.eventtap.leftClick point)))))

(fn start-space-focus! [runtime index emit-retry]
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
      (schedule-space-retry! runtime operation.generation emit-retry)))
  runtime)

(fn retry-space-focus! [runtime generation emit-retry]
  (let [operation runtime.resources.space-focus.active]
    (when (= nil operation) (lua "return runtime"))
    (let [target (. runtime.resources.windows operation.target-window-id)
          result (advance-space-operation
                  runtime.resources.space-focus generation
                  (Timer.secondsSinceEpoch)
                  (= (Spaces.focusedSpace) operation.target-space)
                  (or (= nil operation.target-window-id)
                      (= (Window.focusedWindow) target)))]
      (if (= result.outcome :retry)
          (do
            (attempt-space-focus! runtime result.operation)
            (schedule-space-retry! runtime generation emit-retry))
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
