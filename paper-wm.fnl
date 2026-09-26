;; ============================================================================
;; PaperWM - Scrollable horizontal tiling window manager
;; ============================================================================
;;
;; Inspired by PaperWM Gnome extension.
;; Port from https://github.com/mogenson/PaperWM.spoon
;;
;; Windows are arranged in a horizontal strip per Mission Control space.
;; Multiple windows can stack vertically into columns.

;; ---------------------------------------------------------------------------
;; Imports
;; ---------------------------------------------------------------------------

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
(local Window hs.window)
(local Screen hs.screen)
(local Spaces hs.spaces)
(local Timer hs.timer)
(local Watcher hs.uielement.watcher)
(local Rect hs.geometry.rect)

;; ---------------------------------------------------------------------------
;; Configuration
;; ---------------------------------------------------------------------------

(local default-config {:window-gap 35
                       :screen-margin 16
                       :window-ratios [0.421875 0.843750]})
(var config default-config)

(local logger (hs.logger.new :PaperWM))

;; ---------------------------------------------------------------------------
;; Constants
;; ---------------------------------------------------------------------------

(local Direction {:LEFT -1
                  :RIGHT 1
                  :UP -2
                  :DOWN 2
                  :WIDTH 3
                  :HEIGHT 4
                  :ASCENDING 5
                  :DESCENDING 6})

;; ---------------------------------------------------------------------------
;; State
;; ---------------------------------------------------------------------------
;;
;; Temporary module aliases point into the current runtime during the migration.
;; Layout tables contain window IDs; opaque handles live under resources.
(var window-list {})
(var index-table {})
(var windows {})
(var ui-watchers {})
(var focused-window-id nil)
(var watcher-restart-timers {})

(var next-runtime-epoch 0)

(var current-runtime nil)

(fn make-runtime [?config]
  "Create one owner for legacy PaperWM logical state and resources."
  (set next-runtime-epoch (+ next-runtime-epoch 1))
  (let [runtime-config {:window-gap (or (?. ?config :window-gap) default-config.window-gap)
                        :screen-margin (or (?. ?config :screen-margin) default-config.screen-margin)
                        :window-ratios (or (?. ?config :window-ratios)
                                           default-config.window-ratios)}]
    {:active? true
     :epoch next-runtime-epoch
     :config runtime-config
     :tiling-state (empty-state)
     :resources {:windows {}
                 :ui-watchers {}
                 :watcher-generations {}
                 :watcher-restart-timers {}
                 :frame-observations {:sequences {} :latest {} :timers {}}
                 :frame-source nil
                 :space-focus-timer nil}}))
(fn bind-runtime! [runtime]
  "Bind temporary compatibility aliases to an explicit runtime."
  (set current-runtime runtime)
  (set window-list runtime.tiling-state.spaces)
  (set index-table runtime.tiling-state.index)
  (set windows runtime.resources.windows)
  (set ui-watchers runtime.resources.ui-watchers)
  (set focused-window-id runtime.tiling-state.focused-window-id)
  (set watcher-restart-timers runtime.resources.watcher-restart-timers)
  (set config runtime.config)
  runtime)

(fn current-runtime-value []
  "Return the single currently bound PaperWM runtime."
  current-runtime)

(fn capture-runtime! [runtime]
  "Capture compatibility scalar aliases after a legacy action."
  (tset runtime.tiling-state :focused-window-id focused-window-id)
  runtime)

(fn commit-tiling-state! [next-state]
  "Validate and commit one copy-on-write logical transition."
  (let [(ok reason) (layout-valid? next-state)]
    (when (not ok)
      (error (.. "PaperWM layout invariant failed: " (tostring reason))))
    (tset current-runtime :tiling-state next-state)
    (set window-list next-state.spaces)
    (set index-table next-state.index)
    (set focused-window-id next-state.focused-window-id)
    next-state))

(fn run-with-runtime! [runtime action args]
  "Run one legacy action against injected component state."
  (bind-runtime! runtime)
  (action (table.unpack (or args [])))
  (capture-runtime! runtime))

