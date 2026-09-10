
;; event_sources/space-watcher.fnl
;; Event source type: emits events on space/desktop change

(local {: make-source-type} (require :sheaf.source-registry))
(local {: snapshot-desktop} (require :event_sources.desktop-snapshot))


(fn start-space-watcher [self emit]
  "Start watching for space changes.
   self: {:name instance-name :type type-name :config {}}
   emit: (fn [event-name event-data])
   Returns the watcher object as state."
  (let [handler (fn [space-number]
                  (let [snapshot (snapshot-desktop)]
                    (emit :space-watcher.events/space-changed
                          {:space-number space-number
                           :all-spaces snapshot.all-spaces
                           :active-spaces snapshot.active-spaces
                           :screens snapshot.screens})))
        watcher (hs.spaces.watcher.new handler)]
    (watcher:start)
    watcher))


(fn stop-space-watcher [state]
  "Stop the space watcher.
   state: the hs.spaces.watcher object returned from start-space-watcher"
  (when state
    (state:stop)))


(local space-watcher-source-type
  (make-source-type
   :event-source.type/space-watcher
   "Emits an event when the active space/desktop changes"
   {:config-schema {}
    :emits [:space-watcher.events/space-changed]
    :start-fn start-space-watcher
    :stop-fn stop-space-watcher}))


{: space-watcher-source-type}
