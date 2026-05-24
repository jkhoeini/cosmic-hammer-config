
;; components/init.fnl
;; Central component registry: component-kind hierarchy + component type registration
;;
;; This module creates and exports the component-registry.
;; The hierarchy is accessible via component-registry.hierarchy

(local {: make-hierarchy : derive!} (require :lib.hierarchy))
(local {: make-component-registry} (require :sheaf.component-registry))
(local {: trait-registry} (require :traits))


;; ============================================================================
;; Component Kind Hierarchy
;; ============================================================================
;;
;; :component.kind/any                           ;; Root - all components derive from this
;; ├── :component.kind/space-indicator
;; ├── :component.kind/expose
;; ├── :component.kind/emacs
;; ├── :component.kind/reload-hammerspoon
;; └── :component.kind/compile-fennel

(local component-hierarchy (make-hierarchy))

(derive! component-hierarchy :component.kind/space-indicator :component.kind/any)
(derive! component-hierarchy :component.kind/expose :component.kind/any)
(derive! component-hierarchy :component.kind/emacs :component.kind/any)
(derive! component-hierarchy :component.kind/reload-hammerspoon :component.kind/any)
(derive! component-hierarchy :component.kind/compile-fennel :component.kind/any)


;; ============================================================================
;; Component Registry
;; ============================================================================

(local component-registry (make-component-registry {:hierarchy component-hierarchy
                                                    :trait-registry trait-registry}))


;; Export registry (hierarchy accessible via component-registry.hierarchy)
{: component-registry}
