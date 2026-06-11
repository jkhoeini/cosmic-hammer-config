
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
(local {: show-active-border-command
        : show-inactive-border-command
        : hide-borders-command} (require :commands.window-border))
(local {: record-url-command} (require :commands.record-url))
(local {: show-history-command} (require :commands.show-history))
(local {: initialize-windows-command
        : upsert-window-command
        : remove-window-command} (require :commands.window-state))

;; Create and populate registry
(local command-registry (make-command-registry {:trait-registry trait-registry}))
(add-command! command-registry toggle-expose-command)
(add-command! command-registry update-menubar-command)
(add-command! command-registry compile-command)
(add-command! command-registry reload-hammerspoon-command)
(add-command! command-registry open-in-app-command)
(add-command! command-registry show-chooser-command)
(add-command! command-registry open-emacs-command)
(add-command! command-registry show-active-border-command)
(add-command! command-registry show-inactive-border-command)
(add-command! command-registry hide-borders-command)
(add-command! command-registry record-url-command)
(add-command! command-registry show-history-command)
(add-command! command-registry initialize-windows-command)
(add-command! command-registry upsert-window-command)
(add-command! command-registry remove-window-command)


{: command-registry}
