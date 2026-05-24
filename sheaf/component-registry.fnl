
;; sheaf/component-registry.fnl
;; Data-oriented component type registry with instance lifecycle - no global state.
;;
;; A component-registry is a data structure:
;;   {:component-types {}      ; type-name -> component-type data
;;    :instances {}             ; instance-name -> component-instance data
;;    :hierarchy h             ; component kind hierarchy
;;    :trait-registry tr}      ; reference to trait-registry for cross-validation
;;
;; A component-type is a data structure:
;;   {:name :component.type/space-indicator
;;    :description "Space indicator menubar component"
;;    :traits [:trait/has-menubar]
;;    :config-schema {}
;;    :start-fn (fn [config] -> state)
;;    :stop-fn nil}
;;
;; A component-instance is a data structure:
;;   {:name :component.space-indicator.instance/main
;;    :type :component.type/space-indicator
;;    :config {}
;;    :state {:menubar <hs.menubar>}}
;;
;; Component types form a hierarchy via lib/hierarchy.fnl.
;;
;; Naming conventions:
;;   Type:     :component.type/descriptor-name
;;   Instance: :component.descriptor-name.instance/<instance-name>

(local {: isa?} (require :lib.hierarchy))
(local {: trait-defined? : satisfies-all?} (require :sheaf.trait-registry))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn type-name->descriptor [type-name]
  "Extract the descriptor from a component type name.
   :component.type/space-indicator → \"space-indicator\"
   Returns nil if type-name doesn't match the expected pattern."
  (string.match (tostring type-name) "^component%.type/(.+)$"))


(fn make-instance-name [type-name instance-id]
  "Construct a canonical instance name from a component type name and instance id.
   (make-instance-name :component.type/space-indicator \"main\")
   → :component.space-indicator.instance/main
   Errors if type-name doesn't match the :component.type/<descriptor> pattern."
  (let [descriptor (type-name->descriptor type-name)]
    (when (= nil descriptor)
      (error (.. "make-instance-name: invalid type name format: " (tostring type-name)
                 " (expected :component.type/<descriptor>)")))
    (.. "component." descriptor ".instance/" instance-id)))


(fn valid-instance-name? [type-name instance-name]
  "Check if instance-name follows the naming convention for the given type.
   :component.type/space-indicator expects :component.space-indicator.instance/<id>"
  (let [descriptor (type-name->descriptor type-name)]
    (if (= nil descriptor)
        false
        (not= nil (string.match (tostring instance-name)
                                (.. "^component%." descriptor "%.instance/.+$"))))))


(fn make-component-registry [opts]
  "Create a new component type registry.
   opts:
     :hierarchy - component kind hierarchy (required)
     :trait-registry - trait registry for cross-validation (required)"
  (when (= nil opts.hierarchy)
    (error "make-component-registry: :hierarchy is required"))
  (when (= nil opts.trait-registry)
    (error "make-component-registry: :trait-registry is required"))
  {:component-types {}
   :instances {}
   :hierarchy opts.hierarchy
   :trait-registry opts.trait-registry})


(fn make-component-type [name description opts]
  "Create a component type data structure (pure, no validation).
   name: unique identifier (e.g. :component.type/space-indicator)
   description: human-readable description
   opts:
     :start-fn - function to start the component (required)
     :traits - list of trait names (default [])
     :config-schema - schema for config validation (default {})
     :stop-fn - function to stop the component (optional)
   Returns: {:name :description :traits :config-schema :start-fn :stop-fn}"
  (when (= nil opts.start-fn)
    (error (.. "make-component-type: :start-fn is required for " (tostring name))))
  {:name name
   :description description
   :traits (or opts.traits [])
   :config-schema (or opts.config-schema {})
   :start-fn opts.start-fn
   :stop-fn opts.stop-fn})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn add-component-type! [registry component-type]
  "Add a component type to the registry. Mutates registry."
  (let [name component-type.name]
    (when (= nil name)
      (error "add-component-type!: component-type must have a :name"))
    (when (not= nil (. registry.component-types name))
      (error (.. "Component type already registered: " (tostring name))))
    (each [_ trait-name (ipairs (or component-type.traits []))]
      (when (not (trait-defined? registry.trait-registry trait-name))
        (error (.. "add-component-type! " (tostring name) ": trait '" (tostring trait-name) "' not found in trait-registry"))))
    (tset registry.component-types name component-type)))


