
;; components/app-watcher.fnl
;; Component type: Global app lifecycle watcher (owns app-watcher source)

(local {: make-component-type} (require :sheaf.component-registry))

(local app-watcher-type
  (make-component-type
   :component.type/app-watcher
   "Watches application lifecycle events (launch, quit, activate, deactivate, hidden)"
   {:sources [{:type :event-source.type/app-watcher
               :config {}
               :instance-name "default"
               :tags [:tag/app-watcher]}]
    :start-fn (fn [config] {})}))

{: app-watcher-type}
