
;; traits/init.fnl
;; Central trait registry: trait-kind hierarchy + all trait definitions
;;
;; This module creates and exports the trait-registry.
;; The hierarchy is accessible via trait-registry.hierarchy

(local {: make-hierarchy} (require :lib.hierarchy))
(local {: make-trait-registry} (require :sheaf.trait-registry))


;; ============================================================================
;; Trait Kind Hierarchy
;; ============================================================================
;;
;; :trait.kind/any                           ;; Root - all traits derive from this

(local trait-hierarchy (make-hierarchy))


;; ============================================================================
;; Trait Registry
;; ============================================================================

(local trait-registry (make-trait-registry {:hierarchy trait-hierarchy}))


;; Export registry (hierarchy accessible via trait-registry.hierarchy)
{: trait-registry}
