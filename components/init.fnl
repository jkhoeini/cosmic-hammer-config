
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
(local {: make-tag-registry : attach-tag!} (require :sheaf.tag-registry))
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
;; Instance Names
;; ============================================================================

(local space-indicator-name (make-instance-name :component.type/space-indicator "main"))
(local expose-name (make-instance-name :component.type/expose "main"))
(local emacs-name (make-instance-name :component.type/emacs "main"))
(local reload-hammerspoon-name (make-instance-name :component.type/reload-hammerspoon "main"))
(local compile-fennel-name (make-instance-name :component.type/compile-fennel "main"))


;; ============================================================================
;; Instance Startup
;; ============================================================================

(start-component! component-registry :component.type/space-indicator space-indicator-name {})
(start-component! component-registry :component.type/expose expose-name {})
(start-component! component-registry :component.type/emacs emacs-name {})
(start-component! component-registry :component.type/reload-hammerspoon reload-hammerspoon-name {})
(start-component! component-registry :component.type/compile-fennel compile-fennel-name {})


;; ============================================================================
;; Tag Registry
;; ============================================================================

(local tag-registry (make-tag-registry))


;; ============================================================================
;; Tag Attachment
;; ============================================================================

(attach-tag! tag-registry space-indicator-name :tag/space-indicator)
(attach-tag! tag-registry expose-name :tag/expose)
(attach-tag! tag-registry emacs-name :tag/emacs)
(attach-tag! tag-registry reload-hammerspoon-name :tag/reload-hammerspoon)
(attach-tag! tag-registry compile-fennel-name :tag/compile-fennel)


;; Export registries (hierarchy accessible via component-registry.hierarchy)
{: component-registry : tag-registry}
