
;; event_sources/window-element-watcher.fnl
;; Event source type: per-window uielement watcher for move/resize events

(local {: make-source-type} (require :sheaf.source-registry))

(local Watcher hs.uielement.watcher)

;; cljlib-shim lacks number?; define locally (matches cljlib predicate style)
(local number? (fn [x] (= (type x) :number)))


(fn start-window-element-watcher [self emit]
  "Start a uielement watcher on a specific window for move/resize events.
   self: {:name instance-name :type type-name :config {:window-id number}}
   emit: (fn [event-name event-data])
   Returns the watcher object as state, or nil if window not found."
  (let [window-id self.config.window-id
        window (hs.window.get window-id)]
    (if (not window)
        (do (print (.. "window-element-watcher: window not found for id " (tostring window-id)))
            nil)
        (let [callback (fn [element event-name _watcher-obj _user-data]
                         (let [(ok frame) (pcall #(element:frame))]
                           (when ok
                             (match event-name
                               :AXWindowMoved
                               (emit :window-element-watcher.events/moved
                                     {:window-id window-id :frame frame})
                               :AXWindowResized
                               (emit :window-element-watcher.events/resized
                                     {:window-id window-id :frame frame})))))
              watcher (window:newWatcher callback)]
          (watcher:start [Watcher.windowMoved Watcher.windowResized])
          watcher))))


(fn stop-window-element-watcher [state]
  "Stop the uielement watcher.
   state: the hs.uielement.watcher object returned from start-window-element-watcher"
  (when state
    (state:stop)))


(local window-element-watcher-source-type
  (make-source-type
   :event-source.type/window-element-watcher
   "Per-window uielement watcher for move/resize events"
   {:config-schema {:window-id number?}
    :emits [:window-element-watcher.events/moved
            :window-element-watcher.events/resized]
    :start-fn start-window-element-watcher
    :stop-fn stop-window-element-watcher}))


{: window-element-watcher-source-type}