(fn copy-table [source]
  "Copy a table recursively for read-only diagnostics."
  (let [result {}]
    (each [key value (pairs source)]
      (tset result key (if (= :table (type value))
                           (copy-table value)
                           value)))
    result))

(fn table-count [source]
  "Count entries in a table regardless of key type."
  (var count 0)
  (each [_ _ (pairs source)]
    (set count (+ count 1)))
  count)

(fn diagnostic-snapshot [?runtime]
  "Return logical PaperWM state and resource counts without mutable handles."
  (let [runtime (or ?runtime current-runtime)
        tiling-state (or (and runtime runtime.tiling-state) (empty-state))
        resources (or (and runtime runtime.resources) {})]
    {:active? (and runtime runtime.active?)
     :epoch (and runtime runtime.epoch)
     :window-list (copy-table tiling-state.spaces)
     :index-table (copy-table tiling-state.index)
     :focused-window-id tiling-state.focused-window-id
     :resources {:ui-watcher-count (table-count (or resources.ui-watchers {}))
                 :watcher-restart-timer-count
                 (table-count (or resources.watcher-restart-timers {}))
                 :space-focus-timer? (not= nil resources.space-focus-timer)}}))

(fn invariant-report [?runtime]
  "Return the current logical invariant status without resource handles."
  (let [runtime (or ?runtime current-runtime)
        (ok reason) (layout-valid? (or (and runtime runtime.tiling-state)
                                       (empty-state)))]
    {:ok? ok :reason reason :epoch (and runtime runtime.epoch)}))

;; ---------------------------------------------------------------------------
;; Internal helpers
;; ---------------------------------------------------------------------------

(fn get-space [index]
  "Get the Mission Control space ID for the provided 1-based index."
  (let [layout (Spaces.allSpaces)]
    (var idx index)
    (var result nil)
    (each [_ screen (ipairs (Screen.allScreens)) &until result]
      (let [screen-uuid (screen:getUUID)
            num-spaces (length (. layout screen-uuid))]
        (if (<= idx num-spaces)
            (set result (. layout screen-uuid idx))
            (set idx (- idx num-spaces)))))
    result))

(fn get-first-visible-window [columns screen]
  "Return the leftmost live window that's completely on the screen."
  (let [x (. (screen:frame) :x)]
    (var result nil)
    (each [_ window-ids (ipairs (or columns {})) &until result]
      (let [window (. windows (. window-ids 1))]
        (when (and window (>= (. (window:frame) :x) x))
          (set result window))))
    result))

(fn get-column [space col]
  "Resolve a column of window IDs to currently owned windows."
  (let [result []]
    (each [_ window-id (ipairs (. (or (. window-list space) {}) col))]
      (let [window (. windows window-id)]
        (when window (table.insert result window))))
    result))

(fn get-window [space col row]
  "Resolve the window ID at [space][col][row]."
  (let [window-id (. (or (. (or (. window-list space) {}) col) {}) row)]
    (. windows window-id)))

(fn get-canvas [screen]
  "Get the tileable bounds for a screen, inset by window-gap."
  (let [f (screen:frame)
        gap config.window-gap]
    (Rect (+ f.x gap) (+ f.y gap)
          (- f.w (* 2 gap)) (- f.h (* 2 gap)))))

;; ---------------------------------------------------------------------------
;; Tiling engine
;; ---------------------------------------------------------------------------

(fn move-window! [window frame]
  "Move and resize a window. Disables watchers during the move."
  (let [padding 0.02
        id (window:id)
        watcher (. ui-watchers id)]
    (when (not watcher)
      (logger.e "window does not have ui watcher")
      (lua "return"))
    (when (= frame (window:frame))
      (logger.v "no change in window frame")
      (lua "return"))
    ;; cancel pending restart from a previous move of this window
    (let [pending (. watcher-restart-timers id)]
      (when pending
        (pending:stop)))
    (watcher:stop)
    (window:setFrame frame)
    (tset watcher-restart-timers id
          (Timer.doAfter (+ Window.animationDuration padding)
                         (fn []
                           (tset watcher-restart-timers id nil)
                           ;; fetch fresh: watcher may have been torn down
                           (let [w (. ui-watchers id)]
                             (when w
                               (w:start [Watcher.windowMoved Watcher.windowResized]))))))))

