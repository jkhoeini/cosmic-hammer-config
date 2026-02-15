
;; behaviors/reload-hammerspoon.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :sheaf.behavior-registry))
(local notify (require :notify))


(var reloading? false)
(local reload (hs.timer.delayed.new 0.5 hs.reload))


(local reload-hammerspoon-behavior
  (make-behavior
   {:name :reload-hammerspoon.behaviors/reload-hammerspoon
    :description "When init.lua changes, reload hammerspoon."
    :respond-to [:event.kind.fs/file-change]
    :fn (fn [file-change-event]
          (let [path (?. file-change-event :event-data :file-path)]
            (when (and (not reloading?)
                       (not= nil path)
                       (= ".hammerspoon/init.lua" (path:sub -21)))
              (set reloading? true)
              (notify.warn "Reloading...")
              (reload:start))))}))


{: reload-hammerspoon-behavior}
