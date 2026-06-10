
;; behaviors/record-url.fnl
;; Behavior: record opened URLs into history
;;
;; Responds to url-opened events and sends the record command
;; to the url-history component. Uses the event's own timestamp
;; rather than generating a fresh one.

(local {: make-behavior} (require :sheaf.behavior-registry))

(local record-url-behavior
  (make-behavior
   {:name :url-history.behaviors/record-on-dispatch
    :description "Record dispatched URLs into history for later browsing"
    :respond-to [:event.kind.url/opened]
    :commands {:record :url-history.commands/record-url}
    :fn (fn [event candidates send-cmd]
          (let [url (?. event :event-data :url)
                target (. candidates.record 1)]
            (when (and target url)
              (send-cmd target :record
                        {:url url
                         :sender-bundle-id (?. event :event-data :sender-bundle-id)
                         :timestamp event.timestamp}))))}))

{: record-url-behavior}
