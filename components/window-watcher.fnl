
;; components/window-watcher.fnl
;; Component type: Global window watcher (owns window-watcher source)

(local {: make-component-type} (require :sheaf.component-registry))

(local window-watcher-type
  (make-component-type
   :component.type/window-watcher
   "Watches window focus, visibility, and fullscreen changes"
   {:sources [{:type :event-source.type/window-watcher
               :config {}
               :instance-name "default"
               :tags [:tag/window-watcher]}]
    :start-fn (fn [config] {})}))

{: window-watcher-type}
