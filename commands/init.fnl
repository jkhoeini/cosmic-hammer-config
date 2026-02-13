
;; commands/init.fnl
;; Creates command registry and registers commands.

(local {: make-command-registry : add-command!} (require :lib.command-registry))

;; Import command data
(local {: toggle-expose-command} (require :commands.toggle-expose))
(local {: update-menubar-command} (require :commands.space-indicator))

;; Create and populate registry
(local command-registry (make-command-registry))
(add-command! command-registry toggle-expose-command)
(add-command! command-registry update-menubar-command)


{: command-registry}
