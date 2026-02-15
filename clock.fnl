;; ============================================================================
;; CircleClock - A circle clock inset into the desktop
;; ============================================================================
;;
;; Three concentric ring arcs (seconds outer, minutes middle, hours inner)
;; that sweep clockwise to show the current time. The clock face (tick marks,
;; minute labels, and hour numbers) is drawn entirely with canvas primitives
;; -- no external image required.

(var canvas nil)
(var timer nil)

;; ============================================================================
;; Color palette
;; ============================================================================

(local colors
  {:tick         {:hex "#1A1A1A" :alpha 0.95}
   :minute-label {:hex "#1A1A1A" :alpha 0.85}
   :hour-number  {:hex "#000000" :alpha 1.0}
   :background   {:hex "#FFFFFF" :alpha 0.3}
   :sec-track    {:hex "#9E9E9E" :alpha 0.3}
   :sec-fill     {:hex "#9E9E9E" :alpha 0.1}
   :hour-track   {:hex "#FFFFFF" :alpha 0.1}
   :hour-arc     {:hex "#EC6D27" :alpha 0.75}
   :min-track    {:hex "#FFFFFF" :alpha 0.1}
   :min-arc      {:hex "#1891C3" :alpha 0.75}})

;; ============================================================================
;; Constants
;; ============================================================================

(local pi math.pi)

;; ============================================================================
;; Geometry helpers
;; ============================================================================

(fn deg->rad [deg]
  "Convert degrees to radians."
  (* deg (/ pi 180)))

(fn polar->xy [half angle-deg radius]
  "Convert a clock-position angle (0 = 12 o'clock, clockwise) and radius
   to canvas x,y coordinates relative to center (half = size/2)."
  (let [rad (deg->rad (- angle-deg 90))]
    (values (+ half (* radius (math.cos rad)))
            (+ half (* radius (math.sin rad))))))

;; ============================================================================
;; Clock face elements
;; ============================================================================

(fn make-tick-elements [half]
  "Build canvas element tables for 60 minute tick marks around the dial.
   Every 5th tick is longer and thicker."
  (let [elements []]
    (for [i 0 59]
      (let [angle (* i 6)
            major? (= 0 (% i 5))
            outer-r (* half 0.92)
            inner-r (if major? (* half 0.78) (* half 0.85))
            width (if major? 2.0 1.0)
            (x1 y1) (polar->xy half angle outer-r)
            (x2 y2) (polar->xy half angle inner-r)]
        (table.insert elements
                      {:type :segments
                       :action :stroke
                       :strokeColor colors.tick
                       :strokeWidth width
                       :coordinates [{:x x1 :y y1}
                                     {:x x2 :y y2}]})))
    elements))

(fn make-minute-label-elements [half]
  "Build canvas element tables for the minute labels (05, 10, ... 60)
   positioned just outside the tick marks."
  (let [elements []
        label-r (* half 0.97)
        font-size (math.max 6 (math.floor (* half 0.07)))
        box-size (* font-size 2.2)]
    (for [i 1 12]
      (let [minute (* i 5)
            angle (* i 30)
            label (if (< minute 10) (.. "0" (tostring minute)) (tostring minute))
            (cx cy) (polar->xy half angle label-r)]
        (table.insert elements
                      {:type :text
                       :text label
                       :textAlignment :center
                       :textColor colors.minute-label
                       :textFont "Helvetica Neue"
                       :textSize font-size
                       :frame {:x (- cx (/ box-size 2))
                               :y (- cy (/ box-size 2))
                               :w box-size
                               :h box-size}})))
    elements))

(fn make-hour-number-elements [half]
  "Build canvas element tables for the hour numbers (1-12) positioned
   inside the tick marks."
  (let [elements []
        hour-r (* half 0.66)
        font-size (math.max 10 (math.floor (* half 0.16)))
        box-size (* font-size 1.5)]
    (for [i 1 12]
      (let [angle (* i 30)
            (cx cy) (polar->xy half angle hour-r)]
        (table.insert elements
                      {:type :text
                       :text (tostring i)
                       :textAlignment :center
                       :textColor colors.hour-number
                       :textFont "Helvetica Neue Bold"
                       :textSize font-size
                       :frame {:x (- cx (/ box-size 2))
                               :y (- cy (/ box-size 2))
                               :w box-size
                               :h box-size}})))
    elements))

