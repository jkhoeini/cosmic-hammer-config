
;; sheaf/command-registry.fnl
;; Data-oriented command registry - no global state.
;;
;; A command-registry is a data structure:
;;   {:commands {}            ; command-name -> command data
;;    :trait-registry tr}     ; for requires-traits validation
;;
;; A command is a data structure:
;;   {:name :expose.commands/toggle-show
;;    :description "Toggle the Expose window picker"
;;    :schema {}
;;    :requires-traits [:trait/has-expose]
;;    :fn (fn [component params] → new-state|nil)}
;;
;; Naming convention:
;;   :namespace.commands/action-name

(local {: trait-defined?} (require :sheaf.trait-registry))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-command-registry [opts]
  "Create a new command registry.
   opts:
     :trait-registry - for requires-traits validation (required)"
  (when (= nil opts.trait-registry)
    (error "make-command-registry: :trait-registry is required"))
  {:commands {}
   :trait-registry opts.trait-registry})


(fn make-command [name description opts]
  "Create a command data structure (pure, no validation).
   name: unique identifier (e.g. :expose.commands/toggle-show)
   description: human-readable description
   opts:
     :schema - table describing expected params shape (for documentation/validation)
     :requires-traits - list of traits target component must implement (default [])
     :fn - (fn [component params] → new-state|nil) - the command implementation (required)
   Returns: {:name :description :schema :requires-traits :fn}"
  (when (= nil opts.fn)
    (error (.. "make-command: :fn is required for " (tostring name))))
  {:name name
   :description description
   :schema (or opts.schema {})
   :requires-traits (or opts.requires-traits [])
   :fn opts.fn})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn add-command! [registry command]
  "Add a command to the registry. Mutates registry.
   Validates requires-traits against trait-registry."
  (let [name command.name]
    (when (= nil name)
      (error "add-command!: command must have a :name"))
    (when (not= nil (. registry.commands name))
      (error (.. "Command already registered: " (tostring name))))
    (each [_ trait-name (ipairs (or command.requires-traits []))]
      (when (not (trait-defined? registry.trait-registry trait-name))
        (error (.. "add-command! " (tostring name) ": trait '" (tostring trait-name) "' not found in trait-registry"))))
    (tset registry.commands name command)))


(fn command-defined? [registry name]
  "Check if a command is defined."
  (not= nil (. registry.commands name)))


(fn get-command [registry name]
  "Get a command by name."
  (. registry.commands name))


(fn list-commands [registry]
  "List all registered command names."
  (let [names []]
    (each [name _ (pairs registry.commands)]
      (table.insert names name))
    names))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-command-registry
 : make-command
 : add-command!
 : command-defined?
 : get-command
 : list-commands}
