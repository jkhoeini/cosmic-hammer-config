
;; event_sources/window-watcher.fnl
;; Event source type: emits events on window focus, visibility, and fullscreen changes

(local {: make-source-type} (require :sheaf.source-registry))

(local WindowFilter hs.window.filter)


(fn make-event-data [window appName]
  "Build the event payload from an hs.window object."
  {:window-id (window:id)
   :app-name appName
   :window-title (window:title)
   :frame (window:frame)})


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
                        (emit :window-watcher.events/unfullscreened data)))))]
    (wf:subscribe
     [WindowFilter.windowFocused
      WindowFilter.windowVisible
      WindowFilter.windowNotVisible
      WindowFilter.windowFullscreened
      WindowFilter.windowUnfullscreened]
     handler)
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
            :window-watcher.events/unfullscreened]
    :start-fn start-window-watcher
    :stop-fn stop-window-watcher}))


{: window-watcher-source-type}
