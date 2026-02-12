
;; behaviors/toggle-expose.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :lib.behavior-registry))
(local {: invoke-command!} (require :lib.command-registry))
(local {: command-registry} (require :commands))


(local toggle-expose-behavior
  (make-behavior
   :expose.behaviors/toggle-expose
   "Toggle the Hammerspoon Expose window picker"
   [:event.kind.hotkey/pressed]
   (fn [event]
     (invoke-command! command-registry :expose.commands/toggle-show {}))))


{: toggle-expose-behavior}
