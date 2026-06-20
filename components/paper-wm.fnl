;; components/paper-wm.fnl
;; Component type: PaperWM tiling window manager (hotkey event sources)
;;
;; Stateless component that owns 27 hotkey source instances for PaperWM.
;; Phase 2 of the paper-wm Sheaf migration — hotkey infrastructure only.
;; No traits, no commands, no behaviors wired yet.

(local {: make-component-type} (require :sheaf.component-registry))

;; Build the sources array programmatically
(local sources [])

;; Focus navigation (4)
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :left}
                       :instance-name "focus-left"
                       :tags [:tag/paper-wm-focus-left]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :right}
                       :instance-name "focus-right"
                       :tags [:tag/paper-wm-focus-right]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :up}
                       :instance-name "focus-up"
                       :tags [:tag/paper-wm-focus-up]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :down}
                       :instance-name "focus-down"
                       :tags [:tag/paper-wm-focus-down]})

;; Swap (4)
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd :shift] :key :left}
                       :instance-name "swap-left"
                       :tags [:tag/paper-wm-swap-left]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd :shift] :key :right}
                       :instance-name "swap-right"
                       :tags [:tag/paper-wm-swap-right]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd :shift] :key :up}
                       :instance-name "swap-up"
                       :tags [:tag/paper-wm-swap-up]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd :shift] :key :down}
                       :instance-name "swap-down"
                       :tags [:tag/paper-wm-swap-down]})

;; Sizing (6)
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :c}
                       :instance-name "center-window"
                       :tags [:tag/paper-wm-center-window]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :f}
                       :instance-name "set-full-width"
                       :tags [:tag/paper-wm-set-full-width]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :r}
                       :instance-name "cycle-width-up"
                       :tags [:tag/paper-wm-cycle-width-up]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd :shift] :key :r}
                       :instance-name "cycle-height-up"
                       :tags [:tag/paper-wm-cycle-height-up]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:ctrl :alt :cmd] :key :r}
                       :instance-name "cycle-width-down"
                       :tags [:tag/paper-wm-cycle-width-down]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:ctrl :alt :cmd :shift] :key :r}
                       :instance-name "cycle-height-down"
                       :tags [:tag/paper-wm-cycle-height-down]})

;; Slurp/Barf (2)
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :i}
                       :instance-name "slurp-window"
                       :tags [:tag/paper-wm-slurp]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key :o}
                       :instance-name "barf-window"
                       :tags [:tag/paper-wm-barf]})

;; Space navigation (2)
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key ","}
                       :instance-name "prev-space"
                       :tags [:tag/paper-wm-prev-space]})
(table.insert sources {:type :event-source.type/hotkey
                       :config {:mods [:alt :cmd] :key "."}
                       :instance-name "next-space"
                       :tags [:tag/paper-wm-next-space]})

;; Switch-to-space (9, generated in a loop)
(for [i 1 9]
  (table.insert sources {:type :event-source.type/hotkey
                         :config {:mods [:alt :cmd] :key (tostring i)}
                         :instance-name (.. "switch-to-space-" (tostring i))
                         :tags [(.. :tag/paper-wm-switch-to-space- (tostring i))]}))

(local paper-wm-type
  (make-component-type
   :component.type/paper-wm
   "PaperWM tiling window manager - hotkey event sources"
   {:sources sources
    :start-fn (fn [config] {})}))

{: paper-wm-type}
