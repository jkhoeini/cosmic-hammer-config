
;; components/init.fnl
;; Central component registry: component-kind hierarchy + component type registration
;;
;; This module creates and exports the component-registry and tag-registry.
;; The hierarchy is accessible via component-registry.hierarchy

(local {: make-hierarchy : derive!} (require :lib.hierarchy))
(local {: make-component-registry
        : add-component-type!
        : start-component!
        : make-instance-name} (require :sheaf.component-registry))
(local {: make-tag-registry : attach-tag!} (require :sheaf.tag-registry))
(local {: trait-registry} (require :traits))
(local {: source-registry} (require :event_sources))

;; Import component type data
(local {: space-indicator-type} (require :components.space-indicator))
(local {: expose-type} (require :components.expose))
(local {: emacs-type} (require :components.emacs))
(local {: reload-hammerspoon-type} (require :components.reload-hammerspoon))
(local {: compile-fennel-type} (require :components.compile-fennel))
(local {: config-watcher-type} (require :components.config-watcher))
(local {: window-watcher-type} (require :components.window-watcher))
(local {: app-watcher-type} (require :components.app-watcher))
(local {: window-border-type} (require :components.window-border))
(local {: url-dispatch-type} (require :components.url-dispatch))


;; ============================================================================
;; Component Kind Hierarchy
;; ============================================================================
;;
;; :component.kind/any                           ;; Root - all components derive from this
;; ├── :component.kind/space-indicator
;; ├── :component.kind/expose
;; ├── :component.kind/emacs
;; ├── :component.kind/reload-hammerspoon
;; ├── :component.kind/compile-fennel
;; ├── :component.kind/config-watcher
;; ├── :component.kind/window-watcher
;; ├── :component.kind/app-watcher
;; ├── :component.kind/window-border
;; └── :component.kind/url-dispatch

(local component-hierarchy (make-hierarchy))

(derive! component-hierarchy :component.kind/space-indicator :component.kind/any)
(derive! component-hierarchy :component.kind/expose :component.kind/any)
(derive! component-hierarchy :component.kind/emacs :component.kind/any)
(derive! component-hierarchy :component.kind/reload-hammerspoon :component.kind/any)
(derive! component-hierarchy :component.kind/compile-fennel :component.kind/any)
(derive! component-hierarchy :component.kind/config-watcher :component.kind/any)
(derive! component-hierarchy :component.kind/window-watcher :component.kind/any)
(derive! component-hierarchy :component.kind/app-watcher :component.kind/any)
(derive! component-hierarchy :component.kind/window-border :component.kind/any)
(derive! component-hierarchy :component.kind/url-dispatch :component.kind/any)

;; Derive concrete types from their kinds
(derive! component-hierarchy :component.type/space-indicator :component.kind/space-indicator)
(derive! component-hierarchy :component.type/expose :component.kind/expose)
(derive! component-hierarchy :component.type/emacs :component.kind/emacs)
(derive! component-hierarchy :component.type/reload-hammerspoon :component.kind/reload-hammerspoon)
(derive! component-hierarchy :component.type/compile-fennel :component.kind/compile-fennel)
(derive! component-hierarchy :component.type/config-watcher :component.kind/config-watcher)
(derive! component-hierarchy :component.type/window-watcher :component.kind/window-watcher)
(derive! component-hierarchy :component.type/app-watcher :component.kind/app-watcher)
(derive! component-hierarchy :component.type/window-border :component.kind/window-border)
(derive! component-hierarchy :component.type/url-dispatch :component.kind/url-dispatch)


;; ============================================================================
;; Tag Registry (created before component-registry so it can be passed in)
;; ============================================================================

(local tag-registry (make-tag-registry))


;; ============================================================================
;; Component Registry
;; ============================================================================

(local component-registry (make-component-registry {:hierarchy component-hierarchy
                                                    :trait-registry trait-registry
                                                    :source-registry source-registry
                                                    :tag-registry tag-registry}))


;; ============================================================================
;; Type Registration
;; ============================================================================

(add-component-type! component-registry space-indicator-type)
(add-component-type! component-registry expose-type)
(add-component-type! component-registry emacs-type)
(add-component-type! component-registry reload-hammerspoon-type)
(add-component-type! component-registry compile-fennel-type)
(add-component-type! component-registry config-watcher-type)
(add-component-type! component-registry window-watcher-type)
(add-component-type! component-registry app-watcher-type)
(add-component-type! component-registry window-border-type)
(add-component-type! component-registry url-dispatch-type)


;; ============================================================================
;; Instance Names
;; ============================================================================

(local space-indicator-name (make-instance-name :component.type/space-indicator "main"))
(local expose-name (make-instance-name :component.type/expose "main"))
(local emacs-name (make-instance-name :component.type/emacs "main"))
(local reload-hammerspoon-name (make-instance-name :component.type/reload-hammerspoon "main"))
(local compile-fennel-name (make-instance-name :component.type/compile-fennel "main"))
(local config-watcher-name (make-instance-name :component.type/config-watcher "main"))
(local window-watcher-name (make-instance-name :component.type/window-watcher "main"))
(local app-watcher-name (make-instance-name :component.type/app-watcher "main"))
(local window-border-name (make-instance-name :component.type/window-border "main"))
(local url-dispatch-name (make-instance-name :component.type/url-dispatch "main"))


;; ============================================================================
;; Instance Startup (auto-creates owned source instances via start-component!)
;; ============================================================================

(start-component! component-registry :component.type/space-indicator space-indicator-name {})
(start-component! component-registry :component.type/expose expose-name {})
(start-component! component-registry :component.type/emacs emacs-name {})
(start-component! component-registry :component.type/reload-hammerspoon reload-hammerspoon-name {})
(start-component! component-registry :component.type/compile-fennel compile-fennel-name {})
(start-component! component-registry :component.type/config-watcher config-watcher-name {})
(start-component! component-registry :component.type/window-watcher window-watcher-name {})
(start-component! component-registry :component.type/app-watcher app-watcher-name {})
(start-component! component-registry :component.type/window-border window-border-name
                  {:active-color "0xffe1e3e4" :inactive-color "0xff494d64" :width 5 :corner-radius 9})
(start-component! component-registry :component.type/url-dispatch url-dispatch-name {})


;; ============================================================================
;; Component Tag Attachment
;; ============================================================================

(attach-tag! tag-registry space-indicator-name :tag/space-indicator)
(attach-tag! tag-registry expose-name :tag/expose)
(attach-tag! tag-registry emacs-name :tag/emacs)
(attach-tag! tag-registry reload-hammerspoon-name :tag/reload-hammerspoon)
(attach-tag! tag-registry compile-fennel-name :tag/compile-fennel)
(attach-tag! tag-registry window-border-name :tag/window-border)
(attach-tag! tag-registry url-dispatch-name :tag/url-dispatch)


;; Export registries (hierarchy accessible via component-registry.hierarchy)
{: component-registry : tag-registry}
