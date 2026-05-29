
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
;;    :attrs {:menubar (fn [v] (not= nil v))}
;;    :pred nil}
;;
;; Attrs is a map of {key -> predicate-fn}. satisfies? checks that every
;; attr predicate passes, then checks optional whole-state :pred.
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


(fn trait-attrs [trait]
  "Return a trait's attr contract. Supports legacy :schema trait data."
  (or trait.attrs trait.schema))


(fn normalize-attrs [attrs]
  "Return attrs from the new direct form or legacy {:schema attrs} form."
  (or (?. attrs :attrs) (?. attrs :schema) attrs))


(fn normalize-pred [attrs pred]
  "Return the optional whole-state predicate from the new or legacy form."
  (or pred (?. attrs :pred)))


(fn make-trait [name description attrs ?pred]
  "Create a trait data structure (pure, no validation).
   name: unique identifier (e.g. :trait/has-menubar)
   description: human-readable description
   attrs: {key -> predicate-fn} defining required state attrs (required)
   ?pred: optional predicate over the whole state
   Returns: {:name :description :attrs :pred}"
  (let [normalized-attrs (normalize-attrs attrs)
        normalized-pred (normalize-pred attrs ?pred)]
    (when (= nil normalized-attrs)
      (error (.. "make-trait: attrs are required for " (tostring name))))
    {:name name
     :description description
     :attrs normalized-attrs
     :pred normalized-pred}))


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
  "Check if state satisfies a trait's attr contract.
   Every attr predicate must pass, then optional :pred must pass.
   Returns true if all checks pass, false otherwise."
  (let [trait (get-trait registry trait-name)]
    (when (= nil trait)
      (error (.. "satisfies?: trait not found: " (tostring trait-name))))
    (var ok true)
    (each [key pred (pairs (trait-attrs trait)) &until (not ok)]
      (let [val (. (or state {}) key)]
        (when (not (pred val))
          (set ok false))))
    (when (and ok trait.pred (not (trait.pred (or state {}))))
      (set ok false))
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
