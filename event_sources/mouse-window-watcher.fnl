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
  "Observe mouse movement and emit after the cursor dwells on a new window."
  (let [dwell (or self.config.dwell 0.06)
        state {:candidate-window-id nil
               :last-window-id nil
               :dwell-timer nil
               :eventtap nil}
        observe! (fn [position]
                   (when (not (mouse-buttons-down?))
                     (let [(ok window) (pcall window-at-point position)
                           window-id (and ok window (window:id))]
                       (when (not= window-id state.candidate-window-id)
                         (when state.dwell-timer
                           (state.dwell-timer:stop)
                           (tset state :dwell-timer nil))
                         (tset state :candidate-window-id window-id)
                         (when (and window-id
                                    (not= window-id state.last-window-id))
                           (let [candidate-id window-id
                                 dwell-timer
                                 (hs.timer.doAfter
                                  dwell
                                  (fn []
                                    (when (= candidate-id state.candidate-window-id)
                                      (tset state :last-window-id candidate-id)
                                      (tset state :dwell-timer nil)
                                      (emit :mouse-window-watcher.events/window-hovered
                                            {:window-id candidate-id}))))]
                             (tset state :dwell-timer dwell-timer)))))))
        eventtap (hs.eventtap.new
                  [hs.eventtap.event.types.mouseMoved]
                  (fn [event]
                    (observe! (event:location))
                    false))]
    (tset state :eventtap eventtap)
    (eventtap:start)
    state))


(fn stop-mouse-window-watcher [state]
  "Stop mouse observation and pending dwell work."
  (when (?. state :dwell-timer)
    (state.dwell-timer:stop))
  (when (?. state :eventtap)
    (state.eventtap:stop)))


(local mouse-window-watcher-source-type
  (make-source-type
   :event-source.type/mouse-window-watcher
   "Emits when the standard window under a moving cursor changes"
   {:config-schema {:dwell number?}
    :emits [:mouse-window-watcher.events/window-hovered]
    :start-fn start-mouse-window-watcher
    :stop-fn stop-mouse-window-watcher}))


{: mouse-window-watcher-source-type
 : window-at-point}
