
;; shapes/init.fnl
;; Central shape registry: all shape definitions
;;
;; This module creates and exports the shape-registry.
;; Shapes are named logical compositions of traits (OR of AND groups).
;;
;; No shapes are registered yet — behaviors do not use shaped inputs until
;; the "Migrate behavior input design to shapes" TODO is implemented.

(local {: make-shape-registry : make-shape : add-shape!} (require :sheaf.shape-registry))
(local {: trait-registry} (require :traits))


;; ============================================================================
;; Shape Registry
;; ============================================================================

(local shape-registry (make-shape-registry {:trait-registry trait-registry}))


;; ============================================================================
;; Shape Definitions
;; ============================================================================

(add-shape! shape-registry
  (make-shape :shape/url-routing-rules
              "URL routing configuration: browsers, fallback action, and ordered rules"
              [{:name :default :traits [:trait/has-url-routing-rules]}]))

(add-shape! shape-registry
  (make-shape :shape/window-state
              "Live index of all tracked windows by window-id"
              [{:name :default :traits [:trait/has-window-state]}]))


;; Export registry
{: shape-registry}
