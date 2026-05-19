
;; sheaf/component-registry.fnl
;; Data-oriented component type registry - no global state.
;;
;; A component-registry is a data structure:
;;   {:component-types {}      ; type-name -> component-type data
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
;; Component types form a hierarchy via lib/hierarchy.fnl.
;;
;; Naming convention:
;;   :component.type/descriptor-name

(local {: isa?} (require :lib.hierarchy))
(local {: trait-defined?} (require :sheaf.trait-registry))


;; ============================================================================
;; Constructors
;; ============================================================================

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
;; Hierarchy Queries
;; ============================================================================

(fn component-type-isa? [registry child parent]
  "Check if component type child is-a parent in the component hierarchy."
  (isa? registry.hierarchy child parent))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-component-registry
 : make-component-type
 : add-component-type!
 : component-type-defined?
 : get-component-type
 : list-component-types
 : component-type-isa?}
