
;; behaviors/desktop-layout.fnl
;; Reconciles consecutive desktop snapshots into created and destroyed spaces.

(local {: make-behavior} (require :sheaf.behavior-registry))


(fn space-id-set [all-spaces]
  (let [ids {}]
    (each [_ entry (ipairs (or all-spaces []))]
      (each [_ space-id (ipairs (. entry 2))]
        (tset ids space-id true)))
    ids))


(fn missing-spaces [ordered-layout other-ids]
  (let [missing []]
    (each [_ entry (ipairs (or ordered-layout []))]
      (let [screen-uuid (. entry 1)]
        (each [_ space-id (ipairs (. entry 2))]
          (when (= nil (. other-ids space-id))
            (table.insert missing {:space-id space-id
                                   :screen-uuid screen-uuid})))))
    missing))


(fn reconcile-spaces [previous current]
  (let [previous-ids (space-id-set previous)
        current-ids (space-id-set current)]
    {:destroyed (missing-spaces previous current-ids)
     :created (missing-spaces current previous-ids)}))


(local reconcile-spaces-behavior
  (make-behavior
   {:name :desktop-layout.behaviors/reconcile-spaces
    :description "Derive space creation and destruction from consecutive snapshots"
    :respond-to [:space-watcher.events/space-changed
                 :screen-watcher.events/screen-changed]
    :commands {:reconcile :desktop-layout.commands/reconcile-spaces}
    :inputs {:layout :shape/desktop-layout}
    :fn (fn [event candidates send-cmd inputs]
          (let [target (. candidates.reconcile 1)
                previous (?. inputs :layout :all-spaces)
                current (?. event :event-data :all-spaces)
                active (?. event :event-data :active-spaces)]
            (when (and target previous current active)
              (let [diff (reconcile-spaces previous current)]
                (send-cmd target :reconcile
                          {:all-spaces current
                           :active-spaces active
                           :destroyed diff.destroyed
                           :created diff.created})))))}))


{: reconcile-spaces-behavior}
