
;; events/init.fnl
;; Central event registry: event-kind hierarchy + all event definitions
;;
;; This module creates and exports the event-registry.
;; The hierarchy is accessible via event-registry.hierarchy

(local {: string?} (require :lib.cljlib-shim))
(local {: make-event-registry : define-event!} (require :sheaf.event-registry))
(local {: make-hierarchy : derive!} (require :lib.hierarchy))

(local number? (fn [x] (= (type x) :number)))
(local table? (fn [x] (= (type x) :table)))
(local nil-or-string? (fn [x] (or (= x nil) (string? x))))


;; ============================================================================
;; Event Kind Hierarchy
;; ============================================================================
;;
;; :event.kind/any                         ;; Root - all events derive from this
;; ├── :event.kind.fs/any                  ;; File system events
;; │   ├── :event.kind.fs/file-change
;; │   └── :event.kind.fs/file-move
;; │
;; ├── :event.kind.window/any              ;; Window events
;; │   ├── :event.kind.window/visible
;; │   ├── :event.kind.window/not-visible
;; │   ├── :event.kind.window/focused
;; │   ├── :event.kind.window/unfocused
;; │   ├── :event.kind.window/fullscreened
;; │   ├── :event.kind.window/unfullscreened
;; │   ├── :event.kind.window/moved
;; │   ├── :event.kind.window/resized
;; │   └── :event.kind.window/initial
;; │
;; ├── :event.kind.app/any                 ;; Application events
;; │   ├── :event.kind.app/launched
;; │   ├── :event.kind.app/terminated
;; │   ├── :event.kind.app/activated
;; │   ├── :event.kind.app/deactivated
;; │   └── :event.kind.app/hidden
;; │
;; ├── :event.kind.screen/any              ;; Display/screen events
;; │   ├── :event.kind.screen/added
;; │   ├── :event.kind.screen/removed
;; │   └── :event.kind.screen/layout-changed
;; │
;; ├── :event.kind.space/any               ;; Spaces/desktop events
;; │   └── :event.kind.space/changed
;; │
;; ├── :event.kind.system/any              ;; System events
;; │   ├── :event.kind.system/wake
;; │   ├── :event.kind.system/sleep
;; │   ├── :event.kind.system/screens-changed
;; │   └── :event.kind.system/session-lock
;; │
;; ├── :event.kind.hotkey/any              ;; Hotkey events
;; │   └── :event.kind.hotkey/pressed
;; │
;; ├── :event.kind.usb/any                 ;; USB device events
;; │   ├── :event.kind.usb/attached
;; │   └── :event.kind.usb/detached
;; │
;; ├── :event.kind.wifi/any                ;; WiFi events
;; │   └── :event.kind.wifi/changed
;; │
;; ├── :event.kind.battery/any             ;; Battery events
;;     └── :event.kind.battery/changed
;; │
;; └── :event.kind.url/any                 ;; URL events
;;     └── :event.kind.url/opened

(local event-hierarchy (make-hierarchy))

;; --- File System ---
(derive! event-hierarchy :event.kind.fs/any :event.kind/any)
(derive! event-hierarchy :event.kind.fs/file-change :event.kind.fs/any)
(derive! event-hierarchy :event.kind.fs/file-move :event.kind.fs/any)

;; --- Window ---
(derive! event-hierarchy :event.kind.window/any :event.kind/any)
(derive! event-hierarchy :event.kind.window/visible :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/not-visible :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/focused :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/unfocused :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/fullscreened :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/unfullscreened :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/moved :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/resized :event.kind.window/any)
(derive! event-hierarchy :event.kind.window/initial :event.kind.window/any)

;; --- Application ---
(derive! event-hierarchy :event.kind.app/any :event.kind/any)
(derive! event-hierarchy :event.kind.app/launched :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/terminated :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/activated :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/deactivated :event.kind.app/any)
(derive! event-hierarchy :event.kind.app/hidden :event.kind.app/any)

;; --- Screen/Display ---
(derive! event-hierarchy :event.kind.screen/any :event.kind/any)
(derive! event-hierarchy :event.kind.screen/added :event.kind.screen/any)
(derive! event-hierarchy :event.kind.screen/removed :event.kind.screen/any)
(derive! event-hierarchy :event.kind.screen/layout-changed :event.kind.screen/any)

;; --- Spaces/Desktop ---
(derive! event-hierarchy :event.kind.space/any :event.kind/any)
(derive! event-hierarchy :event.kind.space/changed :event.kind.space/any)

;; --- System ---
(derive! event-hierarchy :event.kind.system/any :event.kind/any)
(derive! event-hierarchy :event.kind.system/wake :event.kind.system/any)
(derive! event-hierarchy :event.kind.system/sleep :event.kind.system/any)
(derive! event-hierarchy :event.kind.system/screens-changed :event.kind.system/any)
(derive! event-hierarchy :event.kind.system/session-lock :event.kind.system/any)

;; --- Hotkey ---
(derive! event-hierarchy :event.kind.hotkey/any :event.kind/any)
(derive! event-hierarchy :event.kind.hotkey/pressed :event.kind.hotkey/any)

;; --- USB ---
(derive! event-hierarchy :event.kind.usb/any :event.kind/any)
(derive! event-hierarchy :event.kind.usb/attached :event.kind.usb/any)
(derive! event-hierarchy :event.kind.usb/detached :event.kind.usb/any)

;; --- WiFi ---
(derive! event-hierarchy :event.kind.wifi/any :event.kind/any)
(derive! event-hierarchy :event.kind.wifi/changed :event.kind.wifi/any)

