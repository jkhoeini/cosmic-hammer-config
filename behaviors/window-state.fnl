
;; behaviors/window-state.fnl
;; Behaviors for tracking window state: initialize, track changes, untrack.

(local {: make-behavior} (require :sheaf.behavior-registry))


(local initialize-behavior
  (make-behavior
   {:name :window-state.behaviors/initialize
    :description "Populate window state from initial snapshot"
    :respond-to [:event.kind.window/initial]
    :commands {:initialize :window-state.commands/initialize-windows}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.initialize 1)]
            (when (and target (?. event :event-data :windows))
              (send-cmd target :initialize
                        {:windows event.event-data.windows}))))}))


(local track-on-change-behavior
  (make-behavior
   {:name :window-state.behaviors/track-on-change
    :description "Track window on focus, visible, or fullscreen change"
    :respond-to [:event.kind.window/focused
                 :event.kind.window/visible
                 :event.kind.window/fullscreened
                 :event.kind.window/unfullscreened]
    :commands {:upsert :window-state.commands/upsert-window}
    :fn (fn [event candidates send-cmd]
          (let [d event.event-data
                target (. candidates.upsert 1)
                fullscreen (match event.event-name
                             :window-watcher.events/fullscreened true
                             :window-watcher.events/unfullscreened false
                             _ nil)]
            (when (and target d.window-id)
              (send-cmd target :upsert
                        {:window-id d.window-id
                         :app-name d.app-name
                         :bundle-id d.bundle-id
                         :window-title d.window-title
                         :frame d.frame
                         :fullscreen fullscreen}))))}))


(local track-on-move-behavior
  (make-behavior
   {:name :window-state.behaviors/track-on-move
    :description "Track window frame on move or resize"
    :respond-to [:event.kind.window/moved]
    :commands {:upsert :window-state.commands/upsert-window}
    :fn (fn [event candidates send-cmd]
          (let [d event.event-data
                target (. candidates.upsert 1)]
            (when (and target d.window-id)
              (send-cmd target :upsert
                        {:window-id d.window-id
                         :frame d.frame}))))}))


(local untrack-on-disappear-behavior
  (make-behavior
   {:name :window-state.behaviors/untrack-on-disappear
    :description "Remove window from tracking on disappear"
    :respond-to [:event.kind.window/not-visible]
    :commands {:remove :window-state.commands/remove-window}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.remove 1)]
            (when (and target (?. event :event-data :window-id))
              (send-cmd target :remove
                        {:window-id event.event-data.window-id}))))}))


(local track-focus-behavior
  (make-behavior
   {:name :window-state.behaviors/track-focus
    :description "Track which window is currently focused"
    :respond-to [:event.kind.window/focused]
    :commands {:set-focused :window-state.commands/set-focused-window}
    :fn (fn [event candidates send-cmd]
          (let [target (. candidates.set-focused 1)
                window-id (?. event :event-data :window-id)]
            (when (and target window-id)
              (send-cmd target :set-focused {:window-id window-id}))))}))


{: initialize-behavior
 : track-on-change-behavior
 : track-on-move-behavior
 : untrack-on-disappear-behavior
 : track-focus-behavior}
