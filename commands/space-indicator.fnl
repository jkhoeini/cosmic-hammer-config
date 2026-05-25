
;; commands/space-indicator.fnl
;; Command: update the space indicator menubar

(local {: make-command} (require :sheaf.command-registry))


(local update-menubar-command
  (make-command
   :space-indicator.commands/update-menubar
   "Update the space indicator menubar with active space indices"
   {:requires-traits [:trait/has-menubar]
    :schema {:active-spaces table?}
    :fn (fn [component params]
          (when component.state.menubar
            (component.state.menubar:setTitle
              (table.concat
                (icollect [_ n (ipairs params.active-spaces)]
                  (tostring n))
                "|")))
          nil)}))


{: update-menubar-command}
