
;; sheaf/dispatcher.fnl
;; Behavior routing for events.
;;
;; Resolves subscriptions → behaviors → target components → commands.
;; Builds candidates and send-cmd per DESIGN.md event flow.

(local {: add-event-handler!} (require :sheaf.event-registry))
(local {: behavior-responds-to? : get-behavior} (require :sheaf.behavior-registry))
(local {: get-matching-subscriptions} (require :sheaf.subscription-registry))
(local {: get-command} (require :sheaf.command-registry))
(local {: components-with-tag} (require :sheaf.tag-registry))
(local {: get-component-instance} (require :sheaf.component-registry))
(local {: satisfies-all?} (require :sheaf.trait-registry))


(fn build-candidates [behavior command-registry component-registry trait-registry tag-registry target-tag]
  "Build candidates table: {cmd-alias → [instance-name ...]}.
   For each command alias in the behavior, find target instances that satisfy
   the command's requires-traits."
  (let [candidates {}
        target-instances (components-with-tag tag-registry target-tag)]
    (each [alias cmd-name (pairs (or behavior.commands {}))]
      (let [command (get-command command-registry cmd-name)
            required-traits (or (?. command :requires-traits) [])
            matching []]
        (each [instance-name _ (pairs target-instances)]
          (let [instance (get-component-instance component-registry instance-name)]
            (when (and instance
                       (satisfies-all? trait-registry required-traits (or instance.state {})))
              (table.insert matching instance-name))))
        (tset candidates alias matching)))
    candidates))


(fn make-send-cmd [behavior command-registry component-registry trait-registry]
  "Build a send-cmd function for a behavior invocation.
   send-cmd: (fn [instance-name cmd-alias params])
   Validates traits, calls command fn with component, captures returned state."
  (fn [instance-name cmd-alias params]
    (let [cmd-name (. behavior.commands cmd-alias)]
      (when (= nil cmd-name)
        (print (.. "[WARN] send-cmd: unknown alias '" (tostring cmd-alias)
                   "' in behavior '" (tostring behavior.name) "'"))
        (lua "return nil"))
      (let [command (get-command command-registry cmd-name)]
        (when (= nil command)
          (print (.. "[WARN] send-cmd: command not found: " (tostring cmd-name)))
          (lua "return nil"))
        (let [instance (get-component-instance component-registry instance-name)]
          (when (= nil instance)
            (print (.. "[WARN] send-cmd: instance not found: " (tostring instance-name)))
            (lua "return nil"))
          (if (satisfies-all? trait-registry (or command.requires-traits []) (or instance.state {}))
              (let [new-state (command.fn instance (or params {}))]
                (when (not= nil new-state)
                  (tset instance :state new-state)))
              (print (.. "[WARN] send-cmd: instance '" (tostring instance-name)
                         "' does not satisfy traits for command '" (tostring cmd-name) "'"))))))))


(fn dispatch-to-behavior [subscription-registry component-registry event behavior-name target-tag]
  "Dispatch an event to a single behavior with resolved candidates and send-cmd."
  (let [behavior-registry subscription-registry.behavior-registry
        command-registry behavior-registry.command-registry
        trait-registry component-registry.trait-registry
        tag-registry subscription-registry.tag-registry]
    (when (not (behavior-responds-to? behavior-registry behavior-name event.event-name))
      (print (.. "[ERROR] dispatch-to-behavior: behavior '"
                 (tostring behavior-name) "' does not respond to event '"
                 (tostring event.event-name) "'"))
      (lua "return nil"))
    (let [behavior (get-behavior behavior-registry behavior-name)]
      (when (= nil behavior)
        (print (.. "[ERROR] dispatch-to-behavior: behavior '"
                   (tostring behavior-name) "' not found in registry"))
        (lua "return nil"))
      (let [candidates (build-candidates behavior command-registry component-registry
                                         trait-registry tag-registry target-tag)
            send-cmd (make-send-cmd behavior command-registry component-registry trait-registry)]
        ((. behavior :fn) event candidates send-cmd)))))


(fn start-dispatcher! [subscription-registry component-registry]
  "Register behavior routing handlers on the event registry.
   subscription-registry must contain :event-registry, :behavior-registry, and :tag-registry.
   component-registry must contain :trait-registry.
   Resolves target-tag → instances, groups by command alias, builds send-cmd."
  (let [event-registry subscription-registry.event-registry]
    (add-event-handler! event-registry :dispatcher/behavior-router
                        (fn [event]
                          (let [sub-matches (get-matching-subscriptions
                                          subscription-registry
                                          event.event-source
                                          event.event-name)]
                            (each [_ sub-match (ipairs (or sub-matches []))]
                              (dispatch-to-behavior subscription-registry component-registry
                                                    event sub-match.behavior sub-match.target-tag)))))

    (add-event-handler! event-registry :dispatcher/debug-handler
                        (fn [event]
                          (when (. _G :event-bus.debug-mode?)
                            (print "got event" (hs.inspect event)))))))


{: start-dispatcher!}
