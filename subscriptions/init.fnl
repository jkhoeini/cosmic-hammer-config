
;; subscriptions/init.fnl
;; Creates subscription registry and wires behaviors to event sources via tags.

(local {: make-subscription-registry : define-subscription!} (require :sheaf.subscription-registry))
(local {: event-registry} (require :events))
(local {: behavior-registry} (require :behaviors))
(local {: tag-registry} (require :components))

;; Create subscription registry
(local subscription-registry
  (make-subscription-registry {:event-registry event-registry
                               :behavior-registry behavior-registry
                               :tag-registry tag-registry}))

(define-subscription! subscription-registry
 :sub/reload-on-config-change
 {:description "Reload Hammerspoon when init.lua changes"
  :behavior :reload-hammerspoon.behaviors/reload-hammerspoon
  :source-tag :tag/config-watcher
  :target-tag :tag/reload-hammerspoon
  :event-selector :event.kind.fs/file-change})

(define-subscription! subscription-registry
 :sub/compile-on-fnl-change
 {:description "Recompile Fennel when .fnl files change"
  :behavior :compile-fennel.behaviors/compile-fennel
  :source-tag :tag/config-watcher
  :target-tag :tag/compile-fennel
  :event-selector :event.kind.fs/file-change})

(define-subscription! subscription-registry
 :sub/toggle-expose-on-hotkey
 {:description "Toggle Expose when ctrl+cmd+e is pressed"
  :behavior :expose.behaviors/toggle-expose
  :source-tag :tag/expose-hotkey
  :target-tag :tag/expose
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/update-indicator-on-space-change
 {:description "Update space indicator when space changes"
  :behavior :space-indicator.behaviors/update-on-change
  :source-tag :tag/space-watcher
  :target-tag :tag/space-indicator
  :event-selector :event.kind.space/changed})

(define-subscription! subscription-registry
 :sub/update-indicator-on-screen-change
 {:description "Update space indicator when screen layout changes"
  :behavior :space-indicator.behaviors/update-on-change
  :source-tag :tag/screen-watcher
  :target-tag :tag/space-indicator
  :event-selector :event.kind.screen/layout-changed})

(define-subscription! subscription-registry
 :sub/open-emacs-on-hotkey
 {:description "Open emacsclient frame when cmd+alt+return is pressed"
  :behavior :emacs.behaviors/open-emacs
  :source-tag :tag/emacs-hotkey
  :target-tag :tag/emacs
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/border-on-focus
 {:description "Show active border when a window gains focus"
  :behavior :window-border.behaviors/update-on-focus
  :source-tag :tag/window-watcher
  :target-tag :tag/window-border
  :event-selector :event.kind.window/focused})

(define-subscription! subscription-registry
 :sub/border-on-visible
 {:description "Show active border when a window becomes visible"
  :behavior :window-border.behaviors/update-on-focus
  :source-tag :tag/window-watcher
  :target-tag :tag/window-border
  :event-selector :event.kind.window/visible})

(define-subscription! subscription-registry
 :sub/border-on-move
 {:description "Reposition active border when a window moves or resizes"
  :behavior :window-border.behaviors/update-on-move
  :source-tag :tag/window-watcher
  :target-tag :tag/window-border
  :event-selector :event.kind.window/moved})

(define-subscription! subscription-registry
 :sub/border-on-disappear
 {:description "Hide active border when the focused window disappears"
  :behavior :window-border.behaviors/hide-on-disappear
  :source-tag :tag/window-watcher
  :target-tag :tag/window-border
  :event-selector :event.kind.window/not-visible})

(define-subscription! subscription-registry
 :sub/route-url-on-open
 {:description "Route opened URLs to browsers based on rules"
  :behavior :url-dispatch.behaviors/route-url
  :source-tag :tag/url-handler
  :target-tag :tag/url-dispatch
  :input-tag :tag/url-routing-rules
  :event-selector :event.kind.url/opened})

{: subscription-registry}
