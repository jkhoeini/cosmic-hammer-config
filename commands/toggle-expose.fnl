
;; commands/toggle-expose.fnl
;; Command: toggle the Expose window picker

(local {: make-command} (require :sheaf.command-registry))


(local expose (hs.expose.new))


(local toggle-expose-command
  (make-command
   :expose.commands/toggle-show
   "Toggle the Hammerspoon Expose window picker"
   {:fn (fn [params] (expose:toggleShow))}))


{: toggle-expose-command}
