
;; commands/desktop-layout.fnl
;; Captures the current desktop layout and emits derived space lifecycle events.

(local {: make-command} (require :sheaf.command-registry))
(local {: dispatch-event!} (require :sheaf.event-registry))
(local {: event-registry} (require :events))


(fn dispatch-spaces! [event-name component entries all-spaces active-spaces]
  (each [_ entry (ipairs (or entries []))]
    (dispatch-event! event-registry event-name component.name
                     {:space-id entry.space-id
                      :screen-uuid entry.screen-uuid
                      :all-spaces all-spaces
                      :active-spaces active-spaces})))


(local reconcile-spaces-command
  (make-command
   :desktop-layout.commands/reconcile-spaces
   "Capture a desktop snapshot and emit derived space lifecycle events"
   {:requires-traits [:trait/has-desktop-layout]
    :fn (fn [component params]
          (dispatch-spaces! :desktop-layout.events/space-destroyed
                            component params.destroyed
                            params.all-spaces params.active-spaces)
          (dispatch-spaces! :desktop-layout.events/space-created
                            component params.created
                            params.all-spaces params.active-spaces)
          {:all-spaces params.all-spaces})}))


{: reconcile-spaces-command}
