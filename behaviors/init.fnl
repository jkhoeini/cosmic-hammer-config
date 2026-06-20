
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
(local {: open-emacs-behavior} (require :behaviors.open-emacs))
(local {: update-on-focus-behavior : update-on-move-behavior : hide-on-disappear-behavior} (require :behaviors.window-border))
(local {: route-url-behavior} (require :behaviors.url-routing))
(local {: record-url-behavior} (require :behaviors.record-url))
(local {: show-history-behavior} (require :behaviors.show-history))
(local {: initialize-behavior
        : track-on-change-behavior
        : track-on-move-behavior
        : untrack-on-disappear-behavior} (require :behaviors.window-state))
(local {: focus-left-behavior
        : focus-right-behavior
        : focus-up-behavior
        : focus-down-behavior
        : swap-left-behavior
        : swap-right-behavior
        : swap-up-behavior
        : swap-down-behavior
        : center-window-behavior
        : set-full-width-behavior
        : cycle-width-up-behavior
        : cycle-width-down-behavior
        : cycle-height-up-behavior
        : cycle-height-down-behavior
        : slurp-window-behavior
        : barf-window-behavior
        : prev-space-behavior
        : next-space-behavior
        : switch-to-space-behaviors} (require :behaviors.paper-wm))

;; Create and populate registry
(local behavior-registry (make-behavior-registry {:event-registry event-registry
                                                  :command-registry command-registry
                                                  :shape-registry shape-registry}))
(add-behavior! behavior-registry compile-fennel-behavior)
(add-behavior! behavior-registry reload-hammerspoon-behavior)
(add-behavior! behavior-registry toggle-expose-behavior)
(add-behavior! behavior-registry update-space-indicator-behavior)
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
(add-behavior! behavior-registry focus-left-behavior)
(add-behavior! behavior-registry focus-right-behavior)
(add-behavior! behavior-registry focus-up-behavior)
(add-behavior! behavior-registry focus-down-behavior)
(add-behavior! behavior-registry swap-left-behavior)
(add-behavior! behavior-registry swap-right-behavior)
(add-behavior! behavior-registry swap-up-behavior)
(add-behavior! behavior-registry swap-down-behavior)
(add-behavior! behavior-registry center-window-behavior)
(add-behavior! behavior-registry set-full-width-behavior)
(add-behavior! behavior-registry cycle-width-up-behavior)
(add-behavior! behavior-registry cycle-width-down-behavior)
(add-behavior! behavior-registry cycle-height-up-behavior)
(add-behavior! behavior-registry cycle-height-down-behavior)
(add-behavior! behavior-registry slurp-window-behavior)
(add-behavior! behavior-registry barf-window-behavior)
(add-behavior! behavior-registry prev-space-behavior)
(add-behavior! behavior-registry next-space-behavior)
(for [i 1 9]
  (add-behavior! behavior-registry (. switch-to-space-behaviors i)))

;; Export registry for other modules
{: behavior-registry}
