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

(local membership-calls [])
(tset package.loaded.paper-wm :initialize-layout!
      (fn [runtime facts]
        (table.insert membership-calls [:initialize (length facts)])
        (let [layout-module (require :paper-wm.layout)]
          (each [_ fact (ipairs facts)]
            (tset runtime :tiling-state
                  (layout-module.add-window runtime.tiling-state fact.window-id
                                            fact.space-id 1))))
        runtime))
(tset package.loaded.paper-wm :reconcile-window-fact!
      (fn [runtime fact opts]
        (table.insert membership-calls [:reconcile fact.window-id opts.runtime-epoch])
        (when (= opts.runtime-epoch runtime.epoch)
          (let [layout-module (require :paper-wm.layout)]
            (tset runtime :tiling-state
                  (if fact.fullscreen
                      (layout-module.remove-window runtime.tiling-state fact.window-id)
                      (layout-module.add-window runtime.tiling-state fact.window-id
                                                fact.space-id 1)))))
        runtime))
(tset package.loaded.paper-wm :record-focus!
      (fn [runtime window-id space-id frame]
        (table.insert membership-calls [:focus window-id space-id frame])
        (tset runtime.tiling-state :focused-window-id window-id)
        runtime))
(tset package.loaded.paper-wm :retile-observed-frame!
      (fn [runtime params]
        (table.insert membership-calls [:frame params.window-id params.sequence])
        runtime))


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
(assert (= :initialize (. membership-calls 1 1))
        "initialize command must delegate effects to PaperWM interpreter")

(local duplicate
  (commands.reconcile-window-command.fn {:state initialized}
                                        {:window facts :runtime-epoch 1}))
(assert (= 1 (length (. duplicate.tiling-state.spaces 3))))
(assert (= :reconcile (. membership-calls 2 1))
        "reconcile command must delegate effects to PaperWM interpreter")
(local focused
  (commands.record-focus-command.fn {:state duplicate}
                                    {:window-id 1 :space-id 3 :frame facts.frame}))
(assert (= 1 focused.tiling-state.focused-window-id))
(assert (= :focus (. membership-calls 3 1)))

(local framed
  (commands.retile-observed-frame-command.fn
   {:state focused}
   {:window-id 1 :frame facts.frame :generation 1 :sequence 2}))
(assert (= focused framed))
(assert (= :frame (. membership-calls 4 1)))

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
