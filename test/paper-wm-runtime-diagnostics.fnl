(local noop #nil)

(set _G.hs
     {:eventtap {:leftClick noop}
      :geometry {:rect {} :rectMidPoint (fn [] {})}
      :logger {:new (fn [] {:e noop :v noop :d noop :df noop :ef noop})}
      :mouse {:absolutePosition noop}
      :screen {}
      :spaces {:screensHaveSeparateSpaces #true}
      :timer {:secondsSinceEpoch #100}
      :uielement {:watcher {}}
      :window {:animationDuration 0}})

(local component-module (require :components.paper-wm))

(assert (= :trait/has-paper-wm-runtime (. component-module.paper-wm-type.traits 1))
        "PaperWM component must declare its runtime trait")
(assert (= :trait/has-tiling-state (. component-module.paper-wm-type.traits 2))
        "PaperWM component must declare its logical tiling-state trait")

(local paper-wm (require :paper-wm))

(assert paper-wm.diagnostic-snapshot
        "PaperWM must expose a read-only diagnostic snapshot")

(local runtime (paper-wm.make-runtime {}))
(local initial (paper-wm.diagnostic-snapshot runtime))
(assert (= 0 (length initial.window-list)))
(assert (= 0 (length initial.index-table)))
(assert (= nil initial.focused-window-id))
(assert (= 0 initial.resources.ui-watcher-count))

(tset initial.window-list 1 [:mutated])
(tset initial.index-table 1 {:space 1 :col 1 :row 1})
(local fresh (paper-wm.diagnostic-snapshot runtime))
(assert (= 0 (length fresh.window-list))
        "diagnostic window list leaked mutable component state")
(assert (= 0 (length fresh.index-table))
        "diagnostic index table leaked mutable component state")
(assert (= nil paper-wm.config) "mutable module config export must be removed")

(assert (= nil runtime.window-list) "legacy object layout must be removed")
(assert (= nil runtime.index-table) "legacy reverse index must be removed")
(assert (= nil runtime.ui-watchers) "opaque resources must not live at runtime root")
(assert (= :table (type runtime.tiling-state)))
(assert (= :table (type runtime.tiling-state.spaces)))
(assert (= :table (type runtime.tiling-state.index)))
(assert (= nil runtime.tiling-state.focused-window-id))
(assert (= :table (type runtime.resources)))
(assert (= :table (type runtime.resources.windows)))
(assert (= :table (type runtime.resources.ui-watchers)))
(assert (= :table (type runtime.resources.watcher-restart-timers)))
(assert runtime.active? "started runtime must be active")
(assert (= :number (type runtime.epoch)))
(local component-runtime (component-module.paper-wm-type.start-fn {}))
(assert (and component-runtime component-runtime.active?)
        "component lifecycle must start an active PaperWM runtime")
(assert (= 35 component-runtime.config.window-gap))
(assert (= 16 component-runtime.config.screen-margin))
(assert (= 0.421875 (. component-runtime.config.window-ratios 1)))
(assert (= 0.843750 (. component-runtime.config.window-ratios 2)))
(local configured-runtime
  (component-module.paper-wm-type.start-fn
   {:window-gap 10 :screen-margin 4 :window-ratios [0.5 1.0]}))
(assert (= 10 configured-runtime.config.window-gap))
(assert (= 4 configured-runtime.config.screen-margin))
(assert (= 0.5 (. configured-runtime.config.window-ratios 1)))
(component-module.paper-wm-type.stop-fn configured-runtime)
(assert (= :table (type runtime.resources.watcher-restart-timers)))
(assert (= nil runtime.tiling-state.focused-window-id))

(local running (paper-wm.diagnostic-snapshot runtime))
(assert (= 0 running.resources.ui-watcher-count))
(paper-wm.stop-runtime! runtime)
(local stopped (paper-wm.diagnostic-snapshot runtime))
(assert (= 0 stopped.resources.ui-watcher-count))
(component-module.paper-wm-type.stop-fn component-runtime)
(assert (= false component-runtime.active?))
(local report (paper-wm.invariant-report runtime))
(assert report.ok?)
(assert (= runtime.epoch report.epoch))
(assert (= false runtime.active?))
(assert (= false stopped.active?))
(assert (= false stopped.resources.space-focus-timer?))

(print "PaperWM runtime diagnostics passed")
