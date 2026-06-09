
;; behaviors/reload-hammerspoon.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :sheaf.behavior-registry))

(local reload-hammerspoon-behavior
  (make-behavior
   {:name :reload-hammerspoon.behaviors/reload-hammerspoon
    :description "When init.lua changes, reload hammerspoon."
    :respond-to [:event.kind.fs/file-change]
    :commands {:reload :reload-hammerspoon.commands/reload}
    :fn (fn [file-change-event candidates send-cmd]
          (let [path (?. file-change-event :event-data :file-path)
                target (. candidates.reload 1)]
            (when (and target (not= nil path)
                       (= "/init.lua" (path:sub -9)))
              (send-cmd target :reload {}))))}))

{: reload-hammerspoon-behavior}
