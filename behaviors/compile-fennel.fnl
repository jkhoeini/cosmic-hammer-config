
;; behaviors/compile-fennel.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :sheaf.behavior-registry))


(local compile-fennel-behavior
  (make-behavior
   {:name :compile-fennel.behaviors/compile-fennel
    :description "Watch fennel files in hammerspoon folder and recompile them."
    :respond-to [:event.kind.fs/file-change]
    :commands {:compile :compile-fennel.commands/compile}
    :fn (fn [file-change-event candidates send-cmd]
          (let [path (?. file-change-event :event-data :file-path)
                target (. candidates.compile 1)]
            (when (and target (not= nil path)
                       (= ".fnl" (path:sub -4)))
              (send-cmd target :compile {}))))}))


{: compile-fennel-behavior}
