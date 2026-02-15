
;; commands/space-indicator.fnl
;; Command: update the space indicator menubar

(local {: make-command} (require :sheaf.command-registry))


;; Create menubar with autosave name so macOS remembers its position
(local menubar (hs.menubar.new true "cosmicHammerSpaceIndicator"))
(when menubar
  (menubar:setTitle "..."))


(local update-menubar-command
  (make-command
   :space-indicator.commands/update-menubar
   "Update the space indicator menubar with active space indices"
   {:schema {:active-spaces table?}
    :fn (fn [params]
          (when menubar
            (menubar:setTitle
              (table.concat
                (icollect [_ n (ipairs params.active-spaces)]
                  (tostring n))
                "|"))))}))


{: update-menubar-command}
