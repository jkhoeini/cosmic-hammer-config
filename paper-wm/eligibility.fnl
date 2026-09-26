(fn eligible? [facts]
  "Return whether shared window facts satisfy PaperWM membership policy."
  (not (not (and facts
                 facts.window-id
                 (= facts.subrole "AXStandardWindow")
                 (= facts.has-titlebar true)
                 (= facts.visible true)
                 (= facts.fullscreen false)
                 (= facts.tab-count 0)
                 (not= nil facts.space-id)))))

{: eligible?}
