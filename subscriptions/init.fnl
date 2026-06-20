
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

(define-subscription! subscription-registry
 :sub/record-url-on-dispatch
 {:description "Record dispatched URLs into history"
  :behavior :url-history.behaviors/record-on-dispatch
  :source-tag :tag/url-handler
  :target-tag :tag/url-history
  :event-selector :event.kind.url/opened})

(define-subscription! subscription-registry
 :sub/show-history-on-hotkey
 {:description "Show URL history browser on Cmd+Ctrl+L"
  :behavior :url-history.behaviors/show-history
  :source-tag :tag/url-history-hotkey
  :target-tag :tag/url-history
  :event-selector :event.kind.hotkey/pressed})


;; --- Window State Tracking ---

(define-subscription! subscription-registry
 :sub/window-state-initialize
 {:description "Populate window state from initial snapshot"
  :behavior :window-state.behaviors/initialize
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/initial})

(define-subscription! subscription-registry
 :sub/window-state-on-focus
 {:description "Track window on focus"
  :behavior :window-state.behaviors/track-on-change
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/focused})

(define-subscription! subscription-registry
 :sub/window-state-on-visible
 {:description "Track window on visible"
  :behavior :window-state.behaviors/track-on-change
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/visible})

(define-subscription! subscription-registry
 :sub/window-state-on-fullscreen
 {:description "Track window fullscreen state"
  :behavior :window-state.behaviors/track-on-change
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/fullscreened})

(define-subscription! subscription-registry
 :sub/window-state-on-unfullscreen
 {:description "Track window unfullscreen state"
  :behavior :window-state.behaviors/track-on-change
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/unfullscreened})

(define-subscription! subscription-registry
 :sub/window-state-on-move
 {:description "Track window frame on move/resize"
  :behavior :window-state.behaviors/track-on-move
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/moved})

(define-subscription! subscription-registry
 :sub/window-state-on-disappear
 {:description "Remove window from tracking on disappear"
  :behavior :window-state.behaviors/untrack-on-disappear
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/not-visible})

(define-subscription! subscription-registry
 :sub/window-state-track-focus
 {:description "Track focused window ID in window state"
  :behavior :window-state.behaviors/track-focus
  :source-tag :tag/window-watcher
  :target-tag :tag/window-state
  :event-selector :event.kind.window/focused})


;; --- PaperWM hotkey wiring ---

(define-subscription! subscription-registry
 :sub/paper-wm-focus-left
 {:description "Focus window left on Alt+Cmd+Left"
  :behavior :paper-wm.behaviors/focus-left
  :source-tag :tag/paper-wm-focus-left
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-focus-right
 {:description "Focus window right on Alt+Cmd+Right"
  :behavior :paper-wm.behaviors/focus-right
  :source-tag :tag/paper-wm-focus-right
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-focus-up
 {:description "Focus window above on Alt+Cmd+Up"
  :behavior :paper-wm.behaviors/focus-up
  :source-tag :tag/paper-wm-focus-up
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-focus-down
 {:description "Focus window below on Alt+Cmd+Down"
  :behavior :paper-wm.behaviors/focus-down
  :source-tag :tag/paper-wm-focus-down
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-swap-left
 {:description "Swap window left on Alt+Cmd+Shift+Left"
  :behavior :paper-wm.behaviors/swap-left
  :source-tag :tag/paper-wm-swap-left
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-swap-right
 {:description "Swap window right on Alt+Cmd+Shift+Right"
  :behavior :paper-wm.behaviors/swap-right
  :source-tag :tag/paper-wm-swap-right
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-swap-up
 {:description "Swap window up on Alt+Cmd+Shift+Up"
  :behavior :paper-wm.behaviors/swap-up
  :source-tag :tag/paper-wm-swap-up
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-swap-down
 {:description "Swap window down on Alt+Cmd+Shift+Down"
  :behavior :paper-wm.behaviors/swap-down
  :source-tag :tag/paper-wm-swap-down
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-center-window
 {:description "Center window on Alt+Cmd+C"
  :behavior :paper-wm.behaviors/center-window
  :source-tag :tag/paper-wm-center-window
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-set-full-width
 {:description "Set full width on Alt+Cmd+F"
  :behavior :paper-wm.behaviors/set-full-width
  :source-tag :tag/paper-wm-set-full-width
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-cycle-width-up
 {:description "Cycle width up on Alt+Cmd+R"
  :behavior :paper-wm.behaviors/cycle-width-up
  :source-tag :tag/paper-wm-cycle-width-up
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-cycle-width-down
 {:description "Cycle width down on Ctrl+Alt+Cmd+R"
  :behavior :paper-wm.behaviors/cycle-width-down
  :source-tag :tag/paper-wm-cycle-width-down
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-cycle-height-up
 {:description "Cycle height up on Alt+Cmd+Shift+R"
  :behavior :paper-wm.behaviors/cycle-height-up
  :source-tag :tag/paper-wm-cycle-height-up
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-cycle-height-down
 {:description "Cycle height down on Ctrl+Alt+Cmd+Shift+R"
  :behavior :paper-wm.behaviors/cycle-height-down
  :source-tag :tag/paper-wm-cycle-height-down
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-slurp
 {:description "Slurp window on Alt+Cmd+I"
  :behavior :paper-wm.behaviors/slurp-window
  :source-tag :tag/paper-wm-slurp
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-barf
 {:description "Barf window on Alt+Cmd+O"
  :behavior :paper-wm.behaviors/barf-window
  :source-tag :tag/paper-wm-barf
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-prev-space
 {:description "Previous space on Alt+Cmd+,"
  :behavior :paper-wm.behaviors/prev-space
  :source-tag :tag/paper-wm-prev-space
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(define-subscription! subscription-registry
 :sub/paper-wm-next-space
 {:description "Next space on Alt+Cmd+."
  :behavior :paper-wm.behaviors/next-space
  :source-tag :tag/paper-wm-next-space
  :target-tag :tag/paper-wm
  :event-selector :event.kind.hotkey/pressed})

(for [i 1 9]
  (define-subscription! subscription-registry
   (.. :sub/paper-wm-switch-to-space- (tostring i))
   {:description (.. "Switch to space " (tostring i) " on Alt+Cmd+" (tostring i))
    :behavior (.. :paper-wm.behaviors/switch-to-space- (tostring i))
    :source-tag (.. :tag/paper-wm-switch-to-space- (tostring i))
    :target-tag :tag/paper-wm
    :event-selector :event.kind.hotkey/pressed}))

{: subscription-registry}
