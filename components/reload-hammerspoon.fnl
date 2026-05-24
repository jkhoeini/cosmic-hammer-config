
;; components/reload-hammerspoon.fnl
;; Component type: Hammerspoon config reloader with debounce timer

(local {: make-component-type} (require :sheaf.component-registry))

(local reload-hammerspoon-type
  (make-component-type
   :component.type/reload-hammerspoon
   "Hammerspoon config reloader with debounce timer"
   {:traits [:trait/has-delayed-timer]
    :start-fn (fn [config]
                {:timer (hs.timer.delayed.new 0.5 hs.reload)
                 :reloading? false})
    :stop-fn (fn [state]
               (state.timer:stop))}))

{: reload-hammerspoon-type}
