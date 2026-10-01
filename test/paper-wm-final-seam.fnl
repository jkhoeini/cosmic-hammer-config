(set _G.hs
     {:eventtap {:leftClick #nil}
      :geometry {:rect {} :rectMidPoint (fn [] {})}
      :logger {:new (fn [] {:d #nil :e #nil :v #nil})}
      :mouse {:absolutePosition #nil}
      :screen {}
      :spaces {:spaceType #:fullscreen}
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
(local (reconciled report) (paper-wm.reconcile-layout! runtime [] [1]))
(assert (= runtime reconciled))
(assert (= 10 (. report.removed 1)))
(assert (= nil (. runtime.tiling-state.index 10)))
(assert (= 10 (. runtime.last-reconcile-report.removed 1)))

(local moved-runtime (paper-wm.make-runtime {:epoch 4}))
(let [layout (require :paper-wm.layout)]
  (tset moved-runtime :tiling-state
        (layout.add-window moved-runtime.tiling-state 20 1 1)))
(local moved-fact {:window-id 20 :space-id 2 :subrole "AXStandardWindow"
                   :has-titlebar true :visible true :fullscreen false :tab-count 0
                   :frame {:x 10 :y 10 :w 100 :h 100}})
(paper-wm.reconcile-window-fact! moved-runtime moved-fact
                                 {:runtime-epoch moved-runtime.epoch})
(assert (= 2 (. moved-runtime.tiling-state.index 20 :space))
        "tracked window did not move to its observed Space")

(print "PaperWM final seam passed")
