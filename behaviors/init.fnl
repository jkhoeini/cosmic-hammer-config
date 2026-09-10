
;; behaviors/init.fnl
;; Creates behavior registry and wires everything together.

(local {: make-behavior-registry : add-behavior!} (require :sheaf.behavior-registry))
(local {: event-registry} (require :events))
(local {: command-registry} (require :commands))
(local {: shape-registry} (require :shapes))

;; Import behavior data
(local {: compile-fennel-behavior} (require :behaviors.compile-fennel))
(local {: reload-hammerspoon-behavior} (require :behaviors.reload-hammerspoon))
(local {: toggle-expose-behavior} (require :behaviors.toggle-expose))
(local {: update-space-indicator-behavior} (require :behaviors.update-space-indicator))
(local {: reconcile-spaces-behavior} (require :behaviors.desktop-layout))
(local {: raise-hovered-window-behavior
        : center-cursor-on-focus-behavior
        : schedule-created-window-behavior
        : note-space-change-behavior
        : place-created-window-behavior} (require :behaviors.mouse-window-management))
(local {: open-emacs-behavior} (require :behaviors.open-emacs))
(local {: update-on-focus-behavior : update-on-move-behavior : hide-on-disappear-behavior} (require :behaviors.window-border))
(local {: route-url-behavior} (require :behaviors.url-routing))
(local {: record-url-behavior} (require :behaviors.record-url))
(local {: show-history-behavior} (require :behaviors.show-history))
(local {: initialize-behavior
        : track-on-change-behavior
        : track-on-move-behavior
        : untrack-on-disappear-behavior
        : track-focus-behavior} (require :behaviors.window-state))
(local {: focus-behavior
        : swap-behavior
        : center-window-behavior
        : set-full-width-behavior
        : cycle-window-size-behavior
        : slurp-window-behavior
        : barf-window-behavior
        : increment-space-behavior
        : switch-to-space-behavior
        : refresh-on-screen-change-behavior
        : refresh-on-window-placed-behavior} (require :behaviors.paper-wm))

;; Create and populate registry
(local behavior-registry (make-behavior-registry {:event-registry event-registry
                                                  :command-registry command-registry
                                                  :shape-registry shape-registry}))
(add-behavior! behavior-registry compile-fennel-behavior)
(add-behavior! behavior-registry reload-hammerspoon-behavior)
(add-behavior! behavior-registry toggle-expose-behavior)
(add-behavior! behavior-registry update-space-indicator-behavior)
(add-behavior! behavior-registry reconcile-spaces-behavior)
(add-behavior! behavior-registry raise-hovered-window-behavior)
(add-behavior! behavior-registry center-cursor-on-focus-behavior)
(add-behavior! behavior-registry schedule-created-window-behavior)
(add-behavior! behavior-registry note-space-change-behavior)
(add-behavior! behavior-registry place-created-window-behavior)
(add-behavior! behavior-registry open-emacs-behavior)
(add-behavior! behavior-registry update-on-focus-behavior)
(add-behavior! behavior-registry update-on-move-behavior)
(add-behavior! behavior-registry hide-on-disappear-behavior)
(add-behavior! behavior-registry route-url-behavior)
(add-behavior! behavior-registry record-url-behavior)
(add-behavior! behavior-registry show-history-behavior)
(add-behavior! behavior-registry initialize-behavior)
(add-behavior! behavior-registry track-on-change-behavior)
(add-behavior! behavior-registry track-on-move-behavior)
(add-behavior! behavior-registry untrack-on-disappear-behavior)
(add-behavior! behavior-registry track-focus-behavior)
(add-behavior! behavior-registry focus-behavior)
(add-behavior! behavior-registry swap-behavior)
(add-behavior! behavior-registry center-window-behavior)
(add-behavior! behavior-registry set-full-width-behavior)
(add-behavior! behavior-registry cycle-window-size-behavior)
(add-behavior! behavior-registry slurp-window-behavior)
(add-behavior! behavior-registry barf-window-behavior)
(add-behavior! behavior-registry increment-space-behavior)
(add-behavior! behavior-registry switch-to-space-behavior)
(add-behavior! behavior-registry refresh-on-screen-change-behavior)
(add-behavior! behavior-registry refresh-on-window-placed-behavior)

;; Export registry for other modules
{: behavior-registry}
