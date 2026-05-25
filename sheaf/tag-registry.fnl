
;; sheaf/tag-registry.fnl
;; Data-oriented tag registry - no global state.
;;
;; A tag-registry is a data structure:
;;   {:instance-tags {}    ; instance-name -> #{tags}        (forward index)
;;    :tag-instances {}}   ; tag -> #{instance-names}        (reverse index)
;;
;; Tags are simple keyword labels attached to component instances.
;; They are the primary wiring mechanism — subscriptions use source-tag
;; and target-tag to select which components participate.
;;
;; Both indexes use hash-sets as values. The reverse index enables
;; O(1) lookup from tag to the set of instances carrying that tag.

(local {: hash-set : conj : disj : contains? : seq} (require :lib.cljlib-shim))


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-tag-registry []
  "Create a new tag registry.
   Returns: {:instance-tags {} :tag-instances {}}"
  {:instance-tags {}
   :tag-instances {}})


;; ============================================================================
;; Registry API
;; ============================================================================

(fn attach-tag! [registry instance-name tag]
  "Attach a tag to a component instance. Mutates both indexes.
   Idempotent — attaching an already-attached tag is a no-op."
  (when (= nil instance-name)
    (error "attach-tag!: instance-name must not be nil"))
  (when (= nil tag)
    (error "attach-tag!: tag must not be nil"))
  (let [inst-tags (or (. registry.instance-tags instance-name) (hash-set))
        tag-insts (or (. registry.tag-instances tag) (hash-set))]
    (tset registry.instance-tags instance-name (conj inst-tags tag))
    (tset registry.tag-instances tag (conj tag-insts instance-name))))


(fn detach-tag! [registry instance-name tag]
  "Detach a tag from a component instance. Mutates both indexes.
   Idempotent — detaching a non-attached tag is a no-op.
   Prunes empty sets to avoid tombstones."
  (let [inst-tags (. registry.instance-tags instance-name)
        tag-insts (. registry.tag-instances tag)]
    (when inst-tags
      (let [new-set (disj inst-tags tag)]
        (tset registry.instance-tags instance-name
              (when (seq new-set) new-set))))
    (when tag-insts
      (let [new-set (disj tag-insts instance-name)]
        (tset registry.tag-instances tag
              (when (seq new-set) new-set))))))


(fn get-tags [registry instance-name]
  "Get the set of tags for an instance.
   Returns empty set if instance has no tags."
  (or (. registry.instance-tags instance-name) (hash-set)))


(fn components-with-tag [registry tag]
  "Get the set of instance-names that have a given tag.
   Returns empty set if no instances have this tag.
   This is the O(1) reverse lookup."
  (or (. registry.tag-instances tag) (hash-set)))


(fn tag-attached? [registry instance-name tag]
  "Check if a specific tag is attached to a specific instance."
  (let [inst-tags (. registry.instance-tags instance-name)]
    (if inst-tags
        (contains? inst-tags tag)
        false)))


;; ============================================================================
;; Exports
;; ============================================================================

{: make-tag-registry
 : attach-tag!
 : detach-tag!
 : get-tags
 : components-with-tag
 : tag-attached?}
