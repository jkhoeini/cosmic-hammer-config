
;; event_sources/file-watcher.fnl
;; Event source type: watches a directory for file changes

(local {: mapv : assoc : string?} (require :lib.cljlib-shim))
(local {: make-source-type} (require :sheaf.source-registry))


(fn start-file-watcher [self emit]
  "Start watching the configured path for file changes.
   self: {:name instance-name :type type-name :config {:path string}}
   emit: (fn [event-name event-data]) - dispatches with source already set
   Returns the watcher object as state."
  (let [path self.config.path
        handler (fn [files attrs]
                  (let [evs (mapv #(assoc $1 :file-path $2) attrs files)]
                    (each [_ ev (ipairs evs)]
                      (emit :file-watcher.events/file-change ev))))
        watcher (hs.pathwatcher.new path handler)]
    (watcher:start)
    watcher))


(fn stop-file-watcher [state]
  "Stop the file watcher.
   state: the watcher object returned from start-file-watcher"
  (when state
    (state:stop)))


(local file-watcher-source-type
  (make-source-type
   :event-source.type/file-watcher
   "Watches a directory for file changes"
   {:config-schema {:path string?}
    :emits [:file-watcher.events/file-change]
    :start-fn start-file-watcher
    :stop-fn stop-file-watcher}))


{: file-watcher-source-type}
