
;; lib/command-registry.fnl
;; Data-oriented command registry - no global state.
;;
;; A command-registry is a data structure:
;;   {:commands {}}  ; command-name -> command data
;;
;; A command is a data structure:
;;   {:name :expose.commands/toggle-show
;;    :description "Toggle the Expose window picker"
;;    :schema {}
;;    :fn (fn [params] ...)}
;;
;; Naming convention:
;;   :namespace.commands/action-name


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-command-registry []
  "Create a new command registry.
   Commands are self-contained — no dependencies on other registries."
  {:commands {}})


(fn make-command [name description opts]
  "Create a command data structure (pure, no validation).
   name: unique identifier (e.g. :expose.commands/toggle-show)
   description: human-readable description
   opts:
     :schema - table describing expected params shape (for documentation/validation)
     :fn - (fn [params] ...) - the command implementation (required)
   Returns: {:name :description :schema :fn}"
  (when (= nil opts.fn)
    (error (.. "make-command: :fn is required for " (tostring name))))
  {:name name
   :description description
   :schema (or opts.schema {})
   :fn opts.fn})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn add-command! [registry command]
  "Add a command to the registry. Mutates registry.
   command must have a :name field."
  (let [name command.name]
    (when (= nil name)
      (error "add-command!: command must have a :name"))
    (when (not= nil (. registry.commands name))
      (error (.. "Command already registered: " (tostring name))))
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


(fn invoke-command! [registry name params]
  "Invoke a command by name with the given params.
   Errors if the command is not found."
  (let [command (get-command registry name)]
    (when (= nil command)
      (error (.. "invoke-command!: command not found: " (tostring name))))
    (command.fn (or params {}))))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-command-registry
 : make-command
 : add-command!
 : command-defined?
 : get-command
 : list-commands
 : invoke-command!}
