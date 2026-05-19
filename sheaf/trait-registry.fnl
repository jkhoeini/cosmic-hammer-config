
;; sheaf/trait-registry.fnl
;; Data-oriented trait registry - no global state.
;;
;; A trait-registry is a data structure:
;;   {:traits {}          ; trait-name -> trait data
;;    :hierarchy h}       ; trait kind hierarchy
;;
;; A trait is a data structure:
;;   {:name :trait/has-menubar
;;    :description "Component state includes a menubar object"
;;    :schema {:menubar (fn [v] (not= nil v))}}
;;
;; Schema is a map of {key -> predicate-fn}. satisfies? checks that every
;; key is present in state and every predicate passes.
;;
;; Traits form a hierarchy via lib/hierarchy.fnl, rooted at :trait.kind/any.
;;
;; Naming convention:
;;   :trait/descriptor-name

(local {: isa?} (require :lib.hierarchy))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-trait-registry [opts]
  "Create a new trait registry.
   opts:
     :hierarchy - trait kind hierarchy (required)"
  (when (= nil opts.hierarchy)
    (error "make-trait-registry: :hierarchy is required"))
  {:traits {}
   :hierarchy opts.hierarchy})


(fn make-trait [name description opts]
  "Create a trait data structure (pure, no validation).
   name: unique identifier (e.g. :trait/has-menubar)
   description: human-readable description
   opts:
     :schema - {key -> predicate-fn} defining required state keys (required)
   Returns: {:name :description :schema}"
  (when (= nil opts.schema)
    (error (.. "make-trait: :schema is required for " (tostring name))))
  {:name name
   :description description
   :schema opts.schema})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn add-trait! [registry trait]
  "Add a trait to the registry. Mutates registry."
  (let [name trait.name]
    (when (= nil name)
      (error "add-trait!: trait must have a :name"))
    (when (not= nil (. registry.traits name))
      (error (.. "Trait already registered: " (tostring name))))
    (tset registry.traits name trait)))


(fn trait-defined? [registry name]
  "Check if a trait is defined."
  (not= nil (. registry.traits name)))


(fn get-trait [registry name]
  "Get a trait by name."
  (. registry.traits name))


(fn list-traits [registry]
  "List all registered trait names."
  (let [names []]
    (each [name _ (pairs registry.traits)]
      (table.insert names name))
    names))


(fn satisfies? [registry trait-name state]
  "Check if state satisfies a trait's schema.
   Every key in the schema must be present in state and its predicate must pass.
   Returns true if all checks pass, false otherwise."
  (let [trait (get-trait registry trait-name)]
    (when (= nil trait)
      (error (.. "satisfies?: trait not found: " (tostring trait-name))))
    (var ok true)
    (each [key pred (pairs trait.schema) &until (not ok)]
      (let [val (. state key)]
        (when (not (pred val))
          (set ok false))))
    ok))


(fn satisfies-all? [registry trait-names state]
  "Check if state satisfies all traits in the list.
   Returns true if every trait is satisfied, false otherwise."
  (var ok true)
  (each [_ trait-name (ipairs trait-names) &until (not ok)]
    (when (not (satisfies? registry trait-name state))
      (set ok false)))
  ok)


(fn trait-isa? [registry child parent]
  "Check if trait child is-a parent in the trait hierarchy."
  (isa? registry.hierarchy child parent))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-trait-registry
 : make-trait
 : add-trait!
 : trait-defined?
 : get-trait
 : list-traits
 : satisfies?
 : satisfies-all?
 : trait-isa?}