(fn tile-column! [column-windows bounds h w id h4id]
  "Plan a column deterministically, apply its frames, and return width plus plan."
  (let [entries (icollect [_ window (ipairs column-windows)]
                  {:window-id (window:id) :frame (window:frame)})
        (plan column-width)
        (plan-column entries bounds
                     {:gap config.window-gap
                      :height h
                      :width w
                      :anchor-window-id id
                      :anchor-height h4id})]
    (each [_ intent (ipairs plan)]
      (let [window (. windows intent.window-id)]
        (when window (move-window! window intent.frame))))
    (values column-width plan)))

(fn tile-space! [space ?anchor-frame-override]
  "Tile all columns in a space by moving and resizing windows."
  (when (or (not space) (not= (Spaces.spaceType space) :user))
    (logger.e "current space invalid")
    (lua "return"))
  (let [screen (Screen (Spaces.spaceDisplay space))]
    (when (not screen)
      (logger.e "no screen for space")
      (lua "return"))
    (let [fw (Window.focusedWindow)
          anchor-window (if (and fw (= (. (Spaces.windowSpaces fw) 1) space))
                            fw
                            (get-first-visible-window (. window-list space) screen))]
      (when (not anchor-window)
        (logger.e "no anchor window in space")
        (lua "return"))
      (let [anchor-index (. index-table (anchor-window:id))]
        (when (not anchor-index)
          (logger.e "anchor index not found")
          (lua "return"))
        (let [screen-frame (screen:frame)
              left-margin (+ screen-frame.x config.screen-margin)
              right-margin (- screen-frame.x2 config.screen-margin)
              canvas (get-canvas screen)
              anchor-frame (or ?anchor-frame-override (anchor-window:frame))]
          (set anchor-frame.x (math.max anchor-frame.x canvas.x))
          (set anchor-frame.w (math.min anchor-frame.w canvas.w))
          (set anchor-frame.h (math.min anchor-frame.h canvas.h))
          (when (> anchor-frame.x2 canvas.x2)
            (set anchor-frame.x (- canvas.x2 anchor-frame.w)))
          (let [column (get-column space anchor-index.col)]
            (when (= 0 (length column))
              (logger.e "no anchor window column")
              (lua "return"))
            (if (= (length column) 1)
                (do
                  (set anchor-frame.y canvas.y)
                  (set anchor-frame.h canvas.h)
                  (move-window! anchor-window anchor-frame))
                (let [n (- (length column) 1)
                      h (math.floor (/ (math.max 0 (- canvas.h anchor-frame.h
                                                     (* n config.window-gap)))
                                       n))
                      bounds {:x anchor-frame.x :x2 nil
                              :y canvas.y :y2 canvas.y2}]
                  (tile-column! column bounds h anchor-frame.w
                                (anchor-window:id) anchor-frame.h)))
            (var x (math.min (+ anchor-frame.x2 config.window-gap) right-margin))
            (for [col (+ anchor-index.col 1) (length (or (. window-list space) {}))]
              (let [bounds {:x x :x2 nil :y canvas.y :y2 canvas.y2}
                    column-width (tile-column! (get-column space col) bounds)]
                (set x (math.min (+ x column-width config.window-gap) right-margin))))
            (var x2 (math.max (- anchor-frame.x config.window-gap) left-margin))
            (for [col (- anchor-index.col 1) 1 -1]
              (let [bounds {:x nil :x2 x2 :y canvas.y :y2 canvas.y2}
                    column-width (tile-column! (get-column space col) bounds)]
                (set x2 (math.max (- x2 column-width config.window-gap) left-margin))))))))))

(fn resolve-window [window-id]
  "Resolve one live window at the effect edge."
  (let [(ok window) (pcall Window.get window-id)]
    (and ok window)))

