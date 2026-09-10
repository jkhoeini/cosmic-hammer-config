
;; components/desktop-layout.fnl
;; Component type: tracks the current ordered spaces grouped by screen.

(local {: make-component-type} (require :sheaf.component-registry))
(local {: snapshot-desktop} (require :event_sources.desktop-snapshot))


(local desktop-layout-type
  (make-component-type
   :component.type/desktop-layout
   "Tracks the current ordered spaces grouped by screen"
   {:traits [:trait/has-desktop-layout]
    :sources [{:type :event-source.type/space-watcher
               :config {}
               :instance-name "default"
               :tags [:tag/space-watcher]}
              {:type :event-source.type/screen-watcher
               :config {}
               :instance-name "default"
               :tags [:tag/screen-watcher]}]
    :start-fn (fn [config]
                (let [snapshot (snapshot-desktop)]
                  {:all-spaces snapshot.all-spaces}))}))


{: desktop-layout-type}
