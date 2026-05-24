
;; components/init.fnl
;; Central component registry: component-kind hierarchy + component type registration
;;
;; This module creates and exports the component-registry.
;; The hierarchy is accessible via component-registry.hierarchy

(local {: make-hierarchy : derive!} (require :lib.hierarchy))
(local {: make-component-registry
        : add-component-type!
        : start-component!
        : make-instance-name} (require :sheaf.component-registry))
(local {: trait-registry} (require :traits))

;; Import component type data
(local {: space-indicator-type} (require :components.space-indicator))
(local {: expose-type} (require :components.expose))
(local {: emacs-type} (require :components.emacs))
(local {: reload-hammerspoon-type} (require :components.reload-hammerspoon))
(local {: compile-fennel-type} (require :components.compile-fennel))


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

;; Derive concrete types from their kinds
(derive! component-hierarchy :component.type/space-indicator :component.kind/space-indicator)
(derive! component-hierarchy :component.type/expose :component.kind/expose)
(derive! component-hierarchy :component.type/emacs :component.kind/emacs)
(derive! component-hierarchy :component.type/reload-hammerspoon :component.kind/reload-hammerspoon)
(derive! component-hierarchy :component.type/compile-fennel :component.kind/compile-fennel)


;; ============================================================================
;; Component Registry
;; ============================================================================

(local component-registry (make-component-registry {:hierarchy component-hierarchy
                                                    :trait-registry trait-registry}))


;; ============================================================================
;; Type Registration
;; ============================================================================

(add-component-type! component-registry space-indicator-type)
(add-component-type! component-registry expose-type)
(add-component-type! component-registry emacs-type)
(add-component-type! component-registry reload-hammerspoon-type)
(add-component-type! component-registry compile-fennel-type)


;; ============================================================================
;; Instance Startup
;; ============================================================================

(start-component! component-registry
                  :component.type/space-indicator
                  (make-instance-name :component.type/space-indicator "main")
                  {})
(start-component! component-registry
                  :component.type/expose
                  (make-instance-name :component.type/expose "main")
                  {})
(start-component! component-registry
                  :component.type/emacs
                  (make-instance-name :component.type/emacs "main")
                  {})
(start-component! component-registry
                  :component.type/reload-hammerspoon
                  (make-instance-name :component.type/reload-hammerspoon "main")
                  {})
(start-component! component-registry
                  :component.type/compile-fennel
                  (make-instance-name :component.type/compile-fennel "main")
                  {})


;; Export registry (hierarchy accessible via component-registry.hierarchy)
{: component-registry}
