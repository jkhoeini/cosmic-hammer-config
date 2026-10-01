;; event_sources/paper-wm-outbox.fnl
;; Event source type: the PaperWM component's owned outbox for asynchronous
;; outcomes. The runtime owns the AX watchers, timers, and coalescing state;
;; this source only lends its emit so those outcomes re-enter as events.

(local {: make-source-type} (require :sheaf.source-registry))

(local table? #(= (type $) :table))

(fn start-outbox [self emit]
  "Attach this source's emit as the owning runtime's outbox port.
   self.config.runtime is the PaperWM component state."
  (let [runtime self.config.runtime]
    (tset runtime.resources :outbox emit)
    {: runtime : emit}))

(fn stop-outbox [state]
  "Detach the outbox port if this source still owns it."
  (when (= state.emit state.runtime.resources.outbox)
    (tset state.runtime.resources :outbox nil)))

(local paper-wm-outbox-source-type
  (make-source-type
   :event-source.type/paper-wm-outbox
   "Emits PaperWM asynchronous outcomes: coalesced frame observations and Space focus retries"
   {:config-schema {:runtime table?}
    :emits [:paper-wm.events/frame-observed :paper-wm.events/space-focus-retry]
    :start-fn start-outbox
    :stop-fn stop-outbox}))

{: paper-wm-outbox-source-type}
