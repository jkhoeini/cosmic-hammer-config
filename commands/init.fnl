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
(local {: focus-left-command
        : focus-right-command
        : focus-up-command
        : focus-down-command
        : swap-left-command
        : swap-right-command
        : swap-up-command
        : swap-down-command
        : center-window-command
        : set-full-width-command
        : cycle-width-up-command
        : cycle-width-down-command
        : cycle-height-up-command
        : cycle-height-down-command
        : slurp-window-command
        : barf-window-command
        : switch-to-space-command
        : prev-space-command
        : next-space-command
        : refresh-windows-command} (require :commands.paper-wm))

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
(add-command! command-registry focus-left-command)
(add-command! command-registry focus-right-command)
(add-command! command-registry focus-up-command)
(add-command! command-registry focus-down-command)
(add-command! command-registry swap-left-command)
(add-command! command-registry swap-right-command)
(add-command! command-registry swap-up-command)
(add-command! command-registry swap-down-command)
(add-command! command-registry center-window-command)
(add-command! command-registry set-full-width-command)
(add-command! command-registry cycle-width-up-command)
(add-command! command-registry cycle-width-down-command)
(add-command! command-registry cycle-height-up-command)
(add-command! command-registry cycle-height-down-command)
(add-command! command-registry slurp-window-command)
(add-command! command-registry barf-window-command)
(add-command! command-registry switch-to-space-command)
(add-command! command-registry prev-space-command)
(add-command! command-registry next-space-command)
(add-command! command-registry refresh-windows-command)

{: command-registry}
