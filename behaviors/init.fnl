
;; behaviors/init.fnl
;; Creates behavior registry and wires everything together.

(local {: make-behavior-registry : add-behavior!} (require :sheaf.behavior-registry))
(local {: event-registry} (require :events))
(local {: command-registry} (require :commands))

;; Import behavior data
(local {: compile-fennel-behavior} (require :behaviors.compile-fennel))
(local {: reload-hammerspoon-behavior} (require :behaviors.reload-hammerspoon))
(local {: toggle-expose-behavior} (require :behaviors.toggle-expose))
(local {: update-space-indicator-behavior} (require :behaviors.update-space-indicator))

;; Create and populate registry
(local behavior-registry (make-behavior-registry {:event-registry event-registry
                                                  :command-registry command-registry}))
(add-behavior! behavior-registry compile-fennel-behavior)
(add-behavior! behavior-registry reload-hammerspoon-behavior)
(add-behavior! behavior-registry toggle-expose-behavior)
(add-behavior! behavior-registry update-space-indicator-behavior)

;; Export registry for other modules
{: behavior-registry}
