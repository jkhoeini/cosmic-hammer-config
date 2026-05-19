
;; traits/init.fnl
;; Central trait registry: trait-kind hierarchy + all trait definitions
;;
;; This module creates and exports the trait-registry.
;; The hierarchy is accessible via trait-registry.hierarchy

(local {: make-hierarchy : derive!} (require :lib.hierarchy))
(local {: make-trait-registry : make-trait : add-trait!} (require :sheaf.trait-registry))


(fn non-nil? [v] (not= nil v))


;; ============================================================================
;; Trait Kind Hierarchy
;; ============================================================================
;;
;; :trait.kind/any                           ;; Root - all traits derive from this
;; ├── :trait.kind/ui                        ;; Persistent UI element in state
;; │   ├── :trait/has-menubar
;; │   ├── :trait/has-expose
;; │   └── :trait/has-chooser
;; │
;; ├── :trait.kind/windowing                 ;; Window management capabilities
;; │   ├── :trait/has-window-filter
;; │   └── :trait/has-layout
;; │
;; └── :trait.kind/scheduling                ;; Timer-based operations
;;     └── :trait/has-delayed-timer

(local trait-hierarchy (make-hierarchy))

;; --- Categories ---
(derive! trait-hierarchy :trait.kind/ui :trait.kind/any)
(derive! trait-hierarchy :trait.kind/windowing :trait.kind/any)
(derive! trait-hierarchy :trait.kind/scheduling :trait.kind/any)

;; --- UI ---
(derive! trait-hierarchy :trait/has-menubar :trait.kind/ui)
(derive! trait-hierarchy :trait/has-expose :trait.kind/ui)
(derive! trait-hierarchy :trait/has-chooser :trait.kind/ui)

;; --- Windowing ---
(derive! trait-hierarchy :trait/has-window-filter :trait.kind/windowing)
(derive! trait-hierarchy :trait/has-layout :trait.kind/windowing)

;; --- Scheduling ---
(derive! trait-hierarchy :trait/has-delayed-timer :trait.kind/scheduling)


;; ============================================================================
;; Trait Registry
;; ============================================================================

(local trait-registry (make-trait-registry {:hierarchy trait-hierarchy}))


;; ============================================================================
;; Trait Definitions
;; ============================================================================

;; --- UI ---
(add-trait! trait-registry
  (make-trait :trait/has-menubar
              "Component state includes an hs.menubar object"
              {:schema {:menubar non-nil?}}))

(add-trait! trait-registry
  (make-trait :trait/has-expose
              "Component state includes an hs.expose object"
              {:schema {:expose non-nil?}}))

(add-trait! trait-registry
  (make-trait :trait/has-chooser
              "Component state includes an hs.chooser object"
              {:schema {:chooser non-nil?}}))

;; --- Windowing ---
(add-trait! trait-registry
  (make-trait :trait/has-window-filter
              "Component state includes an hs.window.filter"
              {:schema {:window-filter non-nil?}}))

(add-trait! trait-registry
  (make-trait :trait/has-layout
              "Component state includes window layout tables"
              {:schema {:window-list non-nil? :index-table non-nil?}}))

;; --- Scheduling ---
(add-trait! trait-registry
  (make-trait :trait/has-delayed-timer
              "Component state includes an hs.timer.delayed"
              {:schema {:timer non-nil?}}))


;; Export registry (hierarchy accessible via trait-registry.hierarchy)
{: trait-registry}
