
;; commands/reload-hammerspoon.fnl
;; Command: reload Hammerspoon config with debounce

(local {: make-command} (require :sheaf.command-registry))
(local notify (require :notify))

(local reload-hammerspoon-command
  (make-command
   :reload-hammerspoon.commands/reload
   "Reload Hammerspoon config with debounce"
   {:requires-traits [:trait/has-delayed-timer]
    :fn (fn [component params]
          (when (not component.state.reloading?)
            (notify.warn "Reloading...")
            (component.state.timer:start)
            {:timer component.state.timer :reloading? true}))}))

{: reload-hammerspoon-command}
