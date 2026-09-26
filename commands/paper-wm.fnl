;; commands/paper-wm.fnl
;; Commands: Sheaf wrappers for paper-wm user-facing functions

(local {: make-command} (require :sheaf.command-registry))
(local {: Direction
        : initialize-layout!
        : reconcile-window-fact!
        : run-with-runtime!
        : focus-window
        : swap-windows!
        : center-window!
        : set-window-full-width!
        : cycle-window-size!
        : slurp-window!
        : barf-window!
        : switch-to-space!
        : increment-space!} (require :paper-wm))

(local initialize-layout-command
  (make-command
   :paper-wm.commands/initialize-layout
   "Initialize PaperWM membership from a shared window snapshot"
   {:requires-traits [:trait/has-paper-wm-runtime :trait/has-tiling-state]
    :schema {:windows table?}
    :fn (fn [component params]
          (initialize-layout! component.state params.windows))}))

(local reconcile-window-command
  (make-command
   :paper-wm.commands/reconcile-window
   "Reconcile one shared window fact into PaperWM membership"
   {:requires-traits [:trait/has-paper-wm-runtime :trait/has-tiling-state]
    :schema {:window table?}
    :fn (fn [component params]
          (reconcile-window-fact! component.state params.window
                                  {:runtime-epoch params.runtime-epoch}))}))

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
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state focus-window
                             [(. direction-by-keyword params.direction)]))}))

;; ============================================================================
;; Swap
;; ============================================================================

(local swap-command
  (make-command
   :paper-wm.commands/swap
   "Swap the focused window in a direction"
   {:schema {:direction #(or (= $1 :left) (= $1 :right)
                            (= $1 :up) (= $1 :down))}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state swap-windows!
                             [(. direction-by-keyword params.direction)]))}))

;; ============================================================================
;; Window sizing
;; ============================================================================

(local center-window-command
  (make-command
   :paper-wm.commands/center-window
   "Center the focused window on screen"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state center-window!))}))

(local set-full-width-command
  (make-command
   :paper-wm.commands/set-full-width
   "Set the focused window to full screen width"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state set-window-full-width!))}))

(local cycle-window-size-command
  (make-command
   :paper-wm.commands/cycle-window-size
   "Cycle the focused window size"
   {:schema {:direction #(or (= $1 :width) (= $1 :height))
             :cycle-direction #(or (= $1 :ascending) (= $1 :descending))}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state cycle-window-size!
                             [(. direction-by-keyword params.direction)
                              (. direction-by-keyword params.cycle-direction)]))}))

;; ============================================================================
;; Column manipulation
;; ============================================================================

(local slurp-window-command
  (make-command
   :paper-wm.commands/slurp-window
   "Slurp a window into the current column"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state slurp-window!))}))

(local barf-window-command
  (make-command
   :paper-wm.commands/barf-window
   "Barf a window out of the current column"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state barf-window!))}))

;; ============================================================================
;; Space navigation
;; ============================================================================

(local switch-to-space-command
  (make-command
   :paper-wm.commands/switch-to-space
   "Switch to a specific space by index"
   {:schema {:index #(and (= :number (type $1)) (<= 1 $1 9))}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state switch-to-space! [params.index]))}))

(local increment-space-command
  (make-command
   :paper-wm.commands/increment-space
   "Switch to an adjacent space"
   {:schema {:direction #(or (= $1 :left) (= $1 :right))}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (run-with-runtime! component.state increment-space!
                             [(. direction-by-keyword params.direction)]))}))

;; ============================================================================
;; Refresh
;; ============================================================================

(local refresh-windows-command
  (make-command
   :paper-wm.commands/refresh-windows
   "Reconcile PaperWM from an explicit window snapshot"
   {:requires-traits [:trait/has-paper-wm-runtime :trait/has-tiling-state]
    :schema {:windows table?}
    :fn (fn [component params]
          (initialize-layout! component.state params.windows))}))


{: initialize-layout-command
 : reconcile-window-command
 : focus-command
 : swap-command
 : center-window-command
 : set-full-width-command
 : cycle-window-size-command
 : slurp-window-command
 : barf-window-command
 : switch-to-space-command
 : increment-space-command
 : refresh-windows-command}