(fn reconcile-window-fact! [runtime fact opts]
  "Apply one shared membership fact and interpret ownership effects."
  (when (and opts.runtime-epoch (not= opts.runtime-epoch runtime.epoch))
    (lua "return runtime"))
  (bind-runtime! runtime)
  (let [window-id fact.window-id
        tracked? (not= nil (. runtime.tiling-state.index window-id))]
    (if (eligible? fact)
        (do
          (when (not tracked?)
            (commit-tiling-state!
             (layout-add-window runtime.tiling-state window-id fact.space-id
                                (+ (length (or (. runtime.tiling-state.spaces
                                                 fact.space-id) [])) 1))))
          (let [window (resolve-window window-id)]
            (when window
              (tset runtime.resources.windows window-id window)))
          (when (and (. runtime.resources.windows window-id)
                     (. runtime.tiling-state.index window-id))
            (tile-space! fact.space-id fact.frame)))
        tracked?
        (let [entry (. runtime.tiling-state.index window-id)
              watcher (. runtime.resources.ui-watchers window-id)]
          (when watcher (watcher:stop))
          (tset runtime.resources.ui-watchers window-id nil)
          (tset runtime.resources.windows window-id nil)
          (commit-tiling-state!
           (layout-remove-window runtime.tiling-state window-id))
          (when (. runtime.tiling-state.spaces entry.space)
            (tile-space! entry.space))))
    (capture-runtime! runtime)))

(fn initialize-layout! [runtime window-facts]
  "Initialize PaperWM idempotently from one shared snapshot occurrence."
  (each [_ fact (ipairs window-facts)]
    (reconcile-window-fact! runtime fact {:runtime-epoch runtime.epoch}))
  runtime)

;; ---------------------------------------------------------------------------
;; User actions
;; ---------------------------------------------------------------------------

(var focus-window nil)

(fn focus-space [space window]
  "Make the specified space the active space, focusing the given window."
  (let [screen (Screen (Spaces.spaceDisplay space))]
    (when (not screen) (lua "return"))
    (let [target-window (or window
                            (get-first-visible-window (. window-list space) screen))
          do-space-focus
          (coroutine.wrap
           (fn []
             (if target-window
                 (do
                   (fn check-focus [win n]
                     (var focused? true)
                     (for [_ 1 n]
                       (set focused? (and focused? (= (Window.focusedWindow) win)))
                       (when (not focused?) (lua "return false"))
                       (coroutine.yield false))
                     focused?)
                   (while true
                     (target-window:focus)
                     (coroutine.yield false)
                     (when (and (= (Spaces.focusedSpace) space)
                                (check-focus target-window 3))
                       (lua :break))))
                 (let [point (screen:frame)]
                   (set point.x (+ point.x (math.floor (/ point.w 2))))
                   (set point.y (- point.y 4))
                   (while true
                     (hs.eventtap.leftClick point)
                     (coroutine.yield false)
                     (when (= (Spaces.focusedSpace) space)
                       (lua :break)))))
             (hs.mouse.absolutePosition (hs.geometry.rectMidPoint (screen:frame)))
             true))
          start-time (Timer.secondsSinceEpoch)]
      (Timer.doUntil do-space-focus
                     (fn [timer]
                       (when (> (- (Timer.secondsSinceEpoch) start-time) 4)
                         (logger.ef "focusSpace() timeout! space %d focused space %d"
                                    space (Spaces.focusedSpace))
                         (timer:stop)))
                     Window.animationDuration))))

;; ---------------------------------------------------------------------------
;; User-facing commands
;; ---------------------------------------------------------------------------
;; These are the actions exposed to Sheaf command wrappers.
;; Each takes simple parameters and performs a complete tiling operation.

