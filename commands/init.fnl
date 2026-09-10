;; commands/init.fnl
;; Creates command registry and registers commands.

(local {: make-command-registry : add-command!} (require :sheaf.command-registry))
(local {: trait-registry} (require :traits))

;; Import command data
(local {: toggle-expose-command} (require :commands.toggle-expose))
(local {: update-menubar-command} (require :commands.space-indicator))
(local {: reconcile-spaces-command} (require :commands.desktop-layout))
(local {: raise-window-command
        : center-cursor-command
        : note-space-change-command
        : schedule-placement-command
        : place-window-command} (require :commands.mouse-window-management))
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
        : remove-window-command
        : set-focused-window-command} (require :commands.window-state))
(local {: focus-command
        : swap-command
        : center-window-command
        : set-full-width-command
        : cycle-window-size-command
        : slurp-window-command
        : barf-window-command
        : switch-to-space-command
        : increment-space-command
        : refresh-windows-command
        : set-pending-window-command
        : clear-pending-window-command} (require :commands.paper-wm))

;; Create and populate registry
(local command-registry (make-command-registry {:trait-registry trait-registry}))
(add-command! command-registry toggle-expose-command)
(add-command! command-registry update-menubar-command)
(add-command! command-registry reconcile-spaces-command)
(add-command! command-registry raise-window-command)
(add-command! command-registry center-cursor-command)
(add-command! command-registry note-space-change-command)
(add-command! command-registry schedule-placement-command)
(add-command! command-registry place-window-command)
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
(add-command! command-registry set-focused-window-command)
(add-command! command-registry focus-command)
(add-command! command-registry swap-command)
(add-command! command-registry center-window-command)
(add-command! command-registry set-full-width-command)
(add-command! command-registry cycle-window-size-command)
(add-command! command-registry slurp-window-command)
(add-command! command-registry barf-window-command)
(add-command! command-registry switch-to-space-command)
(add-command! command-registry increment-space-command)
(add-command! command-registry refresh-windows-command)
(add-command! command-registry set-pending-window-command)
(add-command! command-registry clear-pending-window-command)

{: command-registry}
