;; commands/open-in-app.fnl
;; Command: open a URL in a specific app by bundle ID

(local {: make-command} (require :sheaf.command-registry))

(local open-in-app-command
  (make-command
   :url-dispatch.commands/open-in-app
   "Open a URL in a specific app by bundle ID"
   {:schema {:url string? :bundle-id string?}
    :fn (fn [params]
          (hs.urlevent.openURLWithBundle params.url params.bundle-id))}))

{: open-in-app-command}
