
;; behaviors/update-space-indicator.fnl
;; Behavior: on space/screen change, compute active space indices and update menubar

(local {: make-behavior} (require :lib.behavior-registry))


(fn compute-active-space-indices [all-spaces active-spaces]
  "Compute ordered global space indices from event data.
   all-spaces: [[uuid [space-id ...]] ...] ordered by screen
   active-spaces: {uuid -> active-space-id}
   Returns: [3 6] (global indices across all screens)"
  (let [result []]
    (var offset 0)
    (each [_ entry (ipairs all-spaces)]
      (let [uuid (. entry 1)
            space-ids (. entry 2)
            active-sid (. active-spaces uuid)]
        (each [i sid (ipairs space-ids)]
          (when (= sid active-sid)
            (table.insert result (+ i offset))))
        (set offset (+ offset (length space-ids)))))
    result))


(local update-space-indicator-behavior
  (make-behavior
   {:name :space-indicator.behaviors/update-on-change
    :description "Update space indicator menubar when spaces or screens change"
    :respond-to [:event.kind.space/changed :event.kind.screen/any]
    :commands {:update-menubar :space-indicator.commands/update-menubar}
    :fn (fn [event cmd]
          (let [indices (compute-active-space-indices
                          event.event-data.all-spaces
                          event.event-data.active-spaces)]
            (cmd.update-menubar {:active-spaces indices})))}))


{: update-space-indicator-behavior}
