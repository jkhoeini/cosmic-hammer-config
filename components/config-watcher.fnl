
;; components/config-watcher.fnl
;; Component type: Config directory file watcher (owns file-watcher source)

(local {: make-component-type} (require :sheaf.component-registry))

(local config-watcher-type
  (make-component-type
   :component.type/config-watcher
   "Watches config directory for file changes"
   {:sources [{:type :event-source.type/file-watcher
               :config {:path hs.configdir}
               :instance-name "config-dir"
               :tags [:tag/config-watcher]}]
    :start-fn (fn [config] {})}))

{: config-watcher-type}
