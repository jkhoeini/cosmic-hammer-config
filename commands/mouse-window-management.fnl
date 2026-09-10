;; commands/mouse-window-management.fnl
;; Commands for mouse-driven window management

(local {: make-command} (require :sheaf.command-registry))
(local {: dispatch-event!} (require :sheaf.event-registry))
(local {: event-registry} (require :events))
(local {: window-at-point} (require :event_sources.mouse-window-watcher))


(local number? #(= (type $) :number))
(local table? #(= (type $) :table))
(local string? #(= (type $) :string))

(local raise-window-command
  (make-command
   :mouse-window-management.commands/raise-window
   "Raise the window still under the cursor without activating its application"
   {:schema {:window-id number?}
    :fn (fn [component params]
          (let [point (hs.mouse.absolutePosition)
                (ok window) (pcall window-at-point point)]
            (when (and ok window (= (window:id) params.window-id))
              (pcall #(window:raise))))
          nil)}))


(local center-cursor-command
  (make-command
   :mouse-window-management.commands/center-cursor
   "Center the cursor when it is outside the focused window"
   {:schema {:window-id number? :frame table?}
    :fn (fn [component params]
          (let [(window-ok window) (pcall hs.window.get params.window-id)
                (frame-ok live-frame) (if (and window-ok window)
                                          (pcall #(window:frame))
                                          (values false nil))
                frame (if frame-ok live-frame params.frame)
                point (hs.mouse.absolutePosition)]
            (when (and frame
                       (not (hs.geometry.isPointInRect point frame)))
              (hs.mouse.absolutePosition
               (hs.geometry.rectMidPoint frame))))
          nil)}))


(local note-space-change-command
  (make-command
   :mouse-window-management.commands/note-space-change
   "Record the latest active Space change"
   {:requires-traits [:trait/has-mouse-window-management-state]
    :schema {:timestamp number?}
    :fn (fn [component params]
          {:last-space-change-at params.timestamp
           :pending-placement-timers component.state.pending-placement-timers})}))


(local schedule-placement-command
  (make-command
   :mouse-window-management.commands/schedule-window-placement
   "Delay likely-new window placement until Space discovery settles"
   {:requires-traits [:trait/has-mouse-window-management-state]
    :schema {:window-id number? :created-at number?}
    :fn (fn [component params]
          (let [pending component.state.pending-placement-timers
                existing (. pending params.window-id)
                cursor-screen (hs.mouse.getCurrentScreen)
                cursor-screen-uuid (and cursor-screen (cursor-screen:getUUID))]
            (when existing (existing:stop))
            (tset pending params.window-id
                  (hs.timer.doAfter
                   0.25
                   (fn []
                     (tset pending params.window-id nil)
                     (dispatch-event! event-registry
                                      :mouse-window-management.events/window-placement-ready
                                      component.name
                                      {:window-id params.window-id
                                       :created-at params.created-at
                                       :cursor-screen-uuid cursor-screen-uuid}))))
            {:last-space-change-at component.state.last-space-change-at
             :pending-placement-timers pending}))}))

(local place-window-command
  (make-command
   :mouse-window-management.commands/place-window-on-cursor-screen
   "Move a new standard window to the cursor's screen"
   {:requires-traits [:trait/has-mouse-window-management-state]
    :schema {:window-id number? :cursor-screen-uuid string?}
    :fn (fn [component params]
          (let [(window-ok window) (pcall hs.window.get params.window-id)
                cursor-screen (and params.cursor-screen-uuid
                                   (hs.screen.find params.cursor-screen-uuid))
                pending component.state.pending-placement-timers]
            (when (and window-ok
                       window
                       cursor-screen
                       (window:isStandard)
                       (not (window:isFullScreen))
                       (not= (window:screen) cursor-screen))
              (let [(moved-ok) (pcall #(: window :moveToScreen cursor-screen true true 0))]
                (when moved-ok
                  (tset pending params.window-id
                        (hs.timer.doAfter
                         0.25
                         (fn []
                           (tset pending params.window-id nil)
                           (dispatch-event! event-registry
                                            :mouse-window-management.events/window-placed
                                            component.name
                                            {:window-id params.window-id})))))))
            {:last-space-change-at component.state.last-space-change-at
             :pending-placement-timers pending}))}))


{: raise-window-command
 : center-cursor-command
 : note-space-change-command
 : schedule-placement-command
 : place-window-command}
