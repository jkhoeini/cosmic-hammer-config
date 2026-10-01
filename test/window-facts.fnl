(local facts (require :lib.window-facts))

(local window
  {:id #42
   :application (fn [] {:name #"Editor" :bundleID #"com.example.Editor"})
   :title #"Document"
   :frame (fn [] {:x 1 :y 2 :w 3 :h 4})
   :role #"AXWindow"
   :subrole #"AXStandardWindow"
   :zoomButtonRect (fn [] {:x 0 :y 0 :w 1 :h 1})
   :isVisible #true
   :isFullScreen #false
   :tabCount #0})

(set _G.hs {:spaces {:windowSpaces (fn [_] [7])}
            :window {:allWindows (fn [] [window])}})

(local snapshot (facts.snapshot-window window))
(assert (= 42 snapshot.window-id))
(assert (= "Editor" snapshot.app-name))
(assert (= "com.example.Editor" snapshot.bundle-id))
(assert (= "Document" snapshot.window-title))
(assert (= "AXWindow" snapshot.role))
(assert (= "AXStandardWindow" snapshot.subrole))
(assert snapshot.has-titlebar)
(assert snapshot.visible)
(assert (= false snapshot.fullscreen))
(assert (= 0 snapshot.tab-count))
(assert (= 7 snapshot.space-id))

(local torn
  {:id #(error "gone")
   :application #(error "gone")
   :title #(error "gone")
   :frame #(error "gone")})
(local (ok result) (pcall facts.snapshot-window torn))
(assert ok "guarded snapshot propagated a torn-window error")
(assert (= nil result))

(local all (facts.snapshot-windows))
(assert (= 1 (length all)))
(assert (= 42 (. all 1 :window-id)))

(tset hs.spaces :activeSpaces #{:screen-a 7 :screen-b 3})
(local observed (facts.snapshot-observed-windows))
(assert (= 42 (. observed.windows 1 :window-id)))
(assert (and (= 3 (. observed.observed-spaces 1)) (= 7 (. observed.observed-spaces 2))
             (= 2 (length observed.observed-spaces))))

(tset hs.spaces :activeSpaces #(error "spaces unavailable"))
(assert (= 0 (length (. (facts.snapshot-observed-windows) :observed-spaces)))
        "unknown active Spaces must observe nothing")

(var reads 0)
(tset hs.spaces :activeSpaces (fn []
                                (set reads (+ 1 reads))
                                (if (= 1 reads) {:screen-a 7} {:screen-a 8})))
(assert (= 0 (length (. (facts.snapshot-observed-windows) :observed-spaces)))
        "a Space switch during the snapshot must observe nothing")

(print "Window facts passed")
