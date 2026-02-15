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

(local Window hs.window)
(local Screen hs.screen)
(local Spaces hs.spaces)
(local Timer hs.timer)
(local Watcher hs.uielement.watcher)
(local WindowFilter hs.window.filter)
(local Rect hs.geometry.rect)

;; ---------------------------------------------------------------------------
;; Configuration
;; ---------------------------------------------------------------------------

;; These values can be overridden before calling start!
(var config {:window-gap 35
             :screen-margin 16
             :window-ratios [0.421875 0.843750]})

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
;; window-list: 3D table indexed by [space][column][row] -> window objects
;; index-table: window-id -> {:space <id> :col <n> :row <n>}
;; ui-watchers: window-id -> hs.uielement.watcher
;; window-filter: hs.window.filter instance (created on start!)
;; screen-watcher: hs.screen.watcher (created on start!)
;; hotkeys: list of hs.hotkey objects (for cleanup on stop!)

(var window-list {})
(var index-table {})
(var ui-watchers {})
(var focused-window nil)
(var pending-window nil)
(var window-filter nil)
(var screen-watcher nil)
(var hotkeys [])

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
  "Return the leftmost window that's completely on the screen."
  (let [x (. (screen:frame) :x)]
    (var result nil)
    (each [_ windows (ipairs (or columns {})) &until result]
      (let [window (. windows 1)]
        (when (>= (. (window:frame) :x) x)
          (set result window))))
    result))

(fn get-column [space col]
  "Get a column of windows for a space from window-list."
  (. (or (. window-list space) {}) col))

(fn get-window [space col row]
  "Get a window at [space][col][row] from window-list."
  (. (or (get-column space col) {}) row))

(fn get-canvas [screen]
  "Get the tileable bounds for a screen, inset by window-gap."
  (let [f (screen:frame)
        gap config.window-gap]
    (Rect (+ f.x gap) (+ f.y gap)
          (- f.w (* 2 gap)) (- f.h (* 2 gap)))))

(fn update-index-table! [space column]
  "Update index-table entries from the given column number upward."
  (let [columns (or (. window-list space) {})]
    (for [col column (length columns)]
      (each [row window (ipairs (get-column space col))]
        (tset index-table (window:id) {:space space :col col :row row})))))

;; ---------------------------------------------------------------------------
;; move-window!
;; ---------------------------------------------------------------------------

(fn move-window! [window frame]
  "Move and resize a window. Disables watchers during the move."
  (let [padding 0.02
        watcher (. ui-watchers (window:id))]
    (when (not watcher)
      (logger.e "window does not have ui watcher")
      (lua "return"))
    (when (= frame (window:frame))
      (logger.v "no change in window frame")
      (lua "return"))
    (watcher:stop)
    (window:setFrame frame)
    (Timer.doAfter (+ Window.animationDuration padding)
                   #(watcher:start [Watcher.windowMoved Watcher.windowResized]))))

;; ---------------------------------------------------------------------------
;; Tiling engine
;; ---------------------------------------------------------------------------

(fn tile-column! [windows bounds h w id h4id]
  "Tile a column of windows by moving and resizing.
   Returns the width of the tiled column."
  (var last-window nil)
  (var frame nil)
  (var col-width w)
  (each [_ window (ipairs windows)]
    (set frame (window:frame))
    (set col-width (or col-width frame.w))
    (if bounds.x (set frame.x bounds.x)
        bounds.x2 (set frame.x (- bounds.x2 col-width)))
    (when h
      (if (and id h4id (= (window:id) id))
          (set frame.h h4id)
          (set frame.h h)))
    (set frame.y bounds.y)
    (set frame.w col-width)
    (set frame.y2 (math.min frame.y2 bounds.y2))
    (move-window! window frame)
    (set bounds.y (math.min (+ frame.y2 config.window-gap) bounds.y2))
    (set last-window window))
  ;; expand last window height to bottom
  (when (and frame (not= frame.y2 bounds.y2))
    (set frame.y2 bounds.y2)
    (move-window! last-window frame))
  col-width)

(fn tile-space! [space]
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
              anchor-frame (anchor-window:frame)]
          ;; clamp anchor to canvas
          (set anchor-frame.x (math.max anchor-frame.x canvas.x))
          (set anchor-frame.w (math.min anchor-frame.w canvas.w))
          (set anchor-frame.h (math.min anchor-frame.h canvas.h))
          (when (> anchor-frame.x2 canvas.x2)
            (set anchor-frame.x (- canvas.x2 anchor-frame.w)))
          (let [column (get-column space anchor-index.col)]
            (when (not column)
              (logger.e "no anchor window column")
              (lua "return"))
            ;; tile anchor column
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
            ;; tile columns right of anchor
            (var x (math.min (+ anchor-frame.x2 config.window-gap) right-margin))
            (for [col (+ anchor-index.col 1) (length (or (. window-list space) {}))]
              (let [bounds {:x x :x2 nil :y canvas.y :y2 canvas.y2}
                    column-width (tile-column! (get-column space col) bounds)]
                (set x (math.min (+ x column-width config.window-gap) right-margin))))
            ;; tile columns left of anchor
            (var x2 (math.max (- anchor-frame.x config.window-gap) left-margin))
            (for [col (- anchor-index.col 1) 1 -1]
              (let [bounds {:x nil :x2 x2 :y canvas.y :y2 canvas.y2}
                    column-width (tile-column! (get-column space col) bounds)]
                (set x2 (math.max (- x2 column-width config.window-gap) left-margin))))))))))

