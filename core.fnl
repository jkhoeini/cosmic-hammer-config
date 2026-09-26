;; First thing to do: Clear console.
(hs.console.clearConsole)

;; Configure OpenTelemetry before the Sheaf boot sequence.
;; hs.opentelemetry is always available, so no availability guard is needed.
(hs.opentelemetry.configure
 {:enabled true
  :serviceName "cosmic-hammer-config"
  :exporter "otlp"
  :protocol "http/protobuf"
  :endpoint "http://localhost:4318"
  :traces true
  :logs true
  :metrics true
  ;; Truthy value enables print() capture as logs ("off" would disable it).
  :capturePrint "on"
  :captureLogger true
  :callbackSampleRates {"hs.eventtap" 0.01
                        "hs.sqlite3.progressHandler" 0}
  :attributeLimits {:maxCount 64
                    :maxValueLength 4096}})

;; Debug mode for event-bus logging
(tset _G :event-bus.debug-mode? false)

;; TODO cliInstall doesn't work due to priviledges. For now I've linked manually
(hs.ipc.cliInstall) ; ensure CLI installed


(set hs.window.animationDuration 0.0)




(local notify (require :notify))

;; Boot order: events → traits → shapes → source types → components (auto-creates sources) → commands → behaviors → subscriptions → dispatcher
(local {: event-registry} (require :events))
(local {: trait-registry} (require :traits))
(local {: shape-registry} (require :shapes))
(require :event_sources)
(local {: component-registry} (require :components))
(require :commands)
(require :behaviors)
(local {: subscription-registry} (require :subscriptions))

;; Start dispatcher and event loop
(local {: start-dispatcher!} (require :sheaf.dispatcher))
(local {: make-event-loop : start-event-loop!} (require :sheaf.event-loop))

(start-dispatcher! subscription-registry component-registry shape-registry)
(local event-loop (make-event-loop event-registry))
(start-event-loop! event-loop)

(notify.warn "Reload Succeeded")

{}
