
;; sheaf/shape-registry.fnl
;; Data-oriented shape registry - no global state.
;;
;; A shape-registry is a data structure:
;;   {:shapes {}              ; shape-name -> shape data
;;    :trait-registry tr}     ; for trait existence validation + conformance
;;
;; A shape is a data structure:
;;   {:name :shape/displayable
;;    :description "State that can be displayed"
;;    :alts [{:name :via-menubar :traits [:trait/has-menubar]}
;;           {:name :via-canvas  :traits [:trait/has-canvas]}]}
;;
;; Alternatives are OR: at least one must match.
;; Traits within an alternative are AND: all must hold.
;; An alt with empty :traits always matches (empty AND = true).
;; conforms? returns the first matched alt or nil.
;;
;; Naming convention:
;;   :shape/descriptor-name
;;
;; NOTE: Dispatcher and behavior-registry wiring for shaped inputs is a
;; separate TODO (see "Migrate behavior input design to shapes").

(local {: satisfies-all? : trait-defined?} (require :sheaf.trait-registry))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-shape-registry [opts]
  "Create a new shape registry.
   opts:
     :trait-registry - for trait existence validation and conformance (required)"
  (when (or (= nil opts) (= nil opts.trait-registry))
    (error "make-shape-registry: :trait-registry is required"))
  {:shapes {}
   :trait-registry opts.trait-registry})


(fn validate-alt [shape-name alt index seen-names]
  "Validate a single alternative within a shape. Mutates seen-names set.
   Checks: non-nil, table type, has :name, has :traits table, no duplicate name."
  (when (= nil alt)
    (error (.. "make-shape: alt at index " (tostring index)
               " is nil in " (tostring shape-name))))
  (when (not= :table (type alt))
    (error (.. "make-shape: alt at index " (tostring index)
               " is not a table in " (tostring shape-name))))
  (when (= nil alt.name)
    (error (.. "make-shape: alt at index " (tostring index)
               " has no :name in " (tostring shape-name))))
  (when (= nil alt.traits)
    (error (.. "make-shape: alt " (tostring alt.name)
               " has no :traits in " (tostring shape-name))))
  (when (not= :table (type alt.traits))
    (error (.. "make-shape: alt " (tostring alt.name)
               " :traits is not a table in " (tostring shape-name))))
  (when (. seen-names alt.name)
    (error (.. "make-shape: duplicate alt name " (tostring alt.name)
               " in " (tostring shape-name))))
  (tset seen-names alt.name true))


(fn make-shape [name description alts]
  "Create a shape data structure (pure, no cross-registry validation).
   name: unique identifier (e.g. :shape/displayable)
   description: human-readable description
   alts: [{:name kw :traits [trait-kw ...]} ...] - alternatives (OR semantics)
         Traits within an alt are AND. Empty :traits means always-match (fallback).
   Validates: name present, description present, alts non-empty, alt structure,
              no duplicate alt names.
   Returns: {:name :description :alts}"
  (when (= nil name)
    (error "make-shape: :name is required"))
  (when (= nil description)
    (error "make-shape: :description is required"))
  (when (or (= nil alts) (= 0 (length alts)))
    (error (.. "make-shape: :alts must not be empty for " (tostring name))))
  (let [seen-names {}]
    (each [i alt (ipairs alts)]
      (validate-alt name alt i seen-names)))
  {:name name
   :description description
   :alts alts})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn add-shape! [registry shape]
  "Add a shape to the registry. Mutates registry.
   Validates that all referenced traits exist in trait-registry."
  (let [name shape.name]
    (when (= nil name)
      (error "add-shape!: shape must have a :name"))
    (when (not= nil (. registry.shapes name))
      (error (.. "Shape already registered: " (tostring name))))
    (each [_ alt (ipairs shape.alts)]
      (each [_ trait-name (ipairs alt.traits)]
        (when (not (trait-defined? registry.trait-registry trait-name))
          (error (.. "add-shape! " (tostring name)
                     ": trait '" (tostring trait-name)
                     "' in alt '" (tostring alt.name)
                     "' not found in trait-registry")))))
    (tset registry.shapes name shape)))


(fn shape-defined? [registry name]
  "Check if a shape is defined."
  (not= nil (. registry.shapes name)))


(fn get-shape [registry name]
  "Get a shape by name."
  (. registry.shapes name))


(fn list-shapes [registry]
  "List all registered shape names."
  (let [names []]
    (each [name _ (pairs registry.shapes)]
      (table.insert names name))
    names))


(fn conforms? [registry shape-name state]
  "Check if state conforms to a shape.
   Tries each alternative in order (OR). Within each alt, all traits
   must be satisfied (AND). Empty :traits always matches.
   Returns the first matched alternative {:name :traits} or nil.
   Errors if shape-name is not registered."
  (let [shape (get-shape registry shape-name)]
    (when (= nil shape)
      (error (.. "conforms?: shape not found: " (tostring shape-name))))
    (var matched nil)
    (each [_ alt (ipairs shape.alts) &until matched]
      (when (satisfies-all? registry.trait-registry alt.traits (or state {}))
        (set matched alt)))
    matched))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-shape-registry
 : make-shape
 : add-shape!
 : shape-defined?
 : get-shape
 : list-shapes
 : conforms?}
