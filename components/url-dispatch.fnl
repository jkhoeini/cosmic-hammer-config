
;; components/url-dispatch.fnl
;; Component type: URL dispatch handler (owns url-handler source)

(local {: make-component-type} (require :sheaf.component-registry))
(local {: default-decoders} (require :event_sources.url-decoders))

(local url-dispatch-type
  (make-component-type
   :component.type/url-dispatch
   "URL dispatch handler - routes URLs through decoders and opens them"
   {:sources [{:type :event-source.type/url-handler
               :config {:decoders default-decoders}
               :instance-name "main"
               :tags [:tag/url-handler]}]
    :start-fn (fn [config] {})}))

{: url-dispatch-type}
