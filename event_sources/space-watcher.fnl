
;; event_sources/space-watcher.fnl
;; Event source type: emits events on space/desktop change

(local {: make-source-type} (require :lib.source-registry))


(fn snapshot-spaces []
  "Snapshot current space layout as ordered data.
   Returns: [[uuid [space-id ...]] ...] ordered by screen position."
  (let [spaces-layout (hs.spaces.allSpaces)]
    (icollect [_ screen (ipairs (hs.screen.allScreens))]
      (let [uuid (screen:getUUID)]
        [uuid (. spaces-layout uuid)]))))


(fn start-space-watcher [self emit]
  "Start watching for space changes.
   self: {:name instance-name :type type-name :config {}}
   emit: (fn [event-name event-data])
   Returns the watcher object as state."
  (let [handler (fn [space-number]
                  (emit :space-watcher.events/space-changed
                        {:space-number space-number
                         :all-spaces (snapshot-spaces)
                         :active-spaces (hs.spaces.activeSpaces)}))
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
