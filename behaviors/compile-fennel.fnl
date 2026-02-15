
;; behaviors/compile-fennel.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :sheaf.behavior-registry))


(local compile-fennel-behavior
  (make-behavior
   {:name :compile-fennel.behaviors/compile-fennel
    :description "Watch fennel files in hammerspoon folder and recompile them."
    :respond-to [:event.kind.fs/file-change]
    :fn (fn [file-change-event]
          (let [path (?. file-change-event :event-data :file-path)]
            (when (and (not= nil path)
                       (= ".fnl" (path:sub -4)))
              (print (hs.execute "./compile.sh" true)))))}))


{: compile-fennel-behavior}
