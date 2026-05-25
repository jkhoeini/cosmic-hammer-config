
;; sheaf/subscription-registry.fnl
;; Manages subscription definitions - connections between behaviors and tag+event pairs.
;; Data-oriented subscription registry - no global state.
;;
;; A subscription-registry is a data structure:
;;   {:subscriptions {}        ; subscription name -> subscription data
;;    :index {}                ; tag -> event-selector -> #{behavior-names}
;;    :event-registry er       ; for hierarchy lookups and event validation
;;    :behavior-registry br    ; for behavior validation
;;    :tag-registry tr}        ; for tag lookups
;;
;; A subscription is a data structure:
;;   {:name        :sub/my-subscription
;;    :description "Human-readable description"
;;    :behavior    :my-behavior
;;    :event-selector  :event.kind/something
;;    :source-tag  :tag/my-tag
;;    :target-tag  :tag/my-target}  ; optional, for future component targeting

(local {: hash-set : conj : disj : into : seq} (require :lib.cljlib-shim))
(local {: valid-event-selector?} (require :sheaf.event-registry))
(local {: behavior-defined?} (require :sheaf.behavior-registry))
(local {: get-tags} (require :sheaf.tag-registry))
(local {: ancestors} (require :lib.hierarchy))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-subscription-registry [opts]
  "Create a new subscription registry.
   opts:
     :event-registry    - for event-selector validation and hierarchy lookups (required)
     :behavior-registry - for behavior validation (required)
     :tag-registry      - for tag lookups (required)"
  (when (= nil opts.event-registry)
    (error "make-subscription-registry: :event-registry is required"))
  (when (= nil opts.behavior-registry)
    (error "make-subscription-registry: :behavior-registry is required"))
  (when (= nil opts.tag-registry)
    (error "make-subscription-registry: :tag-registry is required"))
  {:subscriptions {}
   :index {}
   :event-registry opts.event-registry
   :behavior-registry opts.behavior-registry
   :tag-registry opts.tag-registry})


;; ============================================================================
;; Index Management (internal)
;; ============================================================================

(fn index-add! [registry subscription]
  "Add subscription's behavior to the index."
  (let [tag subscription.source-tag
        event subscription.event-selector
        behavior subscription.behavior]
    (when (= nil (. registry.index tag))
      (tset registry.index tag {}))
    (when (= nil (. registry.index tag event))
      (tset registry.index tag event (hash-set)))
    (tset registry.index tag event
          (conj (. registry.index tag event) behavior))))


(fn index-remove! [registry subscription]
  "Remove subscription's behavior from the index.
   Prunes empty sets to avoid tombstones."
  (let [tag subscription.source-tag
        event subscription.event-selector
        behavior subscription.behavior
        behavior-set (?. registry.index tag event)]
    (when behavior-set
      (let [new-set (disj behavior-set behavior)]
        (tset registry.index tag event
              (when (seq new-set) new-set)))
      (when (= nil (. registry.index tag event))
        (when (= nil (next (. registry.index tag)))
          (tset registry.index tag nil))))))


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
  (validate-required-field! name opts :source-tag)

  ;; Check name is unique
  (when (not= nil (. registry.subscriptions name))
    (error (.. "Subscription already defined: " (tostring name))))

  ;; Check behavior exists
  (when (not (behavior-defined? registry.behavior-registry opts.behavior))
    (error (.. "define-subscription! " (tostring name)
               ": behavior not found: " (tostring opts.behavior))))

  ;; Check event-selector is valid
  (when (not (valid-event-selector? registry.event-registry opts.event-selector))
    (error (.. "define-subscription! " (tostring name)
               ": invalid event-selector: " (tostring opts.event-selector)))))


;; ============================================================================
;; Public API
;; ============================================================================

(fn define-subscription! [registry name opts]
  "Define a named subscription connecting a behavior to tag+events.
   opts:
     :description     - human-readable description (required)
     :behavior        - behavior name to invoke (required)
     :event-selector  - event name or kind to match (required)
     :source-tag      - tag to match on source instances (required)
     :target-tag      - target tag for commands (optional)"
  (validate-subscription! registry name opts)
  (let [subscription {:name name
                      :description opts.description
                      :behavior opts.behavior
                      :event-selector opts.event-selector
                      :source-tag opts.source-tag
                      :target-tag opts.target-tag}]
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


(fn get-subscribed-behaviors [registry source-instance-name event-name]
  "Get behavior names subscribed to this source+event.
   Looks up the source instance's tags, then checks subscriptions for each tag
   and all ancestor event-selectors.
   Returns a sequence of behavior names (deduplicated)."
  (let [tags (get-tags registry.tag-registry source-instance-name)
        event-selectors (conj (ancestors registry.event-registry.hierarchy event-name) event-name)
        all-behavior-names (accumulate [result (hash-set)
                                        tag _ (pairs tags)]
                             (let [tag-subs (or (. registry.index tag) {})]
                               (accumulate [inner result
                                            _ e (pairs event-selectors)]
                                 (into inner (or (. tag-subs e) (hash-set))))))]
    (seq all-behavior-names)))


{: make-subscription-registry
 : define-subscription!
 : remove-subscription!
 : get-subscription
 : list-subscriptions
 : subscription-defined?
 : get-subscribed-behaviors}
