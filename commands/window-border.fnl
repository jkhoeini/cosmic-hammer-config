
;; commands/window-border.fnl
;; Commands: show/hide window border overlays

(local {: make-command} (require :sheaf.command-registry))

(fn resolve-corner-radius [window-id default-radius]
  (let [has-api (and hs.window hs.window.cornerRadiusForID)]
    (if has-api
        (let [(ok detected) (pcall hs.window.cornerRadiusForID window-id)]
          (if (and ok detected (> detected 0)) detected default-radius))
        default-radius)))

(fn position-border-canvas [canvas bw cr frame]
  (let [outer-radius (+ cr bw)]
    (canvas:frame {:x (- frame.x bw)
                   :y (- frame.y bw)
                   :w (+ frame.w (* 2 bw))
                   :h (+ frame.h (* 2 bw))})
    (canvas:elementAttribute 1 :roundedRectRadii
                             {:xRadius outer-radius :yRadius outer-radius})
    (canvas:elementAttribute 2 :frame
                             {:x bw :y bw :w frame.w :h frame.h})
    (canvas:elementAttribute 2 :roundedRectRadii
                             {:xRadius cr :yRadius cr})
    (canvas:show)))


(local show-active-border-command
  (make-command
   :window-border.commands/show-active-border
   "Position and show the active window border around a window frame"
   {:requires-traits [:trait/has-canvas]
    :fn (fn [component params]
          (when (and params.only-if-active
                     (not= params.window-id component.state.active-window-id))
            (lua "return nil"))
          (let [bw component.state.border-width
                cr (resolve-corner-radius params.window-id
                                          component.state.default-corner-radius)]
            (position-border-canvas component.state.active-canvas
                                    bw cr params.frame))
          {:active-canvas component.state.active-canvas
           :inactive-canvas component.state.inactive-canvas
           :active-window-id params.window-id
           :border-width component.state.border-width
           :default-corner-radius component.state.default-corner-radius})}))


(local show-inactive-border-command
  (make-command
   :window-border.commands/show-inactive-border
   "Position and show the inactive window border around a window frame"
   {:requires-traits [:trait/has-canvas]
    :fn (fn [component params]
          (let [bw component.state.border-width
                cr (resolve-corner-radius params.window-id
                                          component.state.default-corner-radius)]
            (position-border-canvas component.state.inactive-canvas
                                    bw cr params.frame))
          nil)}))


(local hide-borders-command
  (make-command
   :window-border.commands/hide-borders
   "Hide both active and inactive window border overlays"
   {:requires-traits [:trait/has-canvas]
    :fn (fn [component params]
          (when (and params.only-if-active
                     (not= params.window-id component.state.active-window-id))
            (lua "return nil"))
          (when component.state.active-canvas
            (component.state.active-canvas:hide))
          (when component.state.inactive-canvas
            (component.state.inactive-canvas:hide))
          {:active-canvas component.state.active-canvas
           :inactive-canvas component.state.inactive-canvas
           :active-window-id nil
           :border-width component.state.border-width
           :default-corner-radius component.state.default-corner-radius})}))


{: show-active-border-command
 : show-inactive-border-command
 : hide-borders-command}
