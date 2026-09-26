(set _G.hs
     {:eventtap {:leftClick #nil}
      :geometry {:rect {} :rectMidPoint (fn [] {})}
      :logger {:new (fn [] {:d #nil :e #nil :v #nil})}
      :mouse {:absolutePosition #nil}
      :screen {}
      :spaces {}
      :timer {:secondsSinceEpoch #100}
      :uielement {:watcher {}}
      :window {:animationDuration 0}})

(local paper-wm (require :paper-wm))

(assert paper-wm.make-runtime)
(assert paper-wm.stop-runtime!)
(assert paper-wm.reconcile-layout!)
(assert paper-wm.reconcile-window-fact!)
(assert paper-wm.focus-window!)
(assert paper-wm.swap-windows!)
(assert paper-wm.center-window!)
(assert paper-wm.set-window-full-width!)
(assert paper-wm.cycle-window-size!)
(assert paper-wm.slurp-window!)
(assert paper-wm.barf-window!)

(assert (= nil paper-wm.start!))
(assert (= nil paper-wm.stop!))
(assert (= nil paper-wm.current-runtime))
(assert (= nil paper-wm.run-with-runtime!))
(assert (= nil paper-wm.Direction))

(local first (paper-wm.make-runtime {:epoch 1}))
(local second (paper-wm.make-runtime {:epoch 2}))
(assert (= :table (type first)))
(assert (< first.epoch second.epoch))
(assert (not= first second))

(local runtime (paper-wm.make-runtime {:epoch 3}))
(let [layout (require :paper-wm.layout)]
  (tset runtime :tiling-state
        (layout.add-window runtime.tiling-state 10 1 1)))
(local (reconciled report) (paper-wm.reconcile-layout! runtime []))
(assert (= runtime reconciled))
(assert (= 10 (. report.removed 1)))
(assert (= nil (. runtime.tiling-state.index 10)))
(assert (= 10 (. runtime.last-reconcile-report.removed 1)))

(print "PaperWM final seam passed")
