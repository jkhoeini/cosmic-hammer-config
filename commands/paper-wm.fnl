;; commands/paper-wm.fnl
;; Commands: Sheaf wrappers for paper-wm user-facing functions

(local {: make-command} (require :sheaf.command-registry))
(local {: Direction
        : focus-window
        : swap-windows!
        : center-window!
        : set-window-full-width!
        : cycle-window-size!
        : slurp-window!
        : barf-window!
        : switch-to-space!
        : increment-space!
        : refresh-windows!} (require :paper-wm))

(local direction-by-keyword
  {:left Direction.LEFT
   :right Direction.RIGHT
   :up Direction.UP
   :down Direction.DOWN
   :width Direction.WIDTH
   :height Direction.HEIGHT
   :ascending Direction.ASCENDING
   :descending Direction.DESCENDING})

;; ============================================================================
;; Focus navigation
;; ============================================================================

(local focus-command
  (make-command
   :paper-wm.commands/focus
   "Focus the window in a direction"
   {:schema {:direction #(or (= $1 :left) (= $1 :right)
                            (= $1 :up) (= $1 :down))}
    :fn (fn [component params]
          (focus-window (. direction-by-keyword params.direction))
          nil)}))

;; ============================================================================
;; Swap
;; ============================================================================

(local swap-command
  (make-command
   :paper-wm.commands/swap
   "Swap the focused window in a direction"
   {:schema {:direction #(or (= $1 :left) (= $1 :right)
                            (= $1 :up) (= $1 :down))}
    :fn (fn [component params]
          (swap-windows! (. direction-by-keyword params.direction))
          nil)}))

;; ============================================================================
;; Window sizing
;; ============================================================================

(local center-window-command
  (make-command
   :paper-wm.commands/center-window
   "Center the focused window on screen"
   {:fn (fn [component params]
          (center-window!)
          nil)}))

(local set-full-width-command
  (make-command
   :paper-wm.commands/set-full-width
   "Set the focused window to full screen width"
   {:fn (fn [component params]
          (set-window-full-width!)
          nil)}))

(local cycle-window-size-command
  (make-command
   :paper-wm.commands/cycle-window-size
   "Cycle the focused window size"
   {:schema {:direction #(or (= $1 :width) (= $1 :height))
             :cycle-direction #(or (= $1 :ascending) (= $1 :descending))}
    :fn (fn [component params]
          (cycle-window-size! (. direction-by-keyword params.direction)
                              (. direction-by-keyword params.cycle-direction))
          nil)}))

;; ============================================================================
;; Column manipulation
;; ============================================================================

(local slurp-window-command
  (make-command
   :paper-wm.commands/slurp-window
   "Slurp a window into the current column"
   {:fn (fn [component params]
          (slurp-window!)
          nil)}))

(local barf-window-command
  (make-command
   :paper-wm.commands/barf-window
   "Barf a window out of the current column"
   {:fn (fn [component params]
          (barf-window!)
          nil)}))

;; ============================================================================
;; Space navigation
;; ============================================================================

(local switch-to-space-command
  (make-command
   :paper-wm.commands/switch-to-space
   "Switch to a specific space by index"
   {:schema {:index #(and (= :number (type $1)) (<= 1 $1 9))}
    :fn (fn [component params]
          (switch-to-space! params.index)
          nil)}))

(local increment-space-command
  (make-command
   :paper-wm.commands/increment-space
   "Switch to an adjacent space"
   {:schema {:direction #(or (= $1 :left) (= $1 :right))}
    :fn (fn [component params]
          (increment-space! (. direction-by-keyword params.direction))
          nil)}))

;; ============================================================================
;; Refresh
;; ============================================================================

(local refresh-windows-command
  (make-command
   :paper-wm.commands/refresh-windows
   "Refresh and re-tile all windows"
   {:fn (fn [component params]
          (refresh-windows!)
          nil)}))


{: focus-command
 : swap-command
 : center-window-command
 : set-full-width-command
 : cycle-window-size-command
 : slurp-window-command
 : barf-window-command
 : switch-to-space-command
 : increment-space-command
 : refresh-windows-command}
