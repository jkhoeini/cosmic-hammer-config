
;; components/window-border.fnl
;; Component type: Window border overlay using hs.canvas

(local {: make-component-type} (require :sheaf.component-registry))

(fn parse-argb-hex [hex-str]
  "Parse '0xAARRGGBB' hex color string into {red green blue alpha} table (0.0-1.0)"
  (let [n (tonumber hex-str)
        a (/ (band (rshift n 24) 0xFF) 255)
        r (/ (band (rshift n 16) 0xFF) 255)
        g (/ (band (rshift n 8) 0xFF) 255)
        b (/ (band n 0xFF) 255)]
    {:red r :green g :blue b :alpha a}))

(fn make-border-canvas [color width corner-radius]
  "Create a hidden canvas with two filled rects: outer fill + inner cutout via destinationOut"
  (let [outer-radius (+ corner-radius width)
        canvas (hs.canvas.new {:x 0 :y 0 :w 100 :h 100})]
    (canvas:insertElement {:type "rectangle"
                           :action "fill"
                           :fillColor (parse-argb-hex color)
                           :roundedRectRadii {:xRadius outer-radius :yRadius outer-radius}})
    (canvas:insertElement {:type "rectangle"
                           :action "fill"
                           :fillColor {:red 0 :green 0 :blue 0 :alpha 1}
                           :compositeRule "destinationOut"
                           :frame {:x width :y width :w 80 :h 80}
                           :roundedRectRadii {:xRadius corner-radius :yRadius corner-radius}})
    (canvas:level (. hs.canvas.windowLevels :overlay))
    (canvas:behavior (bor (. hs.canvas.windowBehaviors :canJoinAllSpaces)
                         (. hs.canvas.windowBehaviors :stationary)))
    canvas))

(local window-border-type
  (make-component-type
   :component.type/window-border
   "Draws colored borders around active and inactive windows"
   {:traits [:trait/has-canvas]
    :start-fn (fn [config]
                (let [cr (or config.corner-radius 9)
                      active (make-border-canvas config.active-color config.width cr)
                      inactive (make-border-canvas config.inactive-color config.width cr)]
                  {:active-canvas active
                   :inactive-canvas inactive
                   :active-window-id nil
                   :border-width config.width
                   :default-corner-radius cr}))
    :stop-fn (fn [state]
               (when state.active-canvas
                 (state.active-canvas:delete))
               (when state.inactive-canvas
                 (state.inactive-canvas:delete)))}))

{: window-border-type}
