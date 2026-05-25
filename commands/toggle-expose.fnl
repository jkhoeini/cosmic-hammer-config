
;; commands/toggle-expose.fnl
;; Command: toggle the Expose window picker

(local {: make-command} (require :sheaf.command-registry))


(local toggle-expose-command
  (make-command
   :expose.commands/toggle-show
   "Toggle the Hammerspoon Expose window picker"
   {:requires-traits [:trait/has-expose]
    :fn (fn [component params]
          (component.state.expose:toggleShow)
          nil)}))


{: toggle-expose-command}
