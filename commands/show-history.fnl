;; commands/show-history.fnl
;; Command: show URL history browser via hs.chooser

(local {: make-command} (require :sheaf.command-registry))

;; Must persist across calls to prevent GC from collecting the active chooser
(var active-history-chooser nil)

(local show-history-command
  (make-command
   :url-history.commands/show-history
   "Show URL history as a searchable chooser list"
   {:requires-traits [:trait/has-url-history]
    :fn (fn [component params]
          (let [history (or component.state.history [])
                choices []]
            (when (= 0 (length history))
              (hs.alert "No URL history yet")
              (lua "return nil"))
            ;; Build choices newest-first
            (for [i (length history) 1 -1]
              (let [entry (. history i)]
                (table.insert choices
                              {:text entry.url
                               :subText (.. (or entry.sender-bundle-id "unknown")
                                           " \xe2\x80\x94 "
                                           (os.date "%Y-%m-%d %H:%M" (math.floor entry.timestamp)))})))
            (let [chooser (hs.chooser.new
                           (fn [choice]
                             (when choice
                               (hs.pasteboard.setContents choice.text)
                               (hs.alert "URL copied to clipboard"))))]
              (chooser:choices choices)
              (chooser:show)
              (set active-history-chooser chooser)))
          nil)}))

{: show-history-command}