(set focus-window
  (fn [direction ?focused-index]
    "Move focus to an adjacent window. Returns the newly focused window or nil."
    (var focused-id focused-window-id)
    (when ?focused-index
      (set focused-id (. window-list ?focused-index.space
                         ?focused-index.col ?focused-index.row)))
    (when (not focused-id)
      (let [fw (Window.focusedWindow)]
        (set focused-id (and fw (fw:id)))))
    (when (not (. index-table focused-id))
      (logger.e "focused index not found")
      (lua "return"))
    (let [direction-key (if (= direction Direction.LEFT) :left
                            (= direction Direction.RIGHT) :right
                            (= direction Direction.UP) :up
                            (= direction Direction.DOWN) :down
                            nil)
          target-id (focus-target current-runtime.tiling-state
                                  focused-id direction-key)
          target-window (. windows target-id)]
      (when (not target-window)
        (logger.d "new focused window not found")
        (lua "return"))
      (target-window:focus)
      target-window)))

(fn swap-windows! [direction]
  "Swap the focused window with an adjacent window or column."
  (let [fw (Window.focusedWindow)]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (let [window-id (fw:id)
          fi (. index-table window-id)]
      (when (not fi)
        (logger.e "focused index not found")
        (lua "return"))
      (let [direction-key (if (= direction Direction.LEFT) :left
                              (= direction Direction.RIGHT) :right
                              (= direction Direction.UP) :up
                              (= direction Direction.DOWN) :down
                              nil)
            next-state (layout-swap-window current-runtime.tiling-state
                                           window-id direction-key)]
        (when (= next-state current-runtime.tiling-state)
          (logger.d "target window not found")
          (lua "return"))
        (commit-tiling-state! next-state)
        (tile-space! fi.space (fw:frame))))))

;; --- Window sizing ---

(fn center-window! []
  "Center the focused window horizontally on screen."
  (let [fw (Window.focusedWindow)]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (let [frame (fw:frame)
          sf (: (fw:screen) :frame)]
      (set frame.x (- (+ sf.x (math.floor (/ sf.w 2)))
                      (math.floor (/ frame.w 2))))
      (tile-space! (. (Spaces.windowSpaces fw) 1) frame))))

(fn set-window-full-width! []
  "Set the focused window to the full width of the screen."
  (let [fw (Window.focusedWindow)]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (let [canvas (get-canvas (fw:screen))
          frame (fw:frame)]
      (set frame.x canvas.x)
      (set frame.w canvas.w)
      (tile-space! (. (Spaces.windowSpaces fw) 1) frame))))

(fn cycle-window-size! [direction cycle-direction]
  "Cycle the width or height of the focused window through window-ratios."
  (let [fw (Window.focusedWindow)]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (fn find-new-size [area-size frame-size dir]
      (let [sizes (icollect [_ ratio (ipairs config.window-ratios)]
                    (- (* ratio (+ area-size config.window-gap))
                       config.window-gap))]
        (var new-size nil)
        (if (= dir Direction.ASCENDING)
            (do
              (set new-size (. sizes 1))
              (each [_ size (ipairs sizes)]
                (when (> size (+ frame-size 10))
                  (set new-size size)
                  (lua :break))))
            (= dir Direction.DESCENDING)
            (do
              (set new-size (. sizes (length sizes)))
              (for [i (length sizes) 1 -1]
                (when (< (. sizes i) (- frame-size 10))
                  (set new-size (. sizes i))
                  (lua :break))))
            (do
              (logger.e "invalid cycle direction")
              (lua "return")))
        new-size))
    (let [canvas (get-canvas (fw:screen))
          frame (fw:frame)]
      (if (= direction Direction.WIDTH)
          (let [new-width (find-new-size canvas.w frame.w cycle-direction)]
            (set frame.x (+ frame.x (math.floor (/ (- frame.w new-width) 2))))
            (set frame.w new-width))
          (= direction Direction.HEIGHT)
          (let [new-height (find-new-size canvas.h frame.h cycle-direction)]
            (set frame.y (math.max canvas.y
                                   (+ frame.y (math.floor (/ (- frame.h new-height) 2)))))
            (set frame.h new-height)
            (set frame.y (- frame.y (math.max 0 (- frame.y2 canvas.y2)))))
          (do
            (logger.e "invalid direction for cycle")
            (lua "return")))
      (tile-space! (. (Spaces.windowSpaces fw) 1) frame))))

;; --- Column manipulation ---

