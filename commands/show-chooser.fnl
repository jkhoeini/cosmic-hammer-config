;; commands/show-chooser.fnl
;; Command: show an async browser picker for a URL

(local {: make-command} (require :sheaf.command-registry))

;; Must persist across calls to prevent GC from collecting the active chooser
(var active-chooser nil)

(local show-chooser-command
  (make-command
   :url-dispatch.commands/show-chooser
   "Show an async browser picker dialog for a URL"
   {:schema {:url string? :choices table?}
    :fn (fn [component params]
          (print (.. "[DEBUG] show-chooser: url=" (tostring params.url)
                     " choices=" (tostring (length (or params.choices [])))))
          (when (or (= nil params.choices) (= 0 (length params.choices)))
            (print "[WARN] show-chooser: no choices provided, skipping")
            (lua "return nil"))
          (let [url params.url
                chooser (hs.chooser.new
                         (fn [choice]
                           (if choice
                               (do
                                 (print (.. "[DEBUG] show-chooser: user chose "
                                            (tostring choice.text) " (" (tostring choice.bundle-id) ")"))
                                 (hs.urlevent.openURLWithBundle url choice.bundle-id))
                               (print "[DEBUG] show-chooser: user dismissed chooser"))))]
            (chooser:choices params.choices)
            (chooser:show)
            (set active-chooser chooser))
          nil)}))

{: show-chooser-command}
