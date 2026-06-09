
;; shapes/init.fnl
;; Central shape registry: all shape definitions
;;
;; This module creates and exports the shape-registry.
;; Shapes are named logical compositions of traits (OR of AND groups).
;;
;; No shapes are registered yet — behaviors do not use shaped inputs until
;; the "Migrate behavior input design to shapes" TODO is implemented.

(local {: make-shape-registry} (require :sheaf.shape-registry))
(local {: trait-registry} (require :traits))


;; ============================================================================
;; Shape Registry
;; ============================================================================

(local shape-registry (make-shape-registry {:trait-registry trait-registry}))


;; ============================================================================
;; Shape Definitions
;; ============================================================================

;; (Shapes will be defined here as behaviors declare shaped inputs.)


;; Export registry
{: shape-registry}
