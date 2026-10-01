
;; event_sources/window-watcher.fnl
;; Event source type: emits events on window focus, visibility, and fullscreen changes

(local {: make-source-type} (require :sheaf.source-registry))
(local {: snapshot-window : snapshot-observed-windows} (require :lib.window-facts))

(local WindowFilter hs.window.filter)


(fn make-event-data [window appName]
  "Build guarded event data from an hs.window object."
  (let [data (snapshot-window window)]
    (when (and data (= nil data.app-name))
      (tset data :app-name appName))
    data))


(fn start-window-watcher [self emit]
  "Start watching for window events via hs.window.filter.
   self: {:name instance-name :type type-name :config {}}
   emit: (fn [event-name event-data])
   Returns the filter object as state."
  (let [wf (: (WindowFilter.new) :setOverrideFilter
              {:allowRoles [:AXUnknown :AXStandardWindow :AXDialog :AXSystemDialog]})
        handler (fn [window appName event]
                  (when window
                    (let [data (make-event-data window appName)]
                      (when data
                        (match event
                          WindowFilter.windowFocused
                          (emit :window-watcher.events/focused data)
                          WindowFilter.windowVisible
                          (emit :window-watcher.events/visible data)
                          WindowFilter.windowNotVisible
                          (emit :window-watcher.events/not-visible data)
                          WindowFilter.windowFullscreened
                          (emit :window-watcher.events/fullscreened data)
                          WindowFilter.windowUnfullscreened
                          (emit :window-watcher.events/unfullscreened data)
                          WindowFilter.windowMoved
                          (emit :window-watcher.events/moved data)
                          WindowFilter.windowCreated
                          (emit :window-watcher.events/created data)
                          WindowFilter.windowDestroyed
                          (emit :window-watcher.events/destroyed data)
                          WindowFilter.windowMinimized
                          (emit :window-watcher.events/minimized data)
                          WindowFilter.windowUnminimized
                          (emit :window-watcher.events/deminimized data)
                          WindowFilter.windowTitleChanged
                          (emit :window-watcher.events/title-changed data))))))]
    (wf:subscribe
     [WindowFilter.windowFocused
      WindowFilter.windowVisible
      WindowFilter.windowNotVisible
      WindowFilter.windowFullscreened
      WindowFilter.windowUnfullscreened
      WindowFilter.windowMoved
      WindowFilter.windowCreated
      WindowFilter.windowDestroyed
      WindowFilter.windowMinimized
      WindowFilter.windowUnminimized
      WindowFilter.windowTitleChanged]
     handler)
    (emit :window-watcher.events/initial-windows
          (snapshot-observed-windows))
    wf))


(fn stop-window-watcher [state]
  "Stop the window watcher.
   state: the hs.window.filter object returned from start-window-watcher"
  (when state
    (state:unsubscribeAll)
    (state:delete)))


(local window-watcher-source-type
  (make-source-type
   :event-source.type/window-watcher
   "Emits events on window focus, visibility, and fullscreen changes"
   {:config-schema {}
    :emits [:window-watcher.events/focused
            :window-watcher.events/visible
            :window-watcher.events/not-visible
            :window-watcher.events/fullscreened
            :window-watcher.events/unfullscreened
            :window-watcher.events/moved
            :window-watcher.events/created
            :window-watcher.events/destroyed
            :window-watcher.events/minimized
            :window-watcher.events/deminimized
            :window-watcher.events/title-changed
            :window-watcher.events/initial-windows]
    :start-fn start-window-watcher
    :stop-fn stop-window-watcher}))


{: window-watcher-source-type}
