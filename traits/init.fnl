
;; traits/init.fnl
;; Central trait registry: trait-kind hierarchy + all trait definitions
;;
;; This module creates and exports the trait-registry.
;; The hierarchy is accessible via trait-registry.hierarchy

(local {: make-hierarchy : derive!} (require :lib.hierarchy))
(local {: make-trait-registry : make-trait : add-trait!} (require :sheaf.trait-registry))

(local boolean? #(= (type $) :boolean))
(local number? #(= (type $) :number))
(local table? #(= (type $) :table))


(fn non-nil? [v] (not= nil v))


;; ============================================================================
;; Trait Kind Hierarchy
;; ============================================================================
;;
;; :trait.kind/any                           ;; Root - all traits derive from this
;; ├── :trait.kind/ui                        ;; Persistent UI element in state
;; │   ├── :trait/has-menubar
;; │   ├── :trait/has-expose
;; │   ├── :trait/has-chooser
;; │   └── :trait/has-canvas
;; │
;; ├── :trait.kind/windowing                 ;; Window management capabilities
;; │   ├── :trait/has-window-filter
;; │   ├── :trait/has-paper-wm-runtime
;; │   └── :trait/has-tiling-state
;; │
;; ├── :trait.kind/scheduling                ;; Timer-based operations
;; │   └── :trait/has-delayed-timer
;; │
;; └── :trait.kind/data                      ;; Pure config/data in state
;;     ├── :trait/has-url-routing-rules
;;     ├── :trait/has-url-history
;;     ├── :trait/has-window-state
;;     ├── :trait/has-desktop-layout
;;     └── :trait/has-mouse-window-management-state

(local trait-hierarchy (make-hierarchy))

;; --- Categories ---
(derive! trait-hierarchy :trait.kind/ui :trait.kind/any)
(derive! trait-hierarchy :trait.kind/windowing :trait.kind/any)
(derive! trait-hierarchy :trait.kind/scheduling :trait.kind/any)

;; --- UI ---
(derive! trait-hierarchy :trait/has-menubar :trait.kind/ui)
(derive! trait-hierarchy :trait/has-expose :trait.kind/ui)
(derive! trait-hierarchy :trait/has-chooser :trait.kind/ui)
(derive! trait-hierarchy :trait/has-canvas :trait.kind/ui)

;; --- Windowing ---
(derive! trait-hierarchy :trait/has-window-filter :trait.kind/windowing)
(derive! trait-hierarchy :trait/has-paper-wm-runtime :trait.kind/windowing)
(derive! trait-hierarchy :trait/has-tiling-state :trait.kind/windowing)

;; --- Scheduling ---
(derive! trait-hierarchy :trait/has-delayed-timer :trait.kind/scheduling)

;; --- Data ---
(derive! trait-hierarchy :trait.kind/data :trait.kind/any)
(derive! trait-hierarchy :trait/has-url-routing-rules :trait.kind/data)
(derive! trait-hierarchy :trait/has-url-history :trait.kind/data)
(derive! trait-hierarchy :trait/has-window-state :trait.kind/data)
(derive! trait-hierarchy :trait/has-desktop-layout :trait.kind/data)
(derive! trait-hierarchy :trait/has-mouse-window-management-state :trait.kind/data)


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
              {:menubar non-nil?}))

(add-trait! trait-registry
  (make-trait :trait/has-expose
              "Component state includes an hs.expose object"
              {:expose non-nil?}))

(add-trait! trait-registry
  (make-trait :trait/has-chooser
              "Component state includes an hs.chooser object"
              {:chooser non-nil?}))

(add-trait! trait-registry
  (make-trait :trait/has-canvas
              "Component state includes hs.canvas objects"
              {:active-canvas non-nil?}))

;; --- Windowing ---
(add-trait! trait-registry
  (make-trait :trait/has-window-filter
              "Component state includes an hs.window.filter"
              {:window-filter non-nil?}))

(add-trait! trait-registry
  (make-trait :trait/has-paper-wm-runtime
              "Component state owns PaperWM resources: handles, watchers, timers"
              {:active? boolean?
               :config table?
               :tiling-state table?
               :resources table?}
              (fn [state]
                (let [resources state.resources]
                  (and (= :table (type resources.windows))
                       (= :table (type resources.ui-watchers))
                       (= :table (type resources.watcher-restart-timers))
                       (= :table (type resources.frame-observations)))))))

(add-trait! trait-registry
  (make-trait :trait/has-tiling-state
              "Component state includes serializable PaperWM tiling facts"
              {:tiling-state table?}
              (fn [state]
                (let [tiling-state state.tiling-state]
                  (and (= :table (type tiling-state.spaces))
                       (= :table (type tiling-state.index)))))))

;; --- Scheduling ---
(add-trait! trait-registry
  (make-trait :trait/has-delayed-timer
              "Component state includes an hs.timer.delayed"
              {:timer non-nil?}))


;; --- Data ---
(add-trait! trait-registry
  (make-trait :trait/has-url-routing-rules
              "Component state includes URL routing configuration: browsers, fallback, and rules"
              {:browsers non-nil? :fallback non-nil? :rules non-nil?}))


(add-trait! trait-registry
  (make-trait :trait/has-url-history
              "Component state includes URL visit history"
              {:history non-nil?}))

(add-trait! trait-registry
  (make-trait :trait/has-window-state
              "Component state includes a map of tracked window states"
              {:windows non-nil?}))

(add-trait! trait-registry
  (make-trait :trait/has-desktop-layout
              "Component state includes the ordered desktop layout"
              {:all-spaces non-nil?}))

(add-trait! trait-registry
  (make-trait :trait/has-mouse-window-management-state
              "Component state tracks hover focus, Space changes, and delayed placement"
              {:pending-placement-timers non-nil?
               :hover-focus-window-ids non-nil?}))


;; Export registry (hierarchy accessible via trait-registry.hierarchy)
{: trait-registry}
