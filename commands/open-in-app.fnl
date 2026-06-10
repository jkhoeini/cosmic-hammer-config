;; commands/open-in-app.fnl
;; Command: open a URL in a specific app by bundle ID

(local {: make-command} (require :sheaf.command-registry))

(local open-in-app-command
  (make-command
   :url-dispatch.commands/open-in-app
   "Open a URL in a specific app by bundle ID"
   {:schema {:url string? :bundle-id string?}
    :fn (fn [component params]
          (print (.. "[DEBUG] open-in-app: url=" (tostring params.url)
                     " bundle-id=" (tostring params.bundle-id)))
          (hs.urlevent.openURLWithBundle params.url params.bundle-id)
          nil)}))

{: open-in-app-command}
