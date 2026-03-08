
;; commands/reload-hammerspoon.fnl
;; Command: reload Hammerspoon config with debounce

(local {: make-command} (require :sheaf.command-registry))
(local notify (require :notify))

(var reloading? false)
(local reload (hs.timer.delayed.new 0.5 hs.reload))

(local reload-hammerspoon-command
  (make-command
   :reload-hammerspoon.commands/reload
   "Reload Hammerspoon config with debounce"
   {:fn (fn [params]
          (when (not reloading?)
            (set reloading? true)
            (notify.warn "Reloading...")
            (reload:start)))}))

{: reload-hammerspoon-command}
