
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

;; Export registry for other modules
{: behavior-registry}
