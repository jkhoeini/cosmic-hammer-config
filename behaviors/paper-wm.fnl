
;; behaviors/paper-wm.fnl
;; Behaviors: wire PaperWM hotkey events to commands
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :sheaf.behavior-registry))

;; ============================================================================
;; Helper
;; ============================================================================

(fn make-hotkey-behavior [name description cmd-alias cmd-name]
  "Create a simple hotkey-pressed behavior that picks the first candidate."
  (make-behavior
   {:name name
    :description description
    :respond-to [:event.kind.hotkey/pressed]
    :commands {cmd-alias cmd-name}
    :fn (fn [event candidates send-cmd]
          (let [target (. (. candidates cmd-alias) 1)]
            (when target
              (send-cmd target cmd-alias {}))))}))

;; ============================================================================
;; Focus navigation
;; ============================================================================

(local focus-left-behavior
  (make-hotkey-behavior :paper-wm.behaviors/focus-left
                        "Focus window to the left"
                        :focus-left :paper-wm.commands/focus-left))

(local focus-right-behavior
  (make-hotkey-behavior :paper-wm.behaviors/focus-right
                        "Focus window to the right"
                        :focus-right :paper-wm.commands/focus-right))

(local focus-up-behavior
  (make-hotkey-behavior :paper-wm.behaviors/focus-up
                        "Focus window above"
                        :focus-up :paper-wm.commands/focus-up))

(local focus-down-behavior
  (make-hotkey-behavior :paper-wm.behaviors/focus-down
                        "Focus window below"
                        :focus-down :paper-wm.commands/focus-down))

;; ============================================================================
;; Swap
;; ============================================================================

(local swap-left-behavior
  (make-hotkey-behavior :paper-wm.behaviors/swap-left
                        "Swap focused window left"
                        :swap-left :paper-wm.commands/swap-left))

(local swap-right-behavior
  (make-hotkey-behavior :paper-wm.behaviors/swap-right
                        "Swap focused window right"
                        :swap-right :paper-wm.commands/swap-right))

(local swap-up-behavior
  (make-hotkey-behavior :paper-wm.behaviors/swap-up
                        "Swap focused window up"
                        :swap-up :paper-wm.commands/swap-up))

(local swap-down-behavior
  (make-hotkey-behavior :paper-wm.behaviors/swap-down
                        "Swap focused window down"
                        :swap-down :paper-wm.commands/swap-down))

;; ============================================================================
;; Window sizing
;; ============================================================================

(local center-window-behavior
  (make-hotkey-behavior :paper-wm.behaviors/center-window
                        "Center focused window on screen"
                        :center-window :paper-wm.commands/center-window))

(local set-full-width-behavior
  (make-hotkey-behavior :paper-wm.behaviors/set-full-width
                        "Set focused window to full width"
                        :set-full-width :paper-wm.commands/set-full-width))

(local cycle-width-up-behavior
  (make-hotkey-behavior :paper-wm.behaviors/cycle-width-up
                        "Cycle focused window width up"
                        :cycle-width-up :paper-wm.commands/cycle-width-up))

(local cycle-width-down-behavior
  (make-hotkey-behavior :paper-wm.behaviors/cycle-width-down
                        "Cycle focused window width down"
                        :cycle-width-down :paper-wm.commands/cycle-width-down))

(local cycle-height-up-behavior
  (make-hotkey-behavior :paper-wm.behaviors/cycle-height-up
                        "Cycle focused window height up"
                        :cycle-height-up :paper-wm.commands/cycle-height-up))

(local cycle-height-down-behavior
  (make-hotkey-behavior :paper-wm.behaviors/cycle-height-down
                        "Cycle focused window height down"
                        :cycle-height-down :paper-wm.commands/cycle-height-down))

;; ============================================================================
;; Column manipulation
;; ============================================================================

(local slurp-window-behavior
  (make-hotkey-behavior :paper-wm.behaviors/slurp-window
                        "Slurp window into left column"
                        :slurp-window :paper-wm.commands/slurp-window))

(local barf-window-behavior
  (make-hotkey-behavior :paper-wm.behaviors/barf-window
                        "Barf window out of column"
                        :barf-window :paper-wm.commands/barf-window))

;; ============================================================================
;; Space navigation
;; ============================================================================

(local prev-space-behavior
  (make-hotkey-behavior :paper-wm.behaviors/prev-space
                        "Switch to previous space"
                        :prev-space :paper-wm.commands/prev-space))

(local next-space-behavior
  (make-hotkey-behavior :paper-wm.behaviors/next-space
                        "Switch to next space"
                        :next-space :paper-wm.commands/next-space))

;; ============================================================================
;; Switch-to-space (9, generated in a loop)
;; ============================================================================

(local switch-to-space-behaviors {})
(for [i 1 9]
  (tset switch-to-space-behaviors i
    (make-behavior
     {:name (.. :paper-wm.behaviors/switch-to-space- (tostring i))
      :description (.. "Switch to space " (tostring i))
      :respond-to [:event.kind.hotkey/pressed]
      :commands {:switch-to-space :paper-wm.commands/switch-to-space}
      :fn (fn [event candidates send-cmd]
            (let [target (. candidates.switch-to-space 1)]
              (when target
                (send-cmd target :switch-to-space {:index i}))))})))

{: focus-left-behavior
 : focus-right-behavior
 : focus-up-behavior
 : focus-down-behavior
 : swap-left-behavior
 : swap-right-behavior
 : swap-up-behavior
 : swap-down-behavior
 : center-window-behavior
 : set-full-width-behavior
 : cycle-width-up-behavior
 : cycle-width-down-behavior
 : cycle-height-up-behavior
 : cycle-height-down-behavior
 : slurp-window-behavior
 : barf-window-behavior
 : prev-space-behavior
 : next-space-behavior
 : switch-to-space-behaviors}
