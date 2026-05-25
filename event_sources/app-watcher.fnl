
;; event_sources/app-watcher.fnl
;; Event source type: emits events on application lifecycle changes

(local {: make-source-type} (require :sheaf.source-registry))

(local AppWatcher hs.application.watcher)


(fn make-event-data [appName appObject]
  "Build the event payload, guarding against nil appObject."
  {:app-name (or appName "")
   :bundle-id (if appObject (appObject:bundleID) "")
   :pid (if appObject (appObject:pid) 0)})


(fn start-app-watcher [self emit]
  "Start watching for application events.
   self: {:name instance-name :type type-name :config {}}
   emit: (fn [event-name event-data])
   Returns the watcher object as state."
  (let [handler (fn [appName eventType appObject]
                  (let [data (make-event-data appName appObject)]
                    (match eventType
                      AppWatcher.launched
                      (emit :app-watcher.events/launched data)
                      AppWatcher.terminated
                      (emit :app-watcher.events/terminated data)
                      AppWatcher.activated
                      (emit :app-watcher.events/activated data)
                      AppWatcher.deactivated
                      (emit :app-watcher.events/deactivated data)
                      AppWatcher.hidden
                      (emit :app-watcher.events/hidden data))))
        watcher (AppWatcher.new handler)]
    (watcher:start)
    watcher))


(fn stop-app-watcher [state]
  "Stop the application watcher.
   state: the hs.application.watcher object returned from start-app-watcher"
  (when state
    (state:stop)))


(local app-watcher-source-type
  (make-source-type
   :event-source.type/app-watcher
   "Emits events on application lifecycle changes"
   {:config-schema {}
    :emits [:app-watcher.events/launched
            :app-watcher.events/terminated
            :app-watcher.events/activated
            :app-watcher.events/deactivated
            :app-watcher.events/hidden]
    :start-fn start-app-watcher
    :stop-fn stop-app-watcher}))


{: app-watcher-source-type}
