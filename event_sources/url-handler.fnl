
;; event_sources/url-handler.fnl
;; Event source type: registers Hammerspoon as the default browser
;; and emits URL-opened events with decoded URLs.
;;
;; Note: macOS shows a "set as default browser" confirmation dialog
;; on first registration.

(local {: make-source-type} (require :sheaf.source-registry))
(local {: run-decoders : default-decoders : parse-url-parts}
       (require :event_sources.url-decoders))

(local table? (fn [x] (= (type x) :table)))
(local number? (fn [x] (= (type x) :number)))


(fn resolve-sender [sender-pid]
  "Look up the sending application from a PID.
   Returns (sender-name, sender-bundle-id) or (nil, nil) on failure.
   senderPID is -1 when unavailable."
  (if (or (= sender-pid nil) (= sender-pid -1) (= sender-pid 0))
      (values nil nil)
      (let [(ok app) (pcall hs.application.applicationForPID sender-pid)]
        (if (and ok app)
            (values (app:name) (app:bundleID))
            (values nil nil)))))


(fn extract-params [parts fallback-params]
  "Extract query parameters from parsed URL parts as a flat table.
   Falls back to the provided params table if parts are unavailable."
  (if (and parts parts.queryItems)
      (let [p {}]
        (each [_ item (ipairs parts.queryItems)]
          (when item.name
            (tset p item.name item.value)))
        p)
      (or fallback-params {})))


(fn start-url-handler [self emit]
  "Start the URL handler source.
   Registers Hammerspoon as the default HTTP/HTTPS handler.
   Note: setDefaultHandler also registers for HTML/text content types
   via LSSetDefaultRoleHandlerForContentType, so file opens (e.g. local
   .html files) also arrive here with scheme='file'. These are forwarded
   directly to the previous default browser.
   self: {:name instance-name :type type-name :config {:decoders table? :decoder-max-depth number?}}
   emit: (fn [event-name event-data])
   Returns state with previous handler info for restore."
  (let [decoders (or self.config.decoders default-decoders)
        max-depth (or self.config.decoder-max-depth 5)
        ;; Save previous default handlers before we override
        prev-http (hs.urlevent.getDefaultHandler :http)
        prev-https (hs.urlevent.getDefaultHandler :https)
        callback (fn [scheme host params full-url sender-pid]
                   (print (.. "[INFO] url-handler: callback invoked"
                              " scheme=" (tostring scheme)
                              " url=" (tostring full-url)
                              " senderPID=" (tostring sender-pid)))
                   ;; file:// URLs come from local file opens (e.g. GP SAML HTML).
                   ;; Forward directly to the previous browser — we can't render HTML.
                   (when (= scheme :file)
                     (print (.. "[INFO] url-handler: file:// URL, forwarding to "
                                (tostring prev-http)))
                     (when prev-http
                       (hs.urlevent.openURLWithBundle full-url prev-http))
                     (lua "return"))
                   (let [original full-url
                         ;; Run decoder pipeline
                         decoded (run-decoders decoders max-depth full-url)
                         ;; Parse decoded URL for structured fields
                         parts (parse-url-parts decoded)
                         ;; Extract params from decoded URL, fall back to callback params
                         decoded-params (extract-params parts params)
                         ;; Resolve sender info
                         (sender-name sender-bid) (resolve-sender sender-pid)]
                     (print (.. "[DEBUG] url-handler: emitting event, decoded="
                                (tostring decoded) " sender=" (tostring sender-name)
                                " bid=" (tostring sender-bid)))
                     (emit :url-handler.events/url-opened
                           {:url decoded
                            :original original
                            :scheme (if parts parts.scheme (or scheme ""))
                            :host (if parts parts.host (or host ""))
                            :path (when parts parts.path)
                            :params decoded-params
                            :sender sender-name
                            :sender-bundle-id sender-bid})))]
    ;; Register Hammerspoon as the default browser for http
    ;; (http and https are linked in macOS, so one call covers both)
    (hs.urlevent.setDefaultHandler :http)
    ;; Tell cosmichammer to restore the previous browser on exit/reload
    ;; so content-type registrations (HTML, text, etc.) are also restored
    (when prev-http
      (hs.urlevent.setRestoreHandler :http prev-http))
    ;; Set the callback for incoming URLs
    (set hs.urlevent.httpCallback callback)
    (print (.. "[INFO] url-handler: registered, prev-http=" (tostring prev-http)))
    ;; Return state for stop-fn to restore
    {:prev-http-handler prev-http
     :prev-https-handler prev-https}))


(fn stop-url-handler [state]
  "Stop the URL handler and restore previous default browser.
   state: {:prev-http-handler string? :prev-https-handler string?}"
  (when state
    ;; Clear the callback first
    (set hs.urlevent.httpCallback nil)
    ;; Restore previous default handlers
    (when state.prev-http-handler
      (hs.urlevent.setDefaultHandler :http state.prev-http-handler))
    (when state.prev-https-handler
      (hs.urlevent.setDefaultHandler :https state.prev-https-handler))))


(local url-handler-source-type
  (make-source-type
   :event-source.type/url-handler
   "Registers as default browser and emits URL-opened events with decoded URLs"
   {:config-schema {:decoders table? :decoder-max-depth number?}
    :emits [:url-handler.events/url-opened]
    :start-fn start-url-handler
    :stop-fn stop-url-handler}))


{: url-handler-source-type}
