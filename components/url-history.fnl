
;; components/url-history.fnl
;; Component type: URL history state holder
;;
;; Records dispatched URLs for browsing and recall.
;; State is ephemeral — history resets on reload.
;; Persistence (file or SQLite) deferred to a future phase.

(local {: make-component-type} (require :sheaf.component-registry))

(local url-history-type
  (make-component-type
   :component.type/url-history
   "URL history - records dispatched URLs for browsing and recall"
   {:traits [:trait/has-url-history]
    :sources [{:type :event-source.type/hotkey
               :config {:mods [:cmd :ctrl] :key "l"}
               :instance-name "history-hotkey"
               :tags [:tag/url-history-hotkey]}]
    :start-fn (fn [config] {:history []})}))

{: url-history-type}
