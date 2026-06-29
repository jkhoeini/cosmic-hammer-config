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

;; ============================================================================
;; Focus navigation
;; ============================================================================

(local focus-left-command
  (make-command
   :paper-wm.commands/focus-left
   "Focus the window to the left"
   {:fn (fn [component params]
          (focus-window Direction.LEFT)
          nil)}))

(local focus-right-command
  (make-command
   :paper-wm.commands/focus-right
   "Focus the window to the right"
   {:fn (fn [component params]
          (focus-window Direction.RIGHT)
          nil)}))

(local focus-up-command
  (make-command
   :paper-wm.commands/focus-up
   "Focus the window above"
   {:fn (fn [component params]
          (focus-window Direction.UP)
          nil)}))

(local focus-down-command
  (make-command
   :paper-wm.commands/focus-down
   "Focus the window below"
   {:fn (fn [component params]
          (focus-window Direction.DOWN)
          nil)}))

;; ============================================================================
;; Swap
;; ============================================================================

(local swap-left-command
  (make-command
   :paper-wm.commands/swap-left
   "Swap the focused window with the one to the left"
   {:fn (fn [component params]
          (swap-windows! Direction.LEFT)
          nil)}))

(local swap-right-command
  (make-command
   :paper-wm.commands/swap-right
   "Swap the focused window with the one to the right"
   {:fn (fn [component params]
          (swap-windows! Direction.RIGHT)
          nil)}))

(local swap-up-command
  (make-command
   :paper-wm.commands/swap-up
   "Swap the focused window with the one above"
   {:fn (fn [component params]
          (swap-windows! Direction.UP)
          nil)}))

(local swap-down-command
  (make-command
   :paper-wm.commands/swap-down
   "Swap the focused window with the one below"
   {:fn (fn [component params]
          (swap-windows! Direction.DOWN)
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

(local cycle-width-up-command
  (make-command
   :paper-wm.commands/cycle-width-up
   "Cycle the focused window width up"
   {:fn (fn [component params]
          (cycle-window-size! Direction.WIDTH Direction.ASCENDING)
          nil)}))

(local cycle-width-down-command
  (make-command
   :paper-wm.commands/cycle-width-down
   "Cycle the focused window width down"
   {:fn (fn [component params]
          (cycle-window-size! Direction.WIDTH Direction.DESCENDING)
          nil)}))

(local cycle-height-up-command
  (make-command
   :paper-wm.commands/cycle-height-up
   "Cycle the focused window height up"
   {:fn (fn [component params]
          (cycle-window-size! Direction.HEIGHT Direction.ASCENDING)
          nil)}))

(local cycle-height-down-command
  (make-command
   :paper-wm.commands/cycle-height-down
   "Cycle the focused window height down"
   {:fn (fn [component params]
          (cycle-window-size! Direction.HEIGHT Direction.DESCENDING)
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
   {:fn (fn [component params]
          (switch-to-space! params.index)
          nil)}))

(local prev-space-command
  (make-command
   :paper-wm.commands/prev-space
   "Switch to the previous space"
   {:fn (fn [component params]
          (increment-space! Direction.LEFT)
          nil)}))

(local next-space-command
  (make-command
   :paper-wm.commands/next-space
   "Switch to the next space"
   {:fn (fn [component params]
          (increment-space! Direction.RIGHT)
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

;; ============================================================================
;; Pending window state
;; ============================================================================

(local set-pending-window-command
  (make-command
   :paper-wm.commands/set-pending-window
   "Set the pending window ID during space transitions"
   {:fn (fn [component params]
          {:pending-window-id params.window-id})}))

(local clear-pending-window-command
  (make-command
   :paper-wm.commands/clear-pending-window
   "Clear the pending window ID"
   {:fn (fn [component params]
          {:pending-window-id nil})}))

{: focus-left-command
 : focus-right-command
 : focus-up-command
 : focus-down-command
 : swap-left-command
 : swap-right-command
 : swap-up-command
 : swap-down-command
 : center-window-command
 : set-full-width-command
 : cycle-width-up-command
 : cycle-width-down-command
 : cycle-height-up-command
 : cycle-height-down-command
 : slurp-window-command
 : barf-window-command
 : switch-to-space-command
 : prev-space-command
 : next-space-command
 : refresh-windows-command
 : set-pending-window-command
 : clear-pending-window-command}
