
;; event_sources/init.fnl
;; Create source registry, load source types, and create instances.

(local {: make-source-registry : add-source-type! : start-event-source!} (require :sheaf.source-registry))
(local {: event-registry} (require :events))
(local {: file-watcher-source-type} (require :event_sources.file-watcher))
(local {: hotkey-source-type} (require :event_sources.hotkey))
(local {: space-watcher-source-type} (require :event_sources.space-watcher))
(local {: screen-watcher-source-type} (require :event_sources.screen-watcher))
(local {: tag-registry} (require :components))
(local {: attach-tag!} (require :sheaf.tag-registry))


;; Create source registry
(local source-registry (make-source-registry {:event-registry event-registry}))


;; Register source types
(add-source-type! source-registry file-watcher-source-type)
(add-source-type! source-registry hotkey-source-type)
(add-source-type! source-registry space-watcher-source-type)
(add-source-type! source-registry screen-watcher-source-type)


;; Create source instances
(start-event-source! source-registry
                     :event-source.file-watcher/config-dir
                     :event-source.type/file-watcher
                     {:path hs.configdir})
(attach-tag! tag-registry :event-source.file-watcher/config-dir :tag/config-watcher)


(start-event-source! source-registry
                     :event-source.hotkey/ctrl+cmd+e
                     :event-source.type/hotkey
                     {:mods [:ctrl :cmd] :key :e})
(attach-tag! tag-registry :event-source.hotkey/ctrl+cmd+e :tag/expose-hotkey)


(start-event-source! source-registry
                     :event-source.hotkey/cmd+alt+return
                     :event-source.type/hotkey
                     {:mods [:cmd :alt] :key :return})
(attach-tag! tag-registry :event-source.hotkey/cmd+alt+return :tag/emacs-hotkey)


(start-event-source! source-registry
                     :event-source.space-watcher/default
                     :event-source.type/space-watcher
                     {})
(attach-tag! tag-registry :event-source.space-watcher/default :tag/space-watcher)

(start-event-source! source-registry
                     :event-source.screen-watcher/default
                     :event-source.type/screen-watcher
                     {})
(attach-tag! tag-registry :event-source.screen-watcher/default :tag/screen-watcher)


{: source-registry}
