
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
                {:browsers [{:id :safari :bundle-id "com.apple.Safari"}
                            {:id :chrome :bundle-id "com.google.Chrome"}
                            {:id :firefox :bundle-id "org.mozilla.firefox"}
                            {:id :arc :bundle-id "company.thebrowser.Browser"}]
                 :fallback {:type :open-in-app :browser-id :safari}
                 :rules [{:id :work-slack-links
                          :match {:urls [{:scheme [:http :https]
                                          :host "*.slack.com"}]
                                  :sender-bundle-ids ["com.tinyspeck.slackmacgap"]}
                          :action {:type :open-in-app :browser-id :chrome}}]})}))

{: url-routing-rules-type}
