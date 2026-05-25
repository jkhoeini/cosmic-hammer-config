
;; commands/init.fnl
;; Creates command registry and registers commands.

(local {: make-command-registry : add-command!} (require :sheaf.command-registry))
(local {: trait-registry} (require :traits))

;; Import command data
(local {: toggle-expose-command} (require :commands.toggle-expose))
(local {: update-menubar-command} (require :commands.space-indicator))
(local {: compile-command} (require :commands.compile-fennel))
(local {: reload-hammerspoon-command} (require :commands.reload-hammerspoon))
(local {: open-in-app-command} (require :commands.open-in-app))
(local {: show-chooser-command} (require :commands.show-chooser))
(local {: open-emacs-command} (require :commands.open-emacs))

;; Create and populate registry
(local command-registry (make-command-registry {:trait-registry trait-registry}))
(add-command! command-registry toggle-expose-command)
(add-command! command-registry update-menubar-command)
(add-command! command-registry compile-command)
(add-command! command-registry reload-hammerspoon-command)
(add-command! command-registry open-in-app-command)
(add-command! command-registry show-chooser-command)
(add-command! command-registry open-emacs-command)


{: command-registry}
