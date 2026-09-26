;; commands/paper-wm.fnl
;; Commands: Sheaf wrappers for paper-wm user-facing functions

(local {: make-command} (require :sheaf.command-registry))
(local {: dispatch-event!} (require :sheaf.event-registry))
(local {: event-registry} (require :events))
(local {: initialize-layout!
        : reconcile-layout!
        : reconcile-window-fact!
        : record-focus!
        : retile-observed-frame!
        : start-space-focus!
        : retry-space-focus!
        : space-index-after-direction
        : focus-window!
        : swap-windows!
        : center-window!
        : set-window-full-width!
        : cycle-window-size!
        : slurp-window!
        : barf-window!} (require :paper-wm))

(local initialize-layout-command
  (make-command
   :paper-wm.commands/initialize-layout
   "Initialize PaperWM membership from a shared window snapshot"
   {:requires-traits [:trait/has-paper-wm-runtime :trait/has-tiling-state]
    :schema {:windows table?}
    :fn (fn [component params]
          (reconcile-layout! component.state params.windows)
          component.state)}))

(local reconcile-window-command
  (make-command
   :paper-wm.commands/reconcile-window
   "Reconcile one shared window fact into PaperWM membership"
   {:requires-traits [:trait/has-paper-wm-runtime :trait/has-tiling-state]
    :schema {:window table?}
    :fn (fn [component params]
          (reconcile-window-fact! component.state params.window
                                  {:runtime-epoch params.runtime-epoch}))}))

(local record-focus-command
  (make-command
   :paper-wm.commands/record-focus
   "Record shared focus after membership is coherent"
   {:requires-traits [:trait/has-paper-wm-runtime :trait/has-tiling-state]
    :schema {:window-id number? :space-id number? :frame table?}
    :fn (fn [component params]
          (record-focus! component.state params.window-id
                         params.space-id params.frame))}))

(local retile-observed-frame-command
  (make-command
   :paper-wm.commands/retile-observed-frame
   "Retile from the latest coalesced manual frame"
   {:requires-traits [:trait/has-paper-wm-runtime :trait/has-tiling-state]
    :schema {:window-id number? :frame table? :generation number? :sequence number?}
    :fn (fn [component params]
          (retile-observed-frame! component.state params))}))


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
          (focus-window! component.state params.direction))}))

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
          (swap-windows! component.state params.direction))}))

;; ============================================================================
;; Window sizing
;; ============================================================================

(local center-window-command
  (make-command
   :paper-wm.commands/center-window
   "Center the focused window on screen"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (center-window! component.state))}))

(local set-full-width-command
  (make-command
   :paper-wm.commands/set-full-width
   "Set the focused window to full screen width"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (set-window-full-width! component.state))}))

(local cycle-window-size-command
  (make-command
   :paper-wm.commands/cycle-window-size
   "Cycle the focused window size"
   {:schema {:direction #(or (= $1 :width) (= $1 :height))
             :cycle-direction #(or (= $1 :ascending) (= $1 :descending))}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (cycle-window-size! component.state params.direction
                              params.cycle-direction))}))

;; ============================================================================
;; Column manipulation
;; ============================================================================

(local slurp-window-command
  (make-command
   :paper-wm.commands/slurp-window
   "Slurp a window into the current column"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (slurp-window! component.state))}))

(local barf-window-command
  (make-command
   :paper-wm.commands/barf-window
   "Barf a window out of the current column"
   {:requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (barf-window! component.state))}))

;; ============================================================================
;; Space navigation
;; ============================================================================

(fn emit-space-retry [component-name]
  (fn [generation]
    (dispatch-event! event-registry :paper-wm.events/space-focus-retry
                     component-name {:generation generation})))

(local switch-to-space-command
  (make-command
   :paper-wm.commands/switch-to-space
   "Start a Space focus conversation for an absolute index"
   {:schema {:index #(and (= :number (type $1)) (<= 1 $1 9))}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (start-space-focus! component.state params.index
                              (emit-space-retry component.name)))}))

(local increment-space-command
  (make-command
   :paper-wm.commands/increment-space
   "Start a Space focus conversation for a relative direction"
   {:schema {:direction #(or (= $1 :left) (= $1 :right))}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (let [index (space-index-after-direction params.direction)]
            (if index
                (start-space-focus! component.state index
                                    (emit-space-retry component.name))
                component.state)))}))

(local retry-space-focus-command
  (make-command
   :paper-wm.commands/retry-space-focus
   "Advance a generation-scoped Space focus conversation"
   {:schema {:generation number?}
    :requires-traits [:trait/has-paper-wm-runtime]
    :fn (fn [component params]
          (retry-space-focus! component.state params.generation
                              (emit-space-retry component.name)))}))

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
          (reconcile-layout! component.state params.windows)
          component.state)}))


{: initialize-layout-command
 : reconcile-window-command
 : record-focus-command
 : retile-observed-frame-command
 : retry-space-focus-command
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
