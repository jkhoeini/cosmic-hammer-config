;; components/mouse-window-management.fnl
;; Component type: mouse-driven window management

(local {: make-component-type} (require :sheaf.component-registry))


(local mouse-window-management-type
  (make-component-type
   :component.type/mouse-window-management
   "Mouse-driven window focus, cursor following, and window placement"
   {:traits [:trait/has-mouse-window-management-state]
    :sources [{:type :event-source.type/mouse-window-watcher
               :config {:dwell 0.06}
               :instance-name "default"
               :tags [:tag/mouse-window-watcher]}]
    :start-fn (fn [config]
                {:last-space-change-at nil
                 :pending-placement-timers {}
                 :hover-focus-window-ids {}})
    :stop-fn (fn [state]
               (each [_ timer (pairs state.pending-placement-timers)]
                 (timer:stop)))}))


{: mouse-window-management-type}
