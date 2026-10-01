;; PaperWM component state satisfies its declared traits across its lifecycle,
;; honors instantiation choices, and diagnostics never leak mutable state.

(local noop #nil)

(set _G.hs
     {:eventtap {:leftClick noop}
      :geometry {:rect {} :rectMidPoint (fn [] {})}
      :mouse {:absolutePosition noop}
      :screen {}
      :spaces {}
      :timer {:secondsSinceEpoch #100}
      :uielement {:watcher {}}
      :window {:animationDuration 0}})

(local component-module (require :components.paper-wm))
(local {: trait-registry} (require :traits))
(local {: satisfies?} (require :sheaf.trait-registry))
(local paper-wm (require :paper-wm))
(local layout (require :paper-wm.layout))

(fn satisfies-declared-traits? [state]
  (accumulate [ok true _ trait (ipairs component-module.paper-wm-type.traits)]
    (and ok (satisfies? trait-registry trait state))))

(local runtime (component-module.paper-wm-type.start-fn {}))
(assert runtime.active? "component lifecycle must start an active runtime")
(assert (satisfies-declared-traits? runtime)
        "started runtime does not satisfy its declared traits, so dispatch would skip it")

;; Diagnostics are copies: mutating a snapshot never reaches component state.
(tset runtime :tiling-state (layout.add-window runtime.tiling-state 10 1 1))
(let [snapshot (paper-wm.diagnostic-snapshot runtime)]
  (assert (= 10 (. snapshot.spaces 1 1 1)))
  (tset (. snapshot.spaces 1 1) 1 99)
  (tset snapshot.index 10 nil))
(assert (= 10 (. runtime.tiling-state.spaces 1 1 1)) "diagnostic spaces leaked state")
(assert (. runtime.tiling-state.index 10) "diagnostic index leaked state")
(assert (. (paper-wm.invariant-report runtime) :ok?))

;; Instantiation choices reach the runtime config.
(let [configured (component-module.paper-wm-type.start-fn
                  {:window-gap 10 :screen-margin 4 :window-ratios [0.5 1.0]
                   :min-window-height 40})]
  (assert (= 10 configured.config.window-gap))
  (assert (= 4 configured.config.screen-margin))
  (assert (= 0.5 (. configured.config.window-ratios 1)))
  (assert (= 40 configured.config.min-window-height))
  (component-module.paper-wm-type.stop-fn configured))

;; Stop deactivates, releases resources, and still satisfies the traits.
(component-module.paper-wm-type.stop-fn runtime)
(let [stopped (paper-wm.diagnostic-snapshot runtime)]
  (assert (= false stopped.active?))
  (assert (= 0 stopped.resources.ui-watcher-count))
  (assert (= 0 stopped.resources.frame-timer-count))
  (assert (= false stopped.resources.space-focus-timer?)))
(assert (satisfies-declared-traits? runtime) "stopped runtime broke its trait contract")

(print "PaperWM runtime diagnostics passed")