;; ---------------------------------------------------------------------------
;; Event handling
;; ---------------------------------------------------------------------------

;; Forward declarations for mutual references
(var add-window! nil)
(var remove-window! nil)
(var focus-window nil)

(fn window-event-handler [window event]
  "Callback for window filter and uielement watcher events."
  (logger.df "%s for [%s] id: %d" event window
             (or (and window (window:id)) -1))
  (var space nil)
  (if (= event :windowFocused)
      (do
        (when (and pending-window (= window pending-window))
          (Timer.doAfter Window.animationDuration
                         (fn []
                           (logger.vf "pending window timer for %s" window)
                           (window-event-handler window event)))
          (lua "return"))
        (set focused-window window)
        (set space (. (Spaces.windowSpaces window) 1)))
      (or (= event :windowVisible) (= event :windowUnfullscreened))
      (do
        (set space (add-window! window))
        (if (and pending-window (= window pending-window))
            (set pending-window nil)
            (not space)
            (do
              (set pending-window window)
              (Timer.doAfter Window.animationDuration
                             #(window-event-handler window event))
              (lua "return"))))
      (= event :windowNotVisible)
      (set space (remove-window! window))
      (= event :windowFullscreened)
      (set space (remove-window! window true))
      (or (= event :AXWindowMoved) (= event :AXWindowResized))
      (set space (. (Spaces.windowSpaces window) 1)))
  (when space (tile-space! space)))

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
;; Window tracking
;; ---------------------------------------------------------------------------

(set add-window!
  (fn [add-win]
    "Add a new window to be tracked and automatically tiled.
     Returns the space containing the window, or nil."
    (when (> (add-win:tabCount) 0)
      (hs.notify.show :PaperWM "Windows with tabs are not supported!"
                      "See https://github.com/mogenson/PaperWM.spoon/issues/39")
      (lua "return"))
    (when (. index-table (add-win:id))
      (lua "return"))
    (let [space (. (Spaces.windowSpaces add-win) 1)]
      (when (not space)
        (logger.e "add window does not have a space")
        (lua "return"))
      (when (not (. window-list space))
        (tset window-list space {}))
      (var add-column 1)
      (if (and focused-window
               (= (. (or (. index-table (focused-window:id)) {}) :space) space)
               (not= (focused-window:id) (add-win:id)))
          (set add-column (+ (. index-table (focused-window:id) :col) 1))
          (let [x (. (add-win:frame) :center :x)]
            (each [col windows (ipairs (. window-list space))]
              (when (< x (. (: (. windows 1) :frame) :center :x))
                (set add-column col)
                (lua :break)))))
      (table.insert (. window-list space) add-column [add-win])
      (update-index-table! space add-column)
      ;; subscribe to window moved/resized events
      (let [watcher (add-win:newWatcher
                      (fn [window event]
                        (window-event-handler window event)))]
        (watcher:start [Watcher.windowMoved Watcher.windowResized])
        (tset ui-watchers (add-win:id) watcher))
      space)))

(set remove-window!
  (fn [remove-win ?skip-focus]
    "Remove a window from tracking. Returns the space it was in, or nil."
    (let [remove-index (. index-table (remove-win:id))]
      (when (not remove-index)
        (logger.e "remove index not found")
        (lua "return"))
      (when (not ?skip-focus)
        (let [fw (Window.focusedWindow)]
          (when (and fw (= (remove-win:id) (fw:id)))
            (each [_ direction (ipairs [Direction.DOWN Direction.UP
                                        Direction.LEFT Direction.RIGHT])]
              (when (focus-window direction remove-index)
                (lua :break))))))
      ;; remove from window-list
      (table.remove (. window-list remove-index.space remove-index.col)
                    remove-index.row)
      (when (= (length (. window-list remove-index.space remove-index.col)) 0)
        (table.remove (. window-list remove-index.space) remove-index.col))
      ;; remove watcher
      (: (. ui-watchers (remove-win:id)) :stop)
      (tset ui-watchers (remove-win:id) nil)
      ;; update index-table
      (tset index-table (remove-win:id) nil)
      (update-index-table! remove-index.space remove-index.col)
      ;; remove space if empty
      (when (= (length (. window-list remove-index.space)) 0)
        (tset window-list remove-index.space nil))
      remove-index.space)))

;; ---------------------------------------------------------------------------
;; Window navigation and manipulation
;; ---------------------------------------------------------------------------

(set focus-window
  (fn [direction ?focused-index]
    "Move focus to an adjacent window. Returns the newly focused window or nil."
    (var fi ?focused-index)
    (when (not fi)
      (let [fw (Window.focusedWindow)]
        (when (not fw)
          (logger.d "focused window not found")
          (lua "return"))
        (set fi (. index-table (fw:id)))))
    (when (not fi)
      (logger.e "focused index not found")
      (lua "return"))
    (var new-focused nil)
    (if (or (= direction Direction.LEFT) (= direction Direction.RIGHT))
        (for [row fi.row 1 -1]
          (set new-focused (get-window fi.space (+ fi.col direction) row))
          (when new-focused (lua :break)))
        (or (= direction Direction.UP) (= direction Direction.DOWN))
        (set new-focused (get-window fi.space fi.col
                                     (+ fi.row (math.floor (/ direction 2))))))
    (when (not new-focused)
      (logger.d "new focused window not found")
      (lua "return"))
    (new-focused:focus)
    new-focused))

(fn swap-windows! [direction]
  "Swap the focused window with an adjacent window or column."
  (let [fw (Window.focusedWindow)]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (let [fi (. index-table (fw:id))]
      (when (not fi)
        (logger.e "focused index not found")
        (lua "return"))
      (if (or (= direction Direction.LEFT) (= direction Direction.RIGHT))
          (let [target-col (+ fi.col direction)
                target-column (get-column fi.space target-col)]
            (when (not target-column)
              (logger.d "target column not found")
              (lua "return"))
            (let [focused-column (get-column fi.space fi.col)]
              ;; swap in window-list
              (tset (. window-list fi.space) target-col focused-column)
              (tset (. window-list fi.space) fi.col target-column)
              ;; update index-table
              (each [row window (ipairs target-column)]
                (tset index-table (window:id)
                      {:space fi.space :col fi.col :row row}))
              (each [row window (ipairs focused-column)]
                (tset index-table (window:id)
                      {:space fi.space :col target-col :row row}))
              ;; swap frames
              (let [focused-frame (fw:frame)
                    target-frame (: (. target-column 1) :frame)]
                (if (= direction Direction.LEFT)
                    (do
                      (set focused-frame.x target-frame.x)
                      (set target-frame.x (+ focused-frame.x2 config.window-gap)))
                    (do
                      (set target-frame.x focused-frame.x)
                      (set focused-frame.x (+ target-frame.x2 config.window-gap))))
                (each [_ window (ipairs target-column)]
                  (let [frame (window:frame)]
                    (set frame.x target-frame.x)
                    (move-window! window frame)))
                (each [_ window (ipairs focused-column)]
                  (let [frame (window:frame)]
                    (set frame.x focused-frame.x)
                    (move-window! window frame))))))
          (or (= direction Direction.UP) (= direction Direction.DOWN))
          (let [target-row (+ fi.row (math.floor (/ direction 2)))
                target-window (get-window fi.space fi.col target-row)]
            (when (not target-window)
              (logger.d "target window not found")
              (lua "return"))
            ;; swap in window-list
            (tset (. window-list fi.space fi.col) target-row fw)
            (tset (. window-list fi.space fi.col) fi.row target-window)
            ;; update index-table
            (let [target-index {:space fi.space :col fi.col :row target-row}]
              (tset index-table (target-window:id) fi)
              (tset index-table (fw:id) target-index))
            ;; swap frames
            (let [focused-frame (fw:frame)
                  target-frame (target-window:frame)]
              (if (= direction Direction.UP)
                  (do
                    (set focused-frame.y target-frame.y)
                    (set target-frame.y (+ focused-frame.y2 config.window-gap)))
                  (do
                    (set target-frame.y focused-frame.y)
                    (set focused-frame.y (+ target-frame.y2 config.window-gap))))
              (move-window! fw focused-frame)
              (move-window! target-window target-frame))))
      (tile-space! fi.space))))

;; ---------------------------------------------------------------------------
;; Single-window operations
;; ---------------------------------------------------------------------------

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
      (move-window! fw frame)
      (tile-space! (. (Spaces.windowSpaces fw) 1)))))

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
      (move-window! fw frame)
      (tile-space! (. (Spaces.windowSpaces fw) 1)))))

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
      (move-window! fw frame)
      (tile-space! (. (Spaces.windowSpaces fw) 1)))))

