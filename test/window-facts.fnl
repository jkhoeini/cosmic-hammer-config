(local facts (require :lib.window-facts))

(local window
  {:id #42
   :application (fn [] {:name #"Editor" :bundleID #"com.example.Editor"})
   :title #"Document"
   :frame #({:x 1 :y 2 :w 3 :h 4})
   :role #"AXWindow"
   :subrole #"AXStandardWindow"
   :zoomButtonRect #({:x 0 :y 0 :w 1 :h 1})
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

(print "Window facts passed")
