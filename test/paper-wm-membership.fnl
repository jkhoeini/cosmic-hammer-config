(set _G.hs {:window {:get (fn [id]
                           (when (= id 1)
                             {:id #1 :frame (fn [] {:x 0 :y 0 :w 100 :h 100})}))}})
(tset package.loaded :paper-wm
      {:Direction {:LEFT -1 :RIGHT 1 :UP -2 :DOWN 2
                   :WIDTH 3 :HEIGHT 4 :ASCENDING 5 :DESCENDING 6}
       :run-with-runtime! (fn [runtime action args]
                            (action (table.unpack (or args [])))
                            runtime)
       :focus-window #nil :swap-windows! #nil :center-window! #nil
       :set-window-full-width! #nil :cycle-window-size! #nil
       :slurp-window! #nil :barf-window! #nil :switch-to-space! #nil
       :increment-space! #nil :refresh-windows! #nil})


(local layout (require :paper-wm.layout))
(local commands (require :commands.paper-wm))

(local runtime {:active? true
                :epoch 1
                :tiling-state (layout.empty-state)
                :resources {:windows {} :ui-watchers {}
                            :watcher-restart-timers {}
                            :pending-window-timers {}}
                :config {}})
(local component {:state runtime})
(local facts {:window-id 1 :space-id 3 :subrole "AXStandardWindow"
              :has-titlebar true :visible true :fullscreen false :tab-count 0
              :frame {:x 0 :y 0 :w 100 :h 100}})

(local initialized
  (commands.initialize-layout-command.fn component {:windows [facts]}))
(assert (= 1 (. initialized.tiling-state.spaces 3 1 1)))
(assert (= 1 (. initialized.tiling-state.index 1 :row)))

(local duplicate
  (commands.reconcile-window-command.fn {:state initialized}
                                        {:window facts :runtime-epoch 1}))
(assert (= 1 (length (. duplicate.tiling-state.spaces 3))))

(local unsuitable {})
(each [key value (pairs facts)] (tset unsuitable key value))
(tset unsuitable :fullscreen true)
(local removed
  (commands.reconcile-window-command.fn {:state duplicate}
                                        {:window unsuitable :runtime-epoch 1}))
(assert (= nil (. removed.tiling-state.index 1)))

(local stale
  (commands.reconcile-window-command.fn {:state removed}
                                        {:window facts :runtime-epoch 0}))
(assert (= removed stale) "stale membership occurrence changed state")
(print "PaperWM membership commands passed")