;; --- Battery ---
(derive! event-hierarchy :event.kind.battery/any :event.kind/any)
(derive! event-hierarchy :event.kind.battery/changed :event.kind.battery/any)

;; --- URL ---
(derive! event-hierarchy :event.kind.url/any :event.kind/any)
(derive! event-hierarchy :event.kind.url/opened :event.kind.url/any)


;; ============================================================================
;; Event Registry
;; ============================================================================

(local event-registry (make-event-registry {:hierarchy event-hierarchy}))


;; ============================================================================
;; Event Definitions
;; ============================================================================

;; --- File Watcher Events ---
(define-event! event-registry
               :file-watcher.events/file-change
               "File change detected in watched directory"
               {:file-path string?})
(derive! event-hierarchy :file-watcher.events/file-change :event.kind.fs/file-change)


;; --- Hotkey Events ---
(define-event! event-registry
               :hotkey.events/pressed
               "Hotkey was pressed"
               {:mods table? :key string?})
(derive! event-hierarchy :hotkey.events/pressed :event.kind.hotkey/pressed)


;; --- Space Watcher Events ---
(define-event! event-registry
               :space-watcher.events/space-changed
               "Active space/desktop changed"
               {:space-number number? :all-spaces table? :active-spaces table?})
(derive! event-hierarchy :space-watcher.events/space-changed :event.kind.space/changed)


;; --- Screen Watcher Events ---
(define-event! event-registry
               :screen-watcher.events/screen-changed
               "Screen layout changed"
               {:all-spaces table? :active-spaces table?})
(derive! event-hierarchy :screen-watcher.events/screen-changed :event.kind.screen/layout-changed)


;; --- Window Watcher Events ---
(define-event! event-registry
               :window-watcher.events/focused
               "Window gained focus"
               {:window-id number? :app-name string? :bundle-id nil-or-string? :window-title string? :frame table?})
(derive! event-hierarchy :window-watcher.events/focused :event.kind.window/focused)

(define-event! event-registry
               :window-watcher.events/visible
               "Window became visible"
               {:window-id number? :app-name string? :bundle-id nil-or-string? :window-title string? :frame table?})
(derive! event-hierarchy :window-watcher.events/visible :event.kind.window/visible)

(define-event! event-registry
               :window-watcher.events/not-visible
               "Window is no longer visible"
               {:window-id number? :app-name string? :bundle-id nil-or-string? :window-title string? :frame table?})
(derive! event-hierarchy :window-watcher.events/not-visible :event.kind.window/not-visible)

(define-event! event-registry
               :window-watcher.events/fullscreened
               "Window entered fullscreen"
               {:window-id number? :app-name string? :bundle-id nil-or-string? :window-title string? :frame table?})
(derive! event-hierarchy :window-watcher.events/fullscreened :event.kind.window/fullscreened)

(define-event! event-registry
               :window-watcher.events/unfullscreened
               "Window exited fullscreen"
               {:window-id number? :app-name string? :bundle-id nil-or-string? :window-title string? :frame table?})
(derive! event-hierarchy :window-watcher.events/unfullscreened :event.kind.window/unfullscreened)

(define-event! event-registry
               :window-watcher.events/moved
               "Window was moved or resized"
               {:window-id number? :app-name string? :bundle-id nil-or-string? :window-title string? :frame table?})
(derive! event-hierarchy :window-watcher.events/moved :event.kind.window/moved)

(define-event! event-registry
               :window-watcher.events/initial-windows
               "Snapshot of all visible windows at source startup"
               {:windows table?})
(derive! event-hierarchy :window-watcher.events/initial-windows :event.kind.window/initial)


;; --- Window Element Watcher Events ---
(define-event! event-registry
               :window-element-watcher.events/moved
               "Window was moved"
               {:window-id number? :frame table?})
(derive! event-hierarchy :window-element-watcher.events/moved :event.kind.window/moved)

(define-event! event-registry
               :window-element-watcher.events/resized
               "Window was resized"
               {:window-id number? :frame table?})
(derive! event-hierarchy :window-element-watcher.events/resized :event.kind.window/resized)



;; --- App Watcher Events ---
(define-event! event-registry
               :app-watcher.events/launched
               "Application launched"
               {:app-name string? :bundle-id string? :pid number?})
(derive! event-hierarchy :app-watcher.events/launched :event.kind.app/launched)

(define-event! event-registry
               :app-watcher.events/terminated
               "Application terminated"
               {:app-name string? :bundle-id string? :pid number?})
(derive! event-hierarchy :app-watcher.events/terminated :event.kind.app/terminated)

(define-event! event-registry
               :app-watcher.events/activated
               "Application activated (brought to front)"
               {:app-name string? :bundle-id string? :pid number?})
(derive! event-hierarchy :app-watcher.events/activated :event.kind.app/activated)

(define-event! event-registry
               :app-watcher.events/deactivated
               "Application deactivated (lost focus)"
               {:app-name string? :bundle-id string? :pid number?})
(derive! event-hierarchy :app-watcher.events/deactivated :event.kind.app/deactivated)

(define-event! event-registry
               :app-watcher.events/hidden
               "Application hidden"
               {:app-name string? :bundle-id string? :pid number?})
(derive! event-hierarchy :app-watcher.events/hidden :event.kind.app/hidden)


;; --- URL Handler Events ---
(define-event! event-registry
               :url-handler.events/url-opened
               "URL opened via default browser handler"
               {:url string? :original string? :scheme string? :host string?
                :path nil-or-string? :params table?
                :sender nil-or-string? :sender-bundle-id nil-or-string?})
(derive! event-hierarchy :url-handler.events/url-opened :event.kind.url/opened)


;; Export registry (hierarchy accessible via event-registry.hierarchy)
{: event-registry}
