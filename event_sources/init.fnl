
;; event_sources/init.fnl
;; Create source registry and register source types.
;; Source instances are created by components via start-component!.

(local {: make-source-registry : add-source-type!} (require :sheaf.source-registry))
(local {: event-registry} (require :events))
(local {: file-watcher-source-type} (require :event_sources.file-watcher))
(local {: hotkey-source-type} (require :event_sources.hotkey))
(local {: space-watcher-source-type} (require :event_sources.space-watcher))
(local {: screen-watcher-source-type} (require :event_sources.screen-watcher))
(local {: window-watcher-source-type} (require :event_sources.window-watcher))
(local {: window-element-watcher-source-type} (require :event_sources.window-element-watcher))
(local {: app-watcher-source-type} (require :event_sources.app-watcher))
(local {: url-handler-source-type} (require :event_sources.url-handler))


;; Create source registry
(local source-registry (make-source-registry {:event-registry event-registry}))


;; Register source types
(add-source-type! source-registry file-watcher-source-type)
(add-source-type! source-registry hotkey-source-type)
(add-source-type! source-registry space-watcher-source-type)
(add-source-type! source-registry screen-watcher-source-type)
(add-source-type! source-registry window-watcher-source-type)
(add-source-type! source-registry window-element-watcher-source-type)
(add-source-type! source-registry app-watcher-source-type)
(add-source-type! source-registry url-handler-source-type)


{: source-registry}
