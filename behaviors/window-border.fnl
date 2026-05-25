
;; behaviors/window-border.fnl
;; Behaviors: update window borders on focus and move/resize events

(local {: make-behavior} (require :sheaf.behavior-registry))


(local update-on-focus-behavior
  (make-behavior
   {:name :window-border.behaviors/update-on-focus
    :description "Show active border around the newly focused window"
    :respond-to [:event.kind.window/focused]
    :commands {:show-active :window-border.commands/show-active-border
               :show-inactive :window-border.commands/show-inactive-border}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.show-active 1)]
            (when target
              (send-cmd target :show-active {:window-id event.event-data.window-id
                                             :frame event.event-data.frame}))))}))


(local update-on-move-behavior
  (make-behavior
   {:name :window-border.behaviors/update-on-move
    :description "Reposition active border when a window moves or resizes"
    :respond-to [:event.kind.window/focused]
    :commands {:show-active :window-border.commands/show-active-border}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.show-active 1)]
            (when target
              (send-cmd target :show-active {:window-id event.event-data.window-id
                                             :frame event.event-data.frame}))))}))


{: update-on-focus-behavior
 : update-on-move-behavior}
