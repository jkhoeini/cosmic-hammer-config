
;; sheaf/behavior-registry.fnl
;; Data-oriented behavior registry - no global state.
;;
;; A behavior-registry is a data structure:
;;   {:behaviors {}          ; behavior-name -> behavior data
;;    :event-registry r      ; for event-selector validation
;;    :command-registry cr}  ; for command validation
;;
;; A behavior is a data structure:
;;   {:name :my-behavior
;;    :description "Human-readable description"
;;    :respond-to [:event.kind/something]
;;    :commands {:local-alias :namespace.commands/action}
;;    :fn (fn [event candidates send-cmd] ...)}

(local {: some} (require :lib.cljlib-shim))
(local {: valid-event-selector?} (require :sheaf.event-registry))
(local {: command-defined?} (require :sheaf.command-registry))
(local {: isa?} (require :lib.hierarchy))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-behavior-registry [opts]
  "Create a new behavior registry.
   opts:
     :event-registry    - for event-selector validation (required)
     :command-registry  - for command validation (required)"
  (when (= nil opts.event-registry)
    (error "make-behavior-registry: :event-registry is required"))
  (when (= nil opts.command-registry)
    (error "make-behavior-registry: :command-registry is required"))
  {:behaviors {}
   :event-registry opts.event-registry
   :command-registry opts.command-registry})


(fn make-behavior [opts]
  "Create a behavior data structure (pure, no validation).
   opts:
     :name        - unique identifier (e.g. :reload-hammerspoon.behaviors/reload) (required)
     :description - human-readable description (required)
     :respond-to  - list of event-names or event-kinds this behavior responds to (required)
     :commands    - map of {local-alias -> command-registry-name} (default {})
     :fn          - (fn [event candidates send-cmd] ...) - called when matching event occurs (required)
   Returns: {:name :description :respond-to :commands :fn}"
  (when (= nil opts.name)
    (error "make-behavior: :name is required"))
  (when (= nil opts.description)
    (error "make-behavior: :description is required"))
  (when (= nil opts.respond-to)
    (error (.. "make-behavior: :respond-to is required for " (tostring opts.name))))
  (when (= nil opts.fn)
    (error (.. "make-behavior: :fn is required for " (tostring opts.name))))
  {:name opts.name
   :description opts.description
   :respond-to opts.respond-to
   :commands (or opts.commands {})
   :fn opts.fn})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn add-behavior! [registry behavior]
  "Add a behavior to the registry. Mutates registry.
   Validates event-selectors against registry.event-registry.
   Validates command references against registry.command-registry."
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
    ;; Validate command references
    (each [alias cmd-name (pairs behavior.commands)]
      (when (not (command-defined? registry.command-registry cmd-name))
        (error (.. "add-behavior! " (tostring name)
                   ": command '" (tostring cmd-name)
                   "' (alias '" (tostring alias)
                   "') not found in command-registry"))))
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
