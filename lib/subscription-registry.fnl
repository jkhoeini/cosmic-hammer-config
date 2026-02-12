
;; lib/subscription-registry.fnl
;; Manages subscription definitions - connections between behaviors and source+event pairs.
;; Data-oriented subscription registry - no global state.
;;
;; A subscription-registry is a data structure:
;;   {:subscriptions {}        ; subscription name -> subscription data
;;    :index {}                ; source -> event-selector -> #{behavior-names}
;;    :event-registry er       ; for hierarchy lookups and event validation
;;    :behavior-registry br    ; for behavior validation
;;    :source-registry sr}     ; for source instance validation
;;
;; A subscription is a data structure:
;;   {:name        :sub/my-subscription
;;    :description "Human-readable description"
;;    :behavior    :my-behavior
;;    :event-selector  :event.kind/something
;;    :source-selector :my-source
;;    :target-selector :my-target  ; optional, for future component targeting
;;    :require-tags []   ; placeholder for future
;;    :exclude-tags []}  ; placeholder for future

(local {: hash-set : conj : disj : into : seq : filter} (require :lib.cljlib-shim))
(local {: valid-event-selector?} (require :lib.event-registry))
(local {: behavior-defined?} (require :lib.behavior-registry))
(local {: source-instance-exists?} (require :lib.source-registry))
(local {: ancestors} (require :lib.hierarchy))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-subscription-registry [opts]
  "Create a new subscription registry.
   opts:
     :event-registry    - for event-selector validation and hierarchy lookups (required)
     :behavior-registry - for behavior validation (required)
     :source-registry   - for source instance validation (required)"
  (when (= nil opts.event-registry)
    (error "make-subscription-registry: :event-registry is required"))
  (when (= nil opts.behavior-registry)
    (error "make-subscription-registry: :behavior-registry is required"))
  (when (= nil opts.source-registry)
    (error "make-subscription-registry: :source-registry is required"))
  {:subscriptions {}
   :index {}
   :event-registry opts.event-registry
   :behavior-registry opts.behavior-registry
   :source-registry opts.source-registry})


;; ============================================================================
;; Index Management (internal)
;; ============================================================================

(fn index-add! [registry subscription]
  "Add subscription's behavior to the index."
  (let [source subscription.source-selector
        event subscription.event-selector
        behavior subscription.behavior]
    (when (= nil (. registry.index source))
      (tset registry.index source {}))
    (when (= nil (. registry.index source event))
      (tset registry.index source event (hash-set)))
    (tset registry.index source event
          (conj (. registry.index source event) behavior))))


(fn index-remove! [registry subscription]
  "Remove subscription's behavior from the index."
  (let [source subscription.source-selector
        event subscription.event-selector
        behavior subscription.behavior
        behavior-set (?. registry.index source event)]
    (when behavior-set
      (tset registry.index source event
            (disj behavior-set behavior)))))


;; ============================================================================
;; Validation
;; ============================================================================

(fn validate-required-field! [name opts field]
  "Validate that a required field exists in opts. Errors if missing."
  (when (= nil (. opts field))
    (error (.. "define-subscription! " (tostring name)
               ": missing required field " (tostring field)))))


(fn validate-subscription! [registry name opts]
  "Validate all subscription requirements. Errors on failure."
  ;; Check required fields
  (validate-required-field! name opts :description)
  (validate-required-field! name opts :behavior)
  (validate-required-field! name opts :event-selector)
  (validate-required-field! name opts :source-selector)
  
  ;; Check name is unique
  (when (not= nil (. registry.subscriptions name))
    (error (.. "Subscription already defined: " (tostring name))))
  
  ;; Check behavior exists
  (when (not (behavior-defined? registry.behavior-registry opts.behavior))
    (error (.. "define-subscription! " (tostring name)
               ": behavior not found: " (tostring opts.behavior))))
  
  ;; Check source exists
  (when (not (source-instance-exists? registry.source-registry opts.source-selector))
    (error (.. "define-subscription! " (tostring name)
               ": source instance not found: " (tostring opts.source-selector))))
  
  ;; Check event-selector is valid
  (when (not (valid-event-selector? registry.event-registry opts.event-selector))
    (error (.. "define-subscription! " (tostring name)
               ": invalid event-selector: " (tostring opts.event-selector)))))


;; ============================================================================
;; Public API
;; ============================================================================

(fn define-subscription! [registry name opts]
  "Define a named subscription connecting a behavior to source+events.
   opts:
     :description     - human-readable description (required)
     :behavior        - behavior name to invoke (required)
     :event-selector  - event name or kind to match (required)
      :source-selector - event source name to match (required)
      :target-selector - target component for commands (optional, for future component targeting)
      :require-tags    - tags source must have (optional, placeholder)
      :exclude-tags    - tags source must NOT have (optional, placeholder)"
  (validate-subscription! registry name opts)
  (let [subscription {:name name
                      :description opts.description
                      :behavior opts.behavior
                      :event-selector opts.event-selector
                      :source-selector opts.source-selector
                      :target-selector opts.target-selector
                      :require-tags (or opts.require-tags [])
                      :exclude-tags (or opts.exclude-tags [])}]
    (tset registry.subscriptions name subscription)
    (index-add! registry subscription)
    (print (.. "[INFO] Defined subscription: " (tostring name)))))


(fn remove-subscription! [registry name]
  "Remove a subscription by name. Errors if subscription does not exist."
  (let [subscription (. registry.subscriptions name)]
    (when (= nil subscription)
      (error (.. "Subscription not found: " (tostring name))))
    (index-remove! registry subscription)
    (tset registry.subscriptions name nil)
    (print (.. "[INFO] Removed subscription: " (tostring name)))))


(fn get-subscription [registry name]
  "Get subscription data by name. Returns nil if not found."
  (. registry.subscriptions name))


(fn list-subscriptions [registry]
  "List all subscription names."
  (let [names []]
    (each [name _ (pairs registry.subscriptions)]
      (table.insert names name))
    names))


(fn subscription-defined? [registry name]
  "Check if a subscription exists."
  (not= nil (. registry.subscriptions name)))


(fn get-subscribed-behaviors [registry source event-name]
  "Get behavior names subscribed to this source+event.
   Checks subscriptions for the source and all ancestor event-selectors.
   Returns a sequence of behavior names (may contain duplicates if same
   behavior subscribed via multiple selectors)."
  (let [event-selectors (conj (ancestors registry.event-registry.hierarchy event-name) event-name)
        source-subs (or (. registry.index source) {})
        all-behavior-names (accumulate [result (hash-set)
                                        _ e (pairs event-selectors)]
                             (into result (or (. source-subs e) [])))]
    (seq all-behavior-names)))


{: make-subscription-registry
 : define-subscription!
 : remove-subscription!
 : get-subscription
 : list-subscriptions
 : subscription-defined?
 : get-subscribed-behaviors}
