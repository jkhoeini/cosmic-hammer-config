;; behaviors/show-history.fnl
;; Behavior: show URL history browser on hotkey

(local {: make-behavior} (require :sheaf.behavior-registry))

(local show-history-behavior
  (make-behavior
   {:name :url-history.behaviors/show-history
    :description "Show URL history browser when hotkey is pressed"
    :respond-to [:event.kind.hotkey/pressed]
    :commands {:show-history :url-history.commands/show-history}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.show-history 1)]
            (when target
              (send-cmd target :show-history {}))))}))

{: show-history-behavior}