(fn component-type-defined? [registry name]
  "Check if a component type is defined."
  (not= nil (. registry.component-types name)))


(fn get-component-type [registry name]
  "Get a component type by name."
  (. registry.component-types name))


(fn list-component-types [registry]
  "List all registered component type names."
  (let [names []]
    (each [name _ (pairs registry.component-types)]
      (table.insert names name))
    names))


;; ============================================================================
;; Component Instance API
;; ============================================================================

(fn component-instance-exists? [registry instance-name]
  "Check if a component instance exists."
  (not= nil (. registry.instances instance-name)))


(fn get-component-instance [registry instance-name]
  "Get a component instance by name."
  (. registry.instances instance-name))


(fn list-component-instances [registry]
  "List all running component instance names."
  (let [names []]
    (each [name _ (pairs registry.instances)]
      (table.insert names name))
    names))


(fn start-component! [registry type-name instance-name config]
  "Start a new instance of a component type.
   Calls the type's start-fn with config to obtain state, validates that
   the returned state satisfies all traits declared by the type, and
   stores the instance in the registry.
   instance-name: unique name (e.g. :component.space-indicator.instance/main)
   type-name: the component type (e.g. :component.type/space-indicator)
   config: configuration table for this instance"
  (when (component-instance-exists? registry instance-name)
    (error (.. "start-component!: instance already exists: " (tostring instance-name))))
  (when (not (valid-instance-name? type-name instance-name))
    (error (.. "start-component!: instance name '" (tostring instance-name)
               "' does not follow naming convention for type " (tostring type-name)
               " (expected :component.<descriptor>.instance/<id>,"
               " use make-instance-name to construct)")))
  (let [component-type (get-component-type registry type-name)]
    (when (= nil component-type)
      (error (.. "start-component!: type not found: " (tostring type-name))))
    (let [state (component-type.start-fn (or config {}))]
      (when (and (< 0 (length component-type.traits)) (= nil state))
        (error (.. "start-component!: start-fn for " (tostring type-name) " returned nil but type declares traits")))
      (when (not (satisfies-all? registry.trait-registry component-type.traits (or state {})))
        (error (.. "start-component!: state from " (tostring type-name)
                   " does not satisfy declared traits for instance " (tostring instance-name))))
      (tset registry.instances instance-name
            {:name instance-name
             :type type-name
             :config (or config {})
             :state state})
      (print (.. "[INFO] Started component instance: " (tostring instance-name))))))


(fn stop-component! [registry instance-name]
  "Stop a running component instance.
   Calls the type's stop-fn (if any) with the instance state,
   then removes the instance from the registry.
   instance-name: the instance to stop"
  (let [instance (get-component-instance registry instance-name)]
    (when (= nil instance)
      (error (.. "stop-component!: instance not found: " (tostring instance-name))))
    (let [component-type (get-component-type registry instance.type)]
      (when component-type.stop-fn
        (component-type.stop-fn instance.state))
      (tset registry.instances instance-name nil)
      (print (.. "[INFO] Stopped component instance: " (tostring instance-name))))))


;; ============================================================================
;; Hierarchy Queries
;; ============================================================================

(fn component-type-isa? [registry child parent]
  "Check if component type child is-a parent in the component hierarchy."
  (isa? registry.hierarchy child parent))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-instance-name
 : valid-instance-name?
 : make-component-registry
 : make-component-type
 : add-component-type!
 : component-type-defined?
 : get-component-type
 : list-component-types
 : component-instance-exists?
 : get-component-instance
 : list-component-instances
 : start-component!
 : stop-component!
 : component-type-isa?}
