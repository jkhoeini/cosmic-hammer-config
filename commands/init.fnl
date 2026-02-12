
;; commands/init.fnl
;; Creates command registry and registers commands.

(local {: make-command-registry : add-command!} (require :lib.command-registry))

;; Import command data
(local {: toggle-expose-command} (require :commands.toggle-expose))

;; Create and populate registry
(local command-registry (make-command-registry))
(add-command! command-registry toggle-expose-command)


{: command-registry}
