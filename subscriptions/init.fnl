
;; subscriptions/init.fnl
;; Creates subscription registry and wires behaviors to event sources.

(local {: make-subscription-registry : define-subscription!} (require :sheaf.subscription-registry))
(local {: event-registry} (require :events))
(local {: behavior-registry} (require :behaviors))
(local {: source-registry} (require :event_sources))

;; Create subscription registry
(local subscription-registry
  (make-subscription-registry {:event-registry event-registry
                               :behavior-registry behavior-registry
                               :source-registry source-registry}))

(define-subscription! subscription-registry
 :sub/reload-on-config-change
 {:description "Reload Hammerspoon when init.lua changes"
  :behavior :reload-hammerspoon.behaviors/reload-hammerspoon
  :source-selector :event-source.file-watcher/config-dir
  :event-selector :event.kind.fs/file-change})

(define-subscription! subscription-registry
 :sub/compile-on-fnl-change
 {:description "Recompile Fennel when .fnl files change"
  :behavior :compile-fennel.behaviors/compile-fennel
  :source-selector :event-source.file-watcher/config-dir
  :event-selector :event.kind.fs/file-change})

(define-subscription! subscription-registry
 :sub/toggle-expose-on-hotkey
 {:description "Toggle Expose when ctrl+cmd+e is pressed"
  :behavior :expose.behaviors/toggle-expose
  :source-selector :event-source.hotkey/ctrl+cmd+e
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/update-indicator-on-space-change
 {:description "Update space indicator when space changes"
  :behavior :space-indicator.behaviors/update-on-change
  :source-selector :event-source.space-watcher/default
  :event-selector :event.kind.space/changed})

(define-subscription! subscription-registry
 :sub/update-indicator-on-screen-change
 {:description "Update space indicator when screen layout changes"
  :behavior :space-indicator.behaviors/update-on-change
  :source-selector :event-source.screen-watcher/default
   :event-selector :event.kind.screen/layout-changed})

{: subscription-registry}
