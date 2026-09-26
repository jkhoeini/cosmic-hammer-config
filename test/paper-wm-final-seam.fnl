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

(local first (paper-wm.make-runtime {}))
(local second (paper-wm.make-runtime {}))
(assert (= :table (type first)))
(assert (< first.epoch second.epoch))
(assert (not= first second))

(print "PaperWM final seam passed")
