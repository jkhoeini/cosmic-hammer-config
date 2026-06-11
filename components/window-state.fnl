
;; components/window-state.fnl
;; Component type: tracks all visible windows — frame, app, fullscreen state.
;; Starts empty; populated by :window-watcher.events/initial-windows on boot.

(local {: make-component-type} (require :sheaf.component-registry))

(local window-state-type
  (make-component-type
   :component.type/window-state
   "Tracks all visible windows — frame, app, fullscreen state"
   {:traits [:trait/has-window-state]
    :start-fn (fn [config] {:windows {}})}))

{: window-state-type}
