;; commands/record-url.fnl
;; Command: record a URL visit into history

(local {: make-command} (require :sheaf.command-registry))

(local record-url-command
  (make-command
   :url-history.commands/record-url
   "Record a URL visit into the history log"
   {:schema {:url string? :sender-bundle-id string? :timestamp number?}
    :requires-traits [:trait/has-url-history]
    :fn (fn [component params]
          (let [entry {:url params.url
                       :sender-bundle-id params.sender-bundle-id
                       :timestamp params.timestamp}
                old-history (or component.state.history [])
                history []]
            ;; Copy existing entries into a new table
            (each [_ h (ipairs old-history)]
              (table.insert history h))
            (table.insert history entry)
            {:history history}))}))

{: record-url-command}
