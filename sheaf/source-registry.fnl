
;; lib/source-registry.fnl
;; Manages event source types and instances.
;;
;; A source type is a blueprint: it defines what config is needed and how to start/stop.
;; A source instance is a running source with a specific config.
;;
;; Naming convention:
;;   Type:     :event-source.type/file-watcher
;;   Instance: :event-source.file-watcher/config-dir

(local {: dispatch-event!} (require :sheaf.event-registry))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-source-registry [opts]
  "Create a new source registry.
   opts:
     :event-registry - the event registry for dispatching (required)"
  (when (= nil opts.event-registry)
    (error "make-source-registry: :event-registry is required"))
  {:types {}
   :instances {}
   :event-registry opts.event-registry})


(fn make-source-type [type-name description opts]
  "Create a source type data structure.
   type-name: unique identifier (e.g. :event-source.type/file-watcher)
   description: human-readable description
   opts:
     :config-schema - table describing expected config shape (for documentation/validation)
     :emits - list of event names this source can emit
     :start-fn - (fn [self emit] ...) -> state - called to start the source
     :stop-fn - (fn [state] ...) - called to stop the source (optional)
   Returns: {:name :description :config-schema :emits :start-fn :stop-fn}"
  (when (= nil opts.start-fn)
    (error (.. "make-source-type: :start-fn is required for " (tostring type-name))))
  {:name type-name
   :description description
   :config-schema (or opts.config-schema {})
   :emits (or opts.emits [])
   :start-fn opts.start-fn
   :stop-fn opts.stop-fn})


;; ============================================================================
;; Source Type API
;; ============================================================================

(fn add-source-type! [registry source-type]
  "Add a source type to the registry. Mutates registry.
   source-type must have a :name field."
  (let [type-name source-type.name]
    (when (= nil type-name)
      (error "add-source-type!: source-type must have a :name"))
    (when (not= nil (. registry.types type-name))
      (error (.. "Source type already registered: " (tostring type-name))))
    (tset registry.types type-name source-type)))


(fn source-type-defined? [registry type-name]
  "Check if a source type has been defined."
  (not= nil (. registry.types type-name)))


(fn get-source-type [registry type-name]
  "Get a source type definition by name."
  (. registry.types type-name))


(fn list-source-types [registry]
  "List all registered source type names."
  (let [names []]
    (each [name _ (pairs registry.types)]
      (table.insert names name))
    names))


;; ============================================================================
;; Source Instance API
;; ============================================================================

(fn source-instance-exists? [registry instance-name]
  "Check if a source instance exists."
  (not= nil (. registry.instances instance-name)))


(fn get-source-instance [registry instance-name]
  "Get a source instance by name."
  (. registry.instances instance-name))


(fn list-source-instances [registry]
  "List all running source instance names."
  (let [names []]
    (each [name _ (pairs registry.instances)]
      (table.insert names name))
    names))


(fn start-event-source! [registry instance-name type-name config]
  "Start a new instance of an event source type.
   instance-name: unique name for this instance (e.g. :event-source.file-watcher/config-dir)
   type-name: the source type to instantiate (e.g. :event-source.type/file-watcher)
   config: configuration for this instance"
  (when (source-instance-exists? registry instance-name)
    (error (.. "Source instance already exists: " (tostring instance-name))))
  (let [source-type (get-source-type registry type-name)]
    (when (= nil source-type)
      (error (.. "Source type not found: " (tostring type-name))))
    (let [self {:name instance-name
                :type type-name
                :config (or config {})}
          ;; Create an emit function that dispatches with this instance as source
          emit (fn [event-name event-data]
                 (dispatch-event! registry.event-registry event-name instance-name event-data))
          ;; Call start-fn to get state
          state (source-type.start-fn self emit)]
      (tset registry.instances instance-name
            {:type type-name
             :config (or config {})
             :state state})
      (print (.. "[INFO] Started source instance: " (tostring instance-name))))))


(fn stop-event-source! [registry instance-name]
  "Stop a running event source instance."
  (let [instance (get-source-instance registry instance-name)]
    (when (= nil instance)
      (print (.. "[WARN] stop-event-source!: instance not found: " (tostring instance-name)))
      (lua "return nil"))
    (let [source-type (get-source-type registry instance.type)]
      (when source-type.stop-fn
        (source-type.stop-fn instance.state))
      (tset registry.instances instance-name nil)
      (print (.. "[INFO] Stopped source instance: " (tostring instance-name))))))


(fn stop-all-event-sources! [registry]
  "Stop all running event source instances."
  (let [names (list-source-instances registry)]
    (each [_ instance-name (ipairs names)]
      (stop-event-source! registry instance-name))))


{: make-source-registry
 : make-source-type
 : add-source-type!
 : source-type-defined?
 : get-source-type
 : list-source-types
 : source-instance-exists?
 : get-source-instance
 : list-source-instances
 : start-event-source!
 : stop-event-source!
 : stop-all-event-sources!}
