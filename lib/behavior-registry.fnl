
;; lib/behavior-registry.fnl
;; Data-oriented behavior registry - no global state.
;;
;; A behavior-registry is a data structure:
;;   {:behaviors {}       ; behavior-name -> behavior data
;;    :event-registry r}  ; for event-selector validation
;;
;; A behavior is a data structure:
;;   {:name :my-behavior
;;    :description "Human-readable description"
;;    :respond-to [:event.kind/something]
;;    :fn (fn [event send-cmd!] ...)}

(local {: some} (require :lib.cljlib-shim))
(local {: valid-event-selector?} (require :lib.event-registry))
(local {: isa?} (require :lib.hierarchy))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-behavior-registry [opts]
  "Create a new behavior registry.
   opts:
     :event-registry - for event-selector validation (required)"
  (when (= nil opts.event-registry)
    (error "make-behavior-registry: :event-registry is required"))
  {:behaviors {}
   :event-registry opts.event-registry})


(fn make-behavior [name description event-selectors handler-fn]
  "Create a behavior data structure (pure, no validation).
   name: unique identifier (e.g. :reload-hammerspoon.behaviors/reload)
   description: human-readable description
   event-selectors: list of event-names or event-kinds this behavior responds to
    handler-fn: (fn [event send-cmd!] ...) - called when matching event occurs
   Returns: {:name :description :respond-to :fn}"
  {:name name
   :description description
   :respond-to event-selectors
   :fn handler-fn})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn add-behavior! [registry behavior]
  "Add a behavior to the registry. Mutates registry.
   Validates event-selectors against registry.event-registry."
  (let [name behavior.name]
    (when (= nil name)
      (error "add-behavior!: behavior must have a :name"))
    (when (not= nil (. registry.behaviors name))
      (error (.. "Behavior already registered: " (tostring name))))
    ;; Warn about invalid event-selectors
    (each [_ selector (ipairs behavior.respond-to)]
      (when (not (valid-event-selector? registry.event-registry selector))
        (print (.. "[WARN] add-behavior!: event-selector '"
                   (tostring selector) "' in behavior '"
                   (tostring name) "' has no matching defined events"))))
    (tset registry.behaviors name behavior)))


(fn behavior-defined? [registry name]
  "Check if a behavior is defined."
  (not= nil (. registry.behaviors name)))


(fn get-behavior [registry name]
  "Get a behavior by name."
  (. registry.behaviors name))


(fn list-behaviors [registry]
  "List all registered behavior names."
  (let [names []]
    (each [name _ (pairs registry.behaviors)]
      (table.insert names name))
    names))


(fn behavior-responds-to? [registry behavior-name event-name]
  "Check if behavior's :respond-to selectors match the given event-name (via isa?)."
  (let [behavior (get-behavior registry behavior-name)]
    (if (= nil behavior)
        false
        (some #(isa? registry.event-registry.hierarchy event-name $)
              behavior.respond-to))))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-behavior-registry
 : make-behavior
 : add-behavior!
 : behavior-defined?
 : get-behavior
 : list-behaviors
 : behavior-responds-to?}
