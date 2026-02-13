
;; lib/dispatcher.fnl
;; Behavior routing for events.
;;
;; Provides start-dispatcher! to register behavior routing handlers.

(local {: mapv : filter : seq} (require :lib.cljlib-shim))
(local {: add-event-handler!} (require :lib.event-registry))
(local {: behavior-responds-to? : get-behavior} (require :lib.behavior-registry))
(local {: get-subscribed-behaviors} (require :lib.subscription-registry))
(local {: source-instance-exists?} (require :lib.source-registry))
(local {: invoke-command!} (require :lib.command-registry))


(fn build-cmd-table [command-registry behavior]
  "Build a cmd table for a behavior from its :commands map.
   Each key in the :commands map becomes a function that invokes the corresponding command.
   Returns a table like {alias (fn [params] (invoke-command! registry cmd-name params))}."
  (let [cmd {}]
    (each [alias cmd-name (pairs (or behavior.commands {}))]
      (tset cmd alias (fn [params]
                        (invoke-command! command-registry cmd-name params))))
    cmd))


(fn get-behaviors-for-event [subscription-registry event]
  "Get all behaviors for this event, resolved from registry."
  (let [behavior-registry subscription-registry.behavior-registry
        source-registry subscription-registry.source-registry]
    (when (not (source-instance-exists? source-registry event.event-source))
      (print (.. "[WARN] get-behaviors-for-event: unknown source instance '"
                 (tostring event.event-source) "'")))
    (let [behavior-names (or (get-subscribed-behaviors subscription-registry event.event-source event.event-name) [])
          ;; Filter to behaviors that actually respond to this event-name
          valid-names (filter (fn [name]
                                (let [responds? (behavior-responds-to? behavior-registry name event.event-name)]
                                  (when (not responds?)
                                    (print (.. "[ERROR] get-behaviors-for-event: behavior '"
                                               (tostring name) "' does not respond to event '"
                                               (tostring event.event-name) "'")))
                                  responds?))
                              behavior-names)]
      (mapv (fn [name]
              (let [behavior (get-behavior behavior-registry name)]
                (when (= nil behavior)
                  (print (.. "[ERROR] get-behaviors-for-event: behavior '"
                             (tostring name) "' not found in registry")))
                behavior))
            (or (seq valid-names) [])))))


(fn start-dispatcher! [subscription-registry]
  "Register behavior routing handlers on the event registry.
   subscription-registry must contain :event-registry, :behavior-registry, and :source-registry.
   command-registry is resolved from subscription-registry.behavior-registry.command-registry.
   Per-behavior cmd tables are lazily built and cached on first use."
  (let [event-registry subscription-registry.event-registry
        command-registry subscription-registry.behavior-registry.command-registry
        cmd-cache {}
        get-cmd-table (fn [behavior]
                        (let [cached (. cmd-cache behavior.name)]
                          (if cached
                              cached
                              (let [cmd (build-cmd-table command-registry behavior)]
                                (tset cmd-cache behavior.name cmd)
                                cmd))))]
    (add-event-handler! event-registry :dispatcher/behavior-router
                        (fn [event]
                          (let [bs (get-behaviors-for-event subscription-registry event)]
                            (each [_ behavior (pairs bs)]
                              (when behavior
                                ((. behavior :fn) event (get-cmd-table behavior)))))))

    (add-event-handler! event-registry :dispatcher/debug-handler
                        (fn [event]
                          (when (. _G :event-bus.debug-mode?)
                            (print "got event" (hs.inspect event)))))))


{: start-dispatcher!}
