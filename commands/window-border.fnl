
;; commands/window-border.fnl
;; Commands: show/hide window border overlays

(local {: make-command} (require :sheaf.command-registry))


(local show-active-border-command
  (make-command
   :window-border.commands/show-active-border
   "Position and show the active window border around a window frame"
   {:requires-traits [:trait/has-canvas]
    :fn (fn [component params]
          (let [canvas component.state.active-canvas]
            (canvas:frame {:x params.frame.x
                           :y params.frame.y
                           :w params.frame.w
                           :h params.frame.h})
            (canvas:show))
          {:active-canvas component.state.active-canvas
           :inactive-canvas component.state.inactive-canvas
           :active-window-id params.window-id})}))


(local show-inactive-border-command
  (make-command
   :window-border.commands/show-inactive-border
   "Position and show the inactive window border around a window frame"
   {:requires-traits [:trait/has-canvas]
    :fn (fn [component params]
          (let [canvas component.state.inactive-canvas]
            (canvas:frame {:x params.frame.x
                           :y params.frame.y
                           :w params.frame.w
                           :h params.frame.h})
            (canvas:show))
          nil)}))


(local hide-borders-command
  (make-command
   :window-border.commands/hide-borders
   "Hide both active and inactive window border overlays"
   {:requires-traits [:trait/has-canvas]
    :fn (fn [component params]
          (when component.state.active-canvas
            (component.state.active-canvas:hide))
          (when component.state.inactive-canvas
            (component.state.inactive-canvas:hide))
          {:active-canvas component.state.active-canvas
           :inactive-canvas component.state.inactive-canvas
           :active-window-id nil})}))


{: show-active-border-command
 : show-inactive-border-command
 : hide-borders-command}
