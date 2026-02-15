
;; event_sources/hotkey.fnl
;; Event source type: emits events on hotkey press

(local {: string?} (require :lib.cljlib-shim))
(local {: make-source-type} (require :sheaf.source-registry))


(fn start-hotkey [self emit]
  "Start listening for a hotkey press.
   self: {:name instance-name :type type-name :config {:mods table :key string}}
   emit: (fn [event-name event-data])
   Returns the hotkey object as state."
  (let [mods self.config.mods
        key self.config.key
        handler (fn [] (emit :hotkey.events/pressed {:mods mods :key key}))]
    (hs.hotkey.bind mods key handler)))


(fn stop-hotkey [state]
  "Delete the hotkey binding.
   state: the hs.hotkey object returned from start-hotkey"
  (when state
    (state:delete)))


(local hotkey-source-type
  (make-source-type
   :event-source.type/hotkey
   "Emits an event when a hotkey is pressed"
   {:config-schema {:mods table? :key string?}
    :emits [:hotkey.events/pressed]
    :start-fn start-hotkey
    :stop-fn stop-hotkey}))


{: hotkey-source-type}
