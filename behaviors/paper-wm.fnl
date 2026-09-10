
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
    :fn (fn [event candidates send-cmd inputs params]
          (let [target (. (. candidates cmd-alias) 1)]
            (when target
              (send-cmd target cmd-alias (or params {})))))}))

;; ============================================================================
;; Focus navigation
;; ============================================================================

(local focus-behavior
  (make-hotkey-behavior :paper-wm.behaviors/focus
                        "Focus window in a direction"
                        :focus :paper-wm.commands/focus))

;; ============================================================================
;; Swap
;; ============================================================================

(local swap-behavior
  (make-hotkey-behavior :paper-wm.behaviors/swap
                        "Swap focused window in a direction"
                        :swap :paper-wm.commands/swap))

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

(local cycle-window-size-behavior
  (make-hotkey-behavior :paper-wm.behaviors/cycle-window-size
                        "Cycle focused window size"
                        :cycle-window-size :paper-wm.commands/cycle-window-size))

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

(local increment-space-behavior
  (make-hotkey-behavior :paper-wm.behaviors/increment-space
                        "Switch to an adjacent space"
                        :increment-space :paper-wm.commands/increment-space))

;; ============================================================================
;; Switch-to-space
;; ============================================================================

(local switch-to-space-behavior
  (make-behavior
   {:name :paper-wm.behaviors/switch-to-space
    :description "Switch to a specific space"
    :respond-to [:event.kind.hotkey/pressed]
    :commands {:switch-to-space :paper-wm.commands/switch-to-space}
    :fn (fn [event candidates send-cmd inputs params]
          (let [target (. candidates.switch-to-space 1)]
            (when target
              (send-cmd target :switch-to-space {:index params.index}))))}))

;; ============================================================================
;; Screen change
;; ============================================================================

(local refresh-on-screen-change-behavior
  (make-behavior
   {:name :paper-wm.behaviors/refresh-on-screen-change
    :description "Refresh PaperWM windows when screen layout changes"
    :respond-to [:event.kind.screen/layout-changed]
    :commands {:refresh-windows :paper-wm.commands/refresh-windows}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.refresh-windows 1)]
            (when target
              (send-cmd target :refresh-windows {}))))}))

(local refresh-on-window-placed-behavior
  (make-behavior
   {:name :paper-wm.behaviors/refresh-on-window-placed
    :description "Refresh PaperWM after cross-screen window placement"
    :respond-to [:event.kind.window/placed]
    :commands {:refresh-windows :paper-wm.commands/refresh-windows}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.refresh-windows 1)]
            (when target
              (send-cmd target :refresh-windows {}))))}))

{: focus-behavior
 : swap-behavior
 : center-window-behavior
 : set-full-width-behavior
 : cycle-window-size-behavior
 : slurp-window-behavior
 : barf-window-behavior
 : increment-space-behavior
 : switch-to-space-behavior
 : refresh-on-screen-change-behavior
 : refresh-on-window-placed-behavior}
