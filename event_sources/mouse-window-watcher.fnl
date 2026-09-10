;; event_sources/mouse-window-watcher.fnl
;; Event source type: emits when the window under a moving cursor changes

(local {: make-source-type} (require :sheaf.source-registry))

(local number? #(= (type $) :number))


(fn window-at-point [point]
  "Return the standard external-process window at point, or nil."
  (let [(ok element) (pcall hs.axuielement.systemElementAtPosition point)]
    (when ok
      (let [window-element (if (= (?. element :AXRole) :AXWindow)
                               element
                               (?. element :AXWindow))]
        (when window-element
          (let [(converted-ok window) (pcall #(window-element:asHSWindow))]
            (when (and converted-ok
                       window
                       (window:id)
                       (window:isStandard)
                       (not= (window:pid) hs.processInfo.processID))
              window)))))))


(fn mouse-buttons-down? []
  (let [buttons (hs.eventtap.checkMouseButtons)]
    (or buttons.left buttons.right buttons.middle)))


(fn start-mouse-window-watcher [self emit]
  "Start polling for changes to the window under the cursor."
  (let [interval (or self.config.interval 0.15)
        state {:last-position nil :last-window-id nil :timer nil}
        poll! (fn []
                (let [position (hs.mouse.absolutePosition)
                      same-position? (and (= position.x (?. state :last-position :x))
                                          (= position.y (?. state :last-position :y)))]
                  (when (not same-position?)
                    (tset state :last-position {:x position.x :y position.y})
                    (when (not (mouse-buttons-down?))
                      (let [(ok window) (pcall window-at-point position)
                            window-id (and ok window (window:id))]
                        (when (not= window-id state.last-window-id)
                          (tset state :last-window-id window-id)
                          (when window-id
                            (emit :mouse-window-watcher.events/window-hovered
                                  {:window-id window-id}))))))))
        timer (hs.timer.new interval poll! true)]
    (tset state :timer timer)
    (timer:start)
    state))


(fn stop-mouse-window-watcher [state]
  "Stop polling for the window under the cursor."
  (when (?. state :timer)
    (state.timer:stop)))


(local mouse-window-watcher-source-type
  (make-source-type
   :event-source.type/mouse-window-watcher
   "Emits when the standard window under a moving cursor changes"
   {:config-schema {:interval number?}
    :emits [:mouse-window-watcher.events/window-hovered]
    :start-fn start-mouse-window-watcher
    :stop-fn stop-mouse-window-watcher}))


{: mouse-window-watcher-source-type
 : window-at-point}
