
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

(fn make-border-canvas [color width]
  "Create a hidden canvas with a stroke-only rectangle for use as a window border"
  (let [canvas (hs.canvas.new {:x 0 :y 0 :w 100 :h 100})]
    (canvas:insertElement {:type "rectangle"
                           :action "stroke"
                           :strokeWidth width
                           :strokeColor (parse-argb-hex color)
                           :roundedRectRadii {:xRadius 0 :yRadius 0}})
    (canvas:level (. hs.canvas.windowLevels :overlay))
    (canvas:behavior (+ (. hs.canvas.windowBehaviors :canJoinAllSpaces)
                        (. hs.canvas.windowBehaviors :stationary)))
    canvas))

(local window-border-type
  (make-component-type
   :component.type/window-border
   "Draws colored borders around active and inactive windows"
   {:traits [:trait/has-canvas]
    :start-fn (fn [config]
                (let [active (make-border-canvas config.active-color config.width)
                      inactive (make-border-canvas config.inactive-color config.width)]
                  {:active-canvas active
                   :inactive-canvas inactive
                   :active-window-id nil}))
    :stop-fn (fn [state]
               (when state.active-canvas
                 (state.active-canvas:delete))
               (when state.inactive-canvas
                 (state.inactive-canvas:delete)))}))

{: window-border-type}
