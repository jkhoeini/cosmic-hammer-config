(var pending nil)
(set _G.hs {:timer {:doAfter (fn [delay callback]
                              (set pending callback)
                              {:stop #nil})}})

(local emitted [])
(local module (require :event_sources.paper-wm-frame-watcher))
(local runtime {:resources {:frame-observations
                            {:sequences {} :latest {} :timers {}}}})
(local source-type module.frame-watcher-source-type)
(local state (source-type.start-fn {:config {:runtime runtime}}
                                   (fn [name data]
                                     (table.insert emitted [name data]))))

(module.observe! state 10 "moved" {:x 1} 2)
(module.observe! state 10 "resized" {:x 2} 2)
(assert (= 0 (length emitted)))
(pending)
(assert (= 1 (length emitted)))
(assert (= :paper-wm.events/frame-observed (. emitted 1 1)))
(assert (= 2 (. emitted 1 2 :sequence)))
(assert (= 2 (. emitted 1 2 :frame :x)))

(print "PaperWM frame source passed")
