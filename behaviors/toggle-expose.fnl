
;; behaviors/toggle-expose.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :lib.behavior-registry))


(local toggle-expose-behavior
  (make-behavior
   :expose.behaviors/toggle-expose
   "Toggle the Hammerspoon Expose window picker"
   [:event.kind.hotkey/pressed]
   (fn [event send-cmd!]
     (send-cmd! :expose.commands/toggle-show {}))))


{: toggle-expose-behavior}
