
;; lib/event-registry.fnl
;; Data-oriented event registry - no global state.
;;
;; An event-registry is a data structure:
;;   {:events {}           ; event-name -> {:description :schema}
;;    :hierarchy h         ; the hierarchy (access via registry.hierarchy)
;;    :handlers {}         ; handler-key -> handler-fn
;;    :queue []}           ; pending events

(local {: some : seq} (require :lib.cljlib-shim))
(local {: descendants} (require :lib.hierarchy))


(fn make-event-registry [opts]
  "Create a new event registry.
   opts:
     :hierarchy - the hierarchy for event-kind relationships (required)"
  (when (= nil opts.hierarchy)
    (error "make-event-registry: :hierarchy is required"))
  {:events {}
   :hierarchy opts.hierarchy
   :handlers {}
   :queue []})


(fn define-event! [registry event-name description schema]
  "Define an event in the registry. Mutates registry."
  (when (not= nil (. registry.events event-name))
    (error (.. "Event already defined: " (tostring event-name))))
  (tset registry.events event-name {:description description :schema schema}))


(fn event-defined? [registry event-name]
  "Check if an event is defined."
  (not= nil (. registry.events event-name)))


(fn valid-event-selector? [registry selector]
  "Check if selector is valid (defined event or has defined descendants)."
  (or (event-defined? registry selector)
      (some #(event-defined? registry $)
            (seq (descendants registry.hierarchy selector)))))


(fn add-event-handler! [registry key handler]
  "Add a handler that receives all dispatched events. Mutates registry."
  (when (not= nil (. registry.handlers key))
    (error (.. "Event handler already registered: " (tostring key))))
  (tset registry.handlers key handler))


(fn remove-event-handler! [registry key]
  "Remove an event handler. Mutates registry."
  (tset registry.handlers key nil))


(fn dispatch-event! [registry event-name event-source event-data]
  "Enqueue an event for processing. Does not process - use event-loop for that."
  (when (not (event-defined? registry event-name))
    (print (.. "[WARN] dispatch-event!: event '" (tostring event-name) "' not defined")))
  (let [event {:timestamp (hs.timer.secondsSinceEpoch)
               :event-name event-name
               :event-source event-source
               :event-data event-data}]
    (table.insert registry.queue event)))


{: make-event-registry
 : define-event!
 : event-defined?
 : valid-event-selector?
 : add-event-handler!
 : remove-event-handler!
 : dispatch-event!}
