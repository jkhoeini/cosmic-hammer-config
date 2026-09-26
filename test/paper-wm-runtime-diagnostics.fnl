(local noop #nil)
(local filter
  {:getWindows #[]
   :setOverrideFilter (fn [self override]
                        (tset self :override override)
                        self)
   :subscribe noop
   :unsubscribeAll noop})

(set _G.hs
     {:geometry {:rect {}}
      :logger {:new (fn [] {:e noop :v noop :d noop :df noop :ef noop})}
      :notify {:show noop}
      :screen {}
      :spaces {:screensHaveSeparateSpaces #true}
      :timer {}
      :uielement {:watcher {}}
      :window {:animationDuration 0
               :filter {:new #filter}}})

(local component-module (require :components.paper-wm))

(assert (= :trait/has-paper-wm-runtime (. component-module.paper-wm-type.traits 1))
        "PaperWM component must declare its runtime trait")

(local paper-wm (require :paper-wm))

(assert paper-wm.diagnostic-snapshot
        "PaperWM must expose a read-only diagnostic snapshot")

(local initial (paper-wm.diagnostic-snapshot))
(assert (= 0 (length initial.window-list)))
(assert (= 0 (length initial.index-table)))
(assert (= nil initial.focused-window-id))
(assert (= nil initial.pending-window-id))
(assert (= false initial.resources.window-filter?))
(assert (= 0 initial.resources.ui-watcher-count))
(assert (= 0 initial.resources.watcher-restart-timer-count))

(tset initial.window-list 1 [:mutated])
(tset initial.index-table 1 {:space 1 :col 1 :row 1})
(local fresh (paper-wm.diagnostic-snapshot))
(assert (= 0 (length fresh.window-list))
        "diagnostic window list leaked mutable module state")
(assert (= 0 (length fresh.index-table))
        "diagnostic index table leaked mutable module state")

(local runtime (paper-wm.start!))
(assert (= :table (type runtime)) "start! must return the owned runtime")
(assert (= :table (type runtime.window-list)))
(assert (= :table (type runtime.index-table)))
(assert (= :table (type runtime.ui-watchers)))
(assert runtime.active? "started runtime must be active")
(assert (= :number (type runtime.epoch)))
(local component-runtime (component-module.paper-wm-type.start-fn {}))
(assert (and component-runtime component-runtime.active?)
        "component lifecycle must start an active PaperWM runtime")
(assert (= :table (type runtime.watcher-restart-timers)))
(assert (= filter runtime.window-filter))
(assert (= nil runtime.focused-window))
(assert (= nil runtime.pending-window))

(local running (paper-wm.diagnostic-snapshot runtime))
(assert running.resources.window-filter?)
(paper-wm.stop! runtime)
(local stopped (paper-wm.diagnostic-snapshot runtime))
(assert (= false stopped.resources.window-filter?))
(component-module.paper-wm-type.stop-fn component-runtime)
(assert (= false component-runtime.active?))
(assert (= false runtime.active?))
(assert (= false stopped.active?))
(assert (= 0 stopped.resources.pending-window-timer-count))
(assert (= false stopped.resources.space-focus-timer?))

(print "PaperWM runtime diagnostics passed")
