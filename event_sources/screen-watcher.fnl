
;; event_sources/screen-watcher.fnl
;; Event source type: emits events on screen layout change

(local {: make-source-type} (require :lib.source-registry))


(fn snapshot-spaces []
  "Snapshot current space layout as ordered data.
   Returns: [[uuid [space-id ...]] ...] ordered by screen position."
  (let [spaces-layout (hs.spaces.allSpaces)]
    (icollect [_ screen (ipairs (hs.screen.allScreens))]
      (let [uuid (screen:getUUID)]
        [uuid (. spaces-layout uuid)]))))


(fn start-screen-watcher [self emit]
  "Start watching for screen layout changes.
   self: {:name instance-name :type type-name :config {}}
   emit: (fn [event-name event-data])
   Returns the watcher object as state."
  (let [handler (fn []
                  (emit :screen-watcher.events/screen-changed
                        {:all-spaces (snapshot-spaces)
                         :active-spaces (hs.spaces.activeSpaces)}))
        watcher (hs.screen.watcher.new handler)]
    (watcher:start)
    watcher))


(fn stop-screen-watcher [state]
  "Stop the screen watcher.
   state: the hs.screen.watcher object returned from start-screen-watcher"
  (when state
    (state:stop)))


(local screen-watcher-source-type
  (make-source-type
   :event-source.type/screen-watcher
   "Emits an event when the screen layout changes"
   {:config-schema {}
    :emits [:screen-watcher.events/screen-changed]
    :start-fn start-screen-watcher
    :stop-fn stop-screen-watcher}))


{: screen-watcher-source-type}