(fn slurp-window! []
  "Move focused window into the bottom of the column to its left."
  (let [fw (Window.focusedWindow)]
    (when (not fw) (lua "return"))
    (let [window-id (fw:id)
          fi (. index-table window-id)]
      (when (not fi) (lua "return"))
      (let [next-state (layout-slurp-window current-runtime.tiling-state window-id)]
        (when (= next-state current-runtime.tiling-state) (lua "return"))
        (commit-tiling-state! next-state)
        (tile-space! fi.space (fw:frame))))))

(fn barf-window! []
  "Remove focused window from its column into a new column on the right."
  (let [fw (Window.focusedWindow)]
    (when (not fw) (lua "return"))
    (let [window-id (fw:id)
          fi (. index-table window-id)]
      (when (not fi) (lua "return"))
      (let [next-state (layout-barf-window current-runtime.tiling-state window-id)]
        (when (= next-state current-runtime.tiling-state) (lua "return"))
        (commit-tiling-state! next-state)
        (tile-space! fi.space (fw:frame))))))

;; --- Space navigation ---

(fn switch-to-space! [index]
  "Switch to a Mission Control space by 1-based index."
  (let [space (get-space index)]
    (when (not space) (lua "return"))
    (Spaces.gotoSpace space)
    (focus-space space)))

(fn increment-space! [direction]
  "Switch to the next/previous Mission Control space."
  (when (and (not= direction Direction.LEFT) (not= direction Direction.RIGHT))
    (lua "return"))
  (let [curr-space-id (Spaces.focusedSpace)
        layout (Spaces.allSpaces)]
    (var curr-space-idx -1)
    (var num-spaces 0)
    (each [_ screen (ipairs (Screen.allScreens))]
      (let [screen-uuid (screen:getUUID)]
        (when (< curr-space-idx 0)
          (each [idx space-id (ipairs (. layout screen-uuid))]
            (when (= curr-space-id space-id)
              (set curr-space-idx (+ idx num-spaces))
              (lua :break))))
        (set num-spaces (+ num-spaces (length (. layout screen-uuid))))))
    (when (>= curr-space-idx 0)
      (let [new-idx (+ (% (+ (- curr-space-idx 1) direction) num-spaces) 1)]
        (switch-to-space! new-idx)))))

;; ---------------------------------------------------------------------------
;; Lifecycle
;; ---------------------------------------------------------------------------

(fn start! [?config]
  "Start automatic window tiling and return its explicit runtime."
  (when (not (Spaces.screensHaveSeparateSpaces))
    (logger.e "please check 'Displays have separate Spaces' in System Preferences -> Mission Control"))
  (bind-runtime! (make-runtime ?config)))

(fn stop! [?runtime]
  "Stop an explicit PaperWM runtime and release its current resources."
  (let [runtime (or ?runtime current-runtime)]
    (when runtime
      (tset runtime :active? false)
      (let [resources runtime.resources]
        (each [_ watcher (pairs resources.ui-watchers)] (watcher:stop))
        (each [_ timer (pairs resources.watcher-restart-timers)] (timer:stop))
        (when resources.space-focus-timer (resources.space-focus-timer:stop))
        (tset resources :windows {})
        (tset resources :ui-watchers {})
        (tset resources :watcher-restart-timers {})
        (tset resources :space-focus-timer nil)
        (when (= runtime current-runtime)
          (set windows resources.windows)
          (set ui-watchers resources.ui-watchers)
          (set watcher-restart-timers resources.watcher-restart-timers))))))

;; ---------------------------------------------------------------------------
;; Public API
;; ---------------------------------------------------------------------------

{: Direction
 : default-config
 :current-runtime current-runtime-value
 : start!
 : stop!
 : diagnostic-snapshot
 : invariant-report
 : run-with-runtime!
 ;; User-facing commands
 : initialize-layout!
 : reconcile-window-fact!
 : focus-window
 : swap-windows!
 : center-window!
 : set-window-full-width!
 : cycle-window-size!
 : slurp-window!
 : barf-window!
 : switch-to-space!
 : increment-space!}
