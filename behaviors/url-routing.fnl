
;; behaviors/url-routing.fnl
;; Behavior: route opened URLs to browsers based on structured rules.
;;
;; Receives URL-opened events, matches against ordered rules, and dispatches
;; either :open-in-app (single browser) or :show-chooser (browser picker).
;; Uses shaped inputs from the routing-rules component for browser config.

(local {: make-behavior} (require :sheaf.behavior-registry))
(local {: build-browser-lookup
        : resolve-browser
        : resolve-browsers
        : make-chooser-choices
        : parse-url
        : match-rule?
        : find-matching-rule} (require :lib.url-routing))


;; ============================================================================
;; Action Dispatch Helpers
;; ============================================================================

(fn dispatch-open-in-app [action url lookup target send-cmd]
  "Dispatch an :open-in-app action. Resolves browser-id and sends command."
  (let [browser (resolve-browser action.browser-id lookup)]
    (when browser
      (send-cmd target :open-in-app {:url url :bundle-id browser.bundle-id}))))


(fn collect-browser-ids-for-choose [action browsers]
  "Collect browser IDs for a :choose action.
   Handles :browser-ids :all (all configured browsers) or an explicit list."
  (if (= :all action.browser-ids)
      ;; Resolve :all to every configured browser's :id
      (let [ids []]
        (each [_ b (ipairs browsers)]
          (table.insert ids b.id))
        ids)
      ;; Explicit list of browser-ids
      (or action.browser-ids [])))


(fn dispatch-choose [action url browsers lookup target send-cmd]
  "Dispatch a :choose action. Resolves browser list and sends chooser command."
  (let [browser-ids (collect-browser-ids-for-choose action browsers)
        resolved (resolve-browsers browser-ids lookup)
        choices (make-chooser-choices resolved)]
    (if (= 0 (length choices))
        (print "[WARN] url-routing: no browsers resolved for chooser, skipping")
        (send-cmd target :show-chooser {:url url :choices choices}))))


(fn dispatch-action [action url browsers lookup candidates send-cmd]
  "Dispatch a rule action to the appropriate command on a target candidate."
  (when (= nil action)
    (print "[WARN] url-routing: nil action, cannot dispatch")
    (lua "return nil"))
  (when (= nil action.type)
    (print "[WARN] url-routing: action missing :type field")
    (lua "return nil"))
  (if (= :open-in-app action.type)
      (let [target (. candidates.open-in-app 1)]
        (if target
            (dispatch-open-in-app action url lookup target send-cmd)
            (print "[WARN] url-routing: no candidate for :open-in-app")))
      (= :choose action.type)
      (let [target (. candidates.show-chooser 1)]
        (if target
            (dispatch-choose action url browsers lookup target send-cmd)
            (print "[WARN] url-routing: no candidate for :show-chooser")))
      ;; Unknown action type
      (print (.. "[WARN] url-routing: unknown action type '"
                 (tostring action.type) "'"))))


;; ============================================================================
;; Behavior Definition
;; ============================================================================

(local route-url-behavior
  (make-behavior
   {:name :url-dispatch.behaviors/route-url
    :description "Route opened URLs to browsers based on structured routing rules"
    :respond-to [:event.kind.url/opened]
    :commands {:open-in-app :url-dispatch.commands/open-in-app
               :show-chooser :url-dispatch.commands/show-chooser}
    :inputs {:rules :shape/url-routing-rules}
    :fn (fn [event candidates send-cmd inputs]
          (let [url (?. event :event-data :url)
                sender-bundle-id (?. event :event-data :sender-bundle-id)]
            (when (= nil url)
              (print "[WARN] url-routing: event missing :url in event-data")
              (lua "return nil"))
            ;; Extract routing config from shaped inputs
            (let [rules-state (when inputs (?. inputs :rules))
                  browsers (or (?. rules-state :browsers) [])
                  rules (or (?. rules-state :rules) [])
                  fallback (?. rules-state :fallback)
                  ;; Build browser lookup once per invocation
                  lookup (build-browser-lookup browsers)
                  ;; Parse URL for structured matching
                  parsed (parse-url url)
                  ;; First-match-wins against ordered rules
                  matched-rule (find-matching-rule parsed sender-bundle-id rules)
                  ;; Use matched rule's action or fall back
                  action (if matched-rule
                             matched-rule.action
                             fallback)]
              (if action
                  (dispatch-action action url browsers lookup candidates send-cmd)
                  (print (.. "[WARN] url-routing: no matching rule and no fallback for URL '"
                             (tostring url) "'"))))))}))


{: route-url-behavior}
