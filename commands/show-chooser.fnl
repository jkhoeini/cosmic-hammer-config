;; commands/show-chooser.fnl
;; Command: show an async browser picker for a URL

(local {: make-command} (require :sheaf.command-registry))

(local show-chooser-command
  (make-command
   :url-dispatch.commands/show-chooser
   "Show an async browser picker dialog for a URL"
   {:schema {:url string? :choices table?}
    :fn (fn [component params]
          (let [url params.url
                chooser (hs.chooser.new
                         (fn [choice]
                           (when choice
                             (hs.urlevent.openURLWithBundle url choice.bundle-id))))]
            (chooser:choices params.choices)
            (chooser:show))
          nil)}))

{: show-chooser-command}