;; ============================================================================
;; Clock update
;; ============================================================================

;; Element indices are assigned during start; these track where the dynamic
;; arcs live in the canvas element array.
(var sec-arc-idx nil)
(var min-arc-idx nil)
(var hour-arc-idx nil)

(fn update-clock []
  "Update arc angles based on current time."
  (let [secnum (math.tointeger (os.date "%S"))
        minnum (math.tointeger (os.date "%M"))
        hournum (math.tointeger (os.date "%I"))
        secangle (* 6 secnum)
        minangle (+ (* 6 minnum) (* 0.1 secnum))
        hourangle (% (+ (* 30 hournum) (* 0.5 minnum) (* (/ 0.5 60) secnum))
                     360)]
    (tset (. canvas sec-arc-idx) :endAngle secangle)
    (tset (. canvas min-arc-idx) :endAngle minangle)
    (tset (. canvas hour-arc-idx) :endAngle hourangle)))

;; ============================================================================
;; Entry point
;; ============================================================================

(fn start-draw-clock! [cx cy clock-size]
  "Create the clock canvas centered at (cx, cy) with the given size,
   and start the update timer."
  (let [half (/ clock-size 2)]
    (set canvas (: (hs.canvas.new {:x (- cx half)
                                   :y (- cy half)
                                   :w clock-size
                                   :h clock-size})
                   :show))
    (canvas:behavior hs.canvas.windowBehaviors.canJoinAllSpaces)
    (canvas:level hs.canvas.windowLevels.desktopIcon)

    ;; Background
    (var idx 1)
    (tset canvas idx {:type :circle
                      :action :fill
                      :radius "50%"
                      :fillColor colors.background})

    ;; Tick marks (60 elements)
    (each [_ el (ipairs (make-tick-elements half))]
      (set idx (+ idx 1))
      (tset canvas idx el))

    ;; Minute labels (12 elements)
    (each [_ el (ipairs (make-minute-label-elements half))]
      (set idx (+ idx 1))
      (tset canvas idx el))

    ;; Hour numbers (12 elements)
    (each [_ el (ipairs (make-hour-number-elements half))]
      (set idx (+ idx 1))
      (tset canvas idx el))

    ;; Seconds track + arc
    (set idx (+ idx 1))
    (tset canvas idx {:id :watch_circle
                      :type :circle
                      :action :stroke
                      :radius "40%"
                       :strokeColor colors.sec-track})
    (set idx (+ idx 1))
    (set sec-arc-idx idx)
    (tset canvas idx {:id :watch_sechand
                      :type :arc
                      :radius "40%"
                      :fillColor colors.sec-fill
                      :strokeColor colors.sec-track
                      :endAngle 0})

    ;; Hours track + arc
    (set idx (+ idx 1))
    (tset canvas idx {:id :watch_hourcircle
                      :type :circle
                      :action :stroke
                      :radius "20%"
                      :strokeWidth 3
                       :strokeColor colors.hour-track})
    (set idx (+ idx 1))
    (set hour-arc-idx idx)
    (tset canvas idx {:id :watch_hourarc
                      :type :arc
                      :action :stroke
                      :radius "20%"
                      :arcRadii false
                      :strokeWidth 3
                      :strokeColor colors.hour-arc
                      :endAngle 0})

    ;; Minutes track + arc
    (set idx (+ idx 1))
    (tset canvas idx {:id :watch_mincircle
                      :type :circle
                      :action :stroke
                      :radius "27%"
                      :strokeWidth 3
                       :strokeColor colors.min-track})
    (set idx (+ idx 1))
    (set min-arc-idx idx)
    (tset canvas idx {:id :watch_minarc
                      :type :arc
                      :action :stroke
                      :radius "27%"
                      :arcRadii false
                      :strokeWidth 3
                      :strokeColor colors.min-arc
                      :endAngle 0})

    ;; Start the timer
    (if (not timer)
        (set timer (hs.timer.doEvery 1 update-clock))
        (timer:start))))

{: start-draw-clock!}
