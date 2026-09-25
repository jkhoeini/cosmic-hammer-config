;; behaviors/mouse-window-management.fnl
;; Behaviors for mouse-driven window management

(local {: make-behavior} (require :sheaf.behavior-registry))


(fn should-focus-hovered? [window-id window-state]
  (let [window (?. window-state :windows window-id)]
    (and window
         (not window.fullscreen)
         (not= window-id window-state.focused-window-id))))


(fn likely-new-window? [window-id window-state]
  (let [windows (or (?. window-state :windows) {})]
    (when (. windows window-id)
      (lua "return false"))
    (var max-window-id nil)
    (each [tracked-id _ (pairs windows)]
      (when (or (= max-window-id nil) (> tracked-id max-window-id))
        (set max-window-id tracked-id)))
    (or (= max-window-id nil) (> window-id max-window-id))))

(fn placement-allowed-after-space-change? [created-at mouse-state cooldown]
  (let [last-change (?. mouse-state :last-space-change-at)]
    (or (= last-change nil)
        (> created-at (+ last-change cooldown)))))


(local focus-hovered-window-behavior
  (make-behavior
   {:name :mouse-window-management.behaviors/focus-hovered-window
    :description "Focus a non-focused, non-fullscreen window after mouse dwell"
    :respond-to [:event.kind.mouse/window-hovered]
    :commands {:focus :mouse-window-management.commands/focus-hovered-window}
    :inputs {:window-state :shape/window-state}
    :fn (fn [event candidates send-cmd inputs]
          (let [target (. candidates.focus 1)
                window-id (?. event :event-data :window-id)
                window-state (?. inputs :window-state)]
            (when (and target
                       window-id
                       window-state
                       (should-focus-hovered? window-id window-state))
              (send-cmd target :focus {:window-id window-id}))))}))


(local center-cursor-on-focus-behavior
  (make-behavior
   {:name :mouse-window-management.behaviors/center-cursor-on-focus
    :description "Center the cursor for focus changes not initiated by hover"
    :respond-to [:event.kind.window/focused]
    :commands {:center :mouse-window-management.commands/center-cursor
               :consume-hover-focus :mouse-window-management.commands/consume-hover-focus}
    :inputs {:mouse-state :shape/mouse-window-management-state}
    :fn (fn [event candidates send-cmd inputs]
          (let [center-target (. candidates.center 1)
                consume-target (. candidates.consume-hover-focus 1)
                window-id (?. event :event-data :window-id)
                frame (?. event :event-data :frame)
                hover-focus-window-ids (?. inputs :mouse-state :hover-focus-window-ids)]
            (if (and consume-target
                     (. (or hover-focus-window-ids {}) window-id))
                (send-cmd consume-target :consume-hover-focus
                          {:window-id window-id})
                (when (and center-target window-id frame)
                  (send-cmd center-target :center
                            {:window-id window-id :frame frame})))))}))


(local schedule-created-window-behavior
  (make-behavior
   {:name :mouse-window-management.behaviors/schedule-created-window
    :description "Delay placement of a likely-new window until discovery settles"
    :respond-to [:event.kind.window/created]
    :commands {:schedule :mouse-window-management.commands/schedule-window-placement}
    :inputs {:window-state :shape/window-state}
    :fn (fn [event candidates send-cmd inputs]
          (let [target (. candidates.schedule 1)
                window-id (?. event :event-data :window-id)
                window-state (?. inputs :window-state)]
            (when (and target
                       window-id
                       window-state
                       (likely-new-window? window-id window-state))
              (send-cmd target :schedule
                        {:window-id window-id :created-at event.timestamp}))))}))


(local note-space-change-behavior
  (make-behavior
   {:name :mouse-window-management.behaviors/note-space-change
    :description "Record active Space changes for placement suppression"
    :respond-to [:event.kind.space/changed]
    :commands {:note :mouse-window-management.commands/note-space-change}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.note 1)]
            (when target
              (send-cmd target :note {:timestamp event.timestamp}))))}))


(local place-created-window-behavior
  (make-behavior
   {:name :mouse-window-management.behaviors/place-created-window
    :description "Place a settled likely-new window on the cursor's screen"
    :respond-to [:event.kind.window/placement-ready]
    :commands {:place :mouse-window-management.commands/place-window-on-cursor-screen}
    :inputs {:mouse-state :shape/mouse-window-management-state}
    :fn (fn [event candidates send-cmd inputs]
          (let [target (. candidates.place 1)
                window-id (?. event :event-data :window-id)
                created-at (?. event :event-data :created-at)
                cursor-screen-uuid (?. event :event-data :cursor-screen-uuid)
                mouse-state (?. inputs :mouse-state)]
            (when (and target
                       window-id
                       created-at
                       cursor-screen-uuid
                       mouse-state
                       (placement-allowed-after-space-change?
                        created-at mouse-state 1.0))
              (send-cmd target :place
                        {:window-id window-id
                         :cursor-screen-uuid cursor-screen-uuid}))))}))


{: focus-hovered-window-behavior
 : center-cursor-on-focus-behavior
 : schedule-created-window-behavior
 : note-space-change-behavior
 : place-created-window-behavior
 : should-focus-hovered?
 : likely-new-window?
 : placement-allowed-after-space-change?}
