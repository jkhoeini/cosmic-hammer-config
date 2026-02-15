;; First thing to do: Clear console.
(hs.console.clearConsole)

;; Debug mode for event-bus logging
(tset _G :event-bus.debug-mode? false)

;; TODO cliInstall doesn't work due to priviledges. For now I've linked manually
(hs.ipc.cliInstall) ; ensure CLI installed


(set hs.window.animationDuration 0.0)


(local spoons (require :spoons))
(local notify (require :notify))

;; Load events first (creates registry), then event sources, then behaviors
(local {: event-registry} (require :events))
(require :event_sources)
(require :commands)
(require :behaviors)
(local {: subscription-registry} (require :subscriptions))

;; Start dispatcher and event loop
(local {: start-dispatcher!} (require :sheaf.dispatcher))
(local {: make-event-loop : start-event-loop!} (require :sheaf.event-loop))

(start-dispatcher! subscription-registry)
(local event-loop (make-event-loop event-registry))
(start-event-loop! event-loop)


(notify.warn "Reload Succeeded")

{}
