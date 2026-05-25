
;; behaviors/toggle-expose.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :sheaf.behavior-registry))


(local toggle-expose-behavior
  (make-behavior
   {:name :expose.behaviors/toggle-expose
    :description "Toggle the Hammerspoon Expose window picker"
    :respond-to [:event.kind.hotkey/pressed]
    :commands {:toggle-show :expose.commands/toggle-show}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.toggle-show 1)]
            (when target
              (send-cmd target :toggle-show {}))))}))


{: toggle-expose-behavior}