(fn slurp-window! []
  "Move focused window into the bottom of the column to its left."
  (let [fw (Window.focusedWindow)]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (let [fi (. index-table (fw:id))]
      (when (not fi)
        (logger.e "focused index not found")
        (lua "return"))
      (let [column (get-column fi.space (- fi.col 1))]
        (when (not column)
          (logger.d "column not found")
          (lua "return"))
        ;; remove from current column
        (table.remove (. window-list fi.space fi.col) fi.row)
        (when (= (length (. window-list fi.space fi.col)) 0)
          (table.remove (. window-list fi.space) fi.col))
        ;; append to left column
        (table.insert column fw)
        (let [num-windows (length column)]
          (tset index-table (fw:id)
                {:space fi.space :col (- fi.col 1) :row num-windows})
          (update-index-table! fi.space fi.col)
          ;; retile the column
          (let [canvas (get-canvas (fw:screen))
                bounds {:x (. (: (. column 1) :frame) :x) :x2 nil
                        :y canvas.y :y2 canvas.y2}
                h (math.floor (/ (math.max 0 (- canvas.h
                                                (* (- num-windows 1) config.window-gap)))
                                 num-windows))]
            (tile-column! column bounds h)
            (tile-space! fi.space)))))))

(fn barf-window! []
  "Remove focused window from its column and place into a new column to the right."
  (let [fw (Window.focusedWindow)]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (let [fi (. index-table (fw:id))]
      (when (not fi)
        (logger.e "focused index not found")
        (lua "return"))
      (let [column (get-column fi.space fi.col)]
        (when (= (length column) 1)
          (logger.d "only window in column")
          (lua "return"))
        ;; remove and insert as new column
        (table.remove column fi.row)
        (table.insert (. window-list fi.space) (+ fi.col 1) [fw])
        (update-index-table! fi.space fi.col)
        ;; retile
        (let [num-windows (length column)
              canvas (get-canvas (fw:screen))
              frame (fw:frame)
              bounds {:x frame.x :x2 nil :y canvas.y :y2 canvas.y2}
              h (math.floor (/ (math.max 0 (- canvas.h
                                              (* (- num-windows 1) config.window-gap)))
                               num-windows))]
          (set frame.y canvas.y)
          (set frame.x (+ frame.x2 config.window-gap))
          (set frame.h canvas.h)
          (move-window! fw frame)
          (tile-column! column bounds h)
          (tile-space! fi.space))))))

