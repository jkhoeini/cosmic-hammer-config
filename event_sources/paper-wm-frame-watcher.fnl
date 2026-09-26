(local {: make-source-type} (require :sheaf.source-registry))
(local {: next-observation} (require :paper-wm.observations))

(fn start-frame-watcher [self emit]
  "Create a component-owned emitter for bounded PaperWM frame observations."
  (let [state {:emit emit
               :runtime self.config.runtime
               :observations self.config.runtime.resources.frame-observations}]
    (tset self.config.runtime.resources :frame-source state)
    state))
(fn stop-frame-watcher [state]
  (each [_ timer (pairs state.observations.timers)]
    (timer:stop))
  (tset state.observations :timers {})
  (when (= state state.runtime.resources.frame-source)
    (tset state.runtime.resources :frame-source nil)))
(fn observe! [state window-id event-kind frame generation]
  "Coalesce one window to its latest observation and emit at display cadence."
  (let [observation (next-observation state.observations window-id event-kind
                                      frame generation)]
    (when (= nil (. state.observations.timers window-id))
      (tset state.observations.timers window-id
            (hs.timer.doAfter
             (/ 1 60)
             (fn []
               (tset state.observations.timers window-id nil)
               (let [latest (. state.observations.latest window-id)]
                 (when latest
                   (state.emit :paper-wm.events/frame-observed latest)))))))
    observation))

(local frame-watcher-source-type
  (make-source-type
   :event-source.type/paper-wm-frame-watcher
   "Emits bounded PaperWM frame observations"
   {:config-schema {:runtime table?}
    :emits [:paper-wm.events/frame-observed]
    :start-fn start-frame-watcher
    :stop-fn stop-frame-watcher}))

{: frame-watcher-source-type : observe!}
