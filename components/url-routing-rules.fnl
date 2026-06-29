
;; components/url-routing-rules.fnl
;; Component type: URL routing configuration data
;;
;; Pure config component — holds browser definitions, fallback action,
;; and ordered routing rules for URL dispatch behaviors.
;; No stop-fn needed (stateless config data, no resources to clean up).
;;
;; Action types:
;;   {:type :open-in-app :browser-id :safari}      — open directly in a browser
;;   {:type :choose :browser-ids [:safari :chrome]} — show chooser with specific browsers
;;   {:type :choose :browser-ids :all}              — show chooser with all browsers

(local {: make-component-type} (require :sheaf.component-registry))

(local url-routing-rules-type
  (make-component-type
   :component.type/url-routing-rules
   "URL routing configuration: browsers, fallback action, and ordered rules"
   {:traits [:trait/has-url-routing-rules]
    :start-fn (fn [config]
                {:browsers [{:id :orion    :bundle-id "com.kagi.kagimacOS"}
                            {:id :firefox  :bundle-id "org.mozilla.firefox"}
                            {:id :arc      :bundle-id "company.thebrowser.Browser"}
                            {:id :chrome   :bundle-id "com.google.Chrome"}
                            {:id :safari   :bundle-id "com.apple.Safari"}
                            {:id :brave    :bundle-id "com.brave.Browser"}
                            {:id :edge     :bundle-id "com.microsoft.edgemac"}
                            {:id :zen      :bundle-id "app.zen-browser.zen"}
                            {:id :dia      :bundle-id "company.thebrowser.dia"}
                            {:id :figma    :bundle-id "com.figma.Desktop"}
                            {:id :helium   :bundle-id "net.imput.helium"}
                            {:id :ora      :bundle-id "com.orabrowser.app"}
                            {:id :surf     :bundle-id "surf.deta"}]
                 :fallback {:type :choose :browser-ids :all}
                 :rules [{:id :file-url-default
                          :match {:urls [{:scheme :file}]}
                          :action {:type :open-in-app :browser-id :safari}}]})}))

{: url-routing-rules-type}