;; ---------------------------------------------------------------------------
;; Space management
;; ---------------------------------------------------------------------------

(fn switch-to-space! [index]
  "Switch to a Mission Control space by 1-based index."
  (let [space (get-space index)]
    (when (not space)
      (logger.d "space not found")
      (lua "return"))
    (Spaces.gotoSpace space)
    (focus-space space)))

(fn increment-space! [direction]
  "Switch to the next/previous Mission Control space."
  (when (and (not= direction Direction.LEFT) (not= direction Direction.RIGHT))
    (logger.d "move is invalid, left and right only")
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

(fn move-window-to-space! [index ?window]
  "Move a window to a Mission Control space by 1-based index."
  (let [fw (or ?window (Window.focusedWindow))]
    (when (not fw)
      (logger.d "focused window not found")
      (lua "return"))
    (let [fi (. index-table (fw:id))]
      (when (not fi)
        (logger.e "focused index not found")
        (lua "return"))
      (let [new-space (get-space index)]
        (when (not new-space)
          (logger.d "space not found")
          (lua "return"))
        (when (= new-space (. (Spaces.windowSpaces fw) 1))
          (logger.d "window already on space")
          (lua "return"))
        (when (not= (Spaces.spaceType new-space) :user)
          (logger.d "space is invalid")
          (lua "return"))
        (let [screen (Screen (Spaces.spaceDisplay new-space))]
          (when (not screen)
            (logger.d "no screen for space")
            (lua "return"))
          (let [old-space (remove-window! fw true)]
            (when (not old-space)
              (logger.e "can't remove focused window")
              (lua "return"))
            ;; macOS 14.5+ requires mouse drag hack
            (let [version (hs.host.operatingSystemVersion)]
              (if (>= (+ (* version.major 100) version.minor) 1405)
                  (let [start-point (fw:frame)
                        end-point (screen:frame)]
                    (set start-point.x (+ start-point.x (math.floor (/ start-point.w 2))))
                    (set start-point.y (+ start-point.y 4))
                    (set end-point.x (+ end-point.x (math.floor (/ end-point.w 2))))
                    (set end-point.y (+ end-point.y config.window-gap 4))
                    (let [do-window-drag
                          (coroutine.wrap
                           (fn []
                             (set start-point.x
                                  (+ start-point.x
                                     (math.floor (/ (- end-point.x start-point.x) 2))))
                             (set start-point.y
                                  (+ start-point.y
                                     (math.floor (/ (- end-point.y start-point.y) 2))))
                             (: (hs.eventtap.event.newMouseEvent
                                  hs.eventtap.event.types.leftMouseDragged start-point)
                                :post)
                             (coroutine.yield false)
                             (: (hs.eventtap.event.newMouseEvent
                                  hs.eventtap.event.types.leftMouseUp end-point)
                                :post)
                             (while true
                               (coroutine.yield false)
                               (when (= (. (Spaces.windowSpaces fw) 1) new-space)
                                 (lua :break)))
                             (add-window! fw)
                             (tile-space! old-space)
                             (tile-space! new-space)
                             (focus-space new-space fw)
                             true))
                          start-time (Timer.secondsSinceEpoch)]
                      (: (hs.eventtap.event.newMouseEvent
                           hs.eventtap.event.types.leftMouseDown start-point)
                         :post)
                      (Spaces.gotoSpace new-space)
                      (Timer.doUntil do-window-drag
                                     (fn [timer]
                                       (when (> (- (Timer.secondsSinceEpoch) start-time) 4)
                                         (logger.ef
                                          "moveWindowToSpace() timeout! new %d curr %d win %d"
                                          new-space
                                          (Spaces.activeSpaceOnScreen (screen:id))
                                          (. (Spaces.windowSpaces fw) 1))
                                         (timer:stop)))
                                     Window.animationDuration)))
                  (do
                    (Spaces.moveWindowToSpace fw new-space)
                    (add-window! fw)
                    (tile-space! old-space)
                    (tile-space! new-space)
                    (Spaces.gotoSpace new-space)
                    (focus-space new-space fw))))))))))

;; ---------------------------------------------------------------------------
;; Refresh
;; ---------------------------------------------------------------------------

(fn refresh-windows! []
  "Get all windows across all spaces and retile them."
  (let [all-windows (window-filter:getWindows)
        retile-spaces {}]
    (each [_ window (ipairs all-windows)]
      (let [index (. index-table (window:id))]
        (if (not index)
            (let [space (add-window! window)]
              (when space (tset retile-spaces space true)))
            (not= index.space (. (Spaces.windowSpaces window) 1))
            (do
              (remove-window! window)
              (let [space (add-window! window)]
                (when space (tset retile-spaces space true)))))))
    (each [space _ (pairs retile-spaces)]
      (tile-space! space))))

;; ---------------------------------------------------------------------------
;; Hotkey bindings
;; ---------------------------------------------------------------------------

(fn bind-hotkeys! []
  "Bind all PaperWM hotkeys. Stores references in `hotkeys` for cleanup."
  (let [bind (fn [mods key action]
               (table.insert hotkeys (hs.hotkey.bind mods key action)))]
    ;; Focus navigation
    (bind [:alt :cmd] :left  #(focus-window Direction.LEFT))
    (bind [:alt :cmd] :right #(focus-window Direction.RIGHT))
    (bind [:alt :cmd] :up    #(focus-window Direction.UP))
    (bind [:alt :cmd] :down  #(focus-window Direction.DOWN))
    ;; Swap windows
    (bind [:alt :cmd :shift] :left  #(swap-windows! Direction.LEFT))
    (bind [:alt :cmd :shift] :right #(swap-windows! Direction.RIGHT))
    (bind [:alt :cmd :shift] :up    #(swap-windows! Direction.UP))
    (bind [:alt :cmd :shift] :down  #(swap-windows! Direction.DOWN))
    ;; Window sizing
    (bind [:alt :cmd] :c #(center-window!))
    (bind [:alt :cmd] :f #(set-window-full-width!))
    (bind [:alt :cmd] :r #(cycle-window-size! Direction.WIDTH Direction.ASCENDING))
    (bind [:alt :cmd :shift] :r #(cycle-window-size! Direction.HEIGHT Direction.ASCENDING))
    (bind [:ctrl :alt :cmd] :r #(cycle-window-size! Direction.WIDTH Direction.DESCENDING))
    (bind [:ctrl :alt :cmd :shift] :r #(cycle-window-size! Direction.HEIGHT Direction.DESCENDING))
    ;; Slurp / Barf
    (bind [:alt :cmd] :i #(slurp-window!))
    (bind [:alt :cmd] :o #(barf-window!))
    ;; Space switching
    (bind [:alt :cmd] "," #(increment-space! Direction.LEFT))
    (bind [:alt :cmd] "." #(increment-space! Direction.RIGHT))
    (for [i 1 9]
      (bind [:alt :cmd] (tostring i) #(switch-to-space! i)))
    ;; Move window to space
    (for [i 1 9]
      (bind [:alt :cmd :shift] (tostring i) #(move-window-to-space! i)))
    ;; Stop
    (bind [:alt :cmd :shift] :q #(stop!))))

;; ---------------------------------------------------------------------------
;; Lifecycle
;; ---------------------------------------------------------------------------

(fn start! []
  "Start automatic window tiling."
  (when (not (Spaces.screensHaveSeparateSpaces))
    (logger.e "please check 'Displays have separate Spaces' in System Preferences -> Mission Control"))
  ;; clear state
  (set window-list {})
  (set index-table {})
  (set ui-watchers {})
  ;; create window filter
  (set window-filter
       (: (WindowFilter.new) :setOverrideFilter
          {:visible true
           :fullscreen false
           :hasTitlebar true
           :allowRoles :AXStandardWindow}))
  ;; populate and tile
  (refresh-windows!)
  ;; listen for window events
  (window-filter:subscribe
   [WindowFilter.windowFocused
    WindowFilter.windowVisible
    WindowFilter.windowNotVisible
    WindowFilter.windowFullscreened
    WindowFilter.windowUnfullscreened]
   (fn [window _ event]
     (window-event-handler window event)))
  ;; watch for screen changes
  (set screen-watcher
       (Screen.watcher.new #(refresh-windows!)))
  (screen-watcher:start)
  ;; bind hotkeys
  (bind-hotkeys!))

(fn stop! []
  "Stop automatic window tiling and release all resources."
  (when window-filter
    (window-filter:unsubscribeAll))
  (each [_ watcher (pairs ui-watchers)]
    (watcher:stop))
  (when screen-watcher
    (screen-watcher:stop))
  ;; unbind hotkeys
  (each [_ hk (ipairs hotkeys)]
    (hk:delete))
  (set hotkeys []))

;; ---------------------------------------------------------------------------
;; Public API
;; ---------------------------------------------------------------------------

{: start!
 : stop!
 : refresh-windows!
 : config}
