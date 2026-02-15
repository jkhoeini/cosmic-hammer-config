;; ============================================================================
;; Calendar - A calendar widget inset into the desktop
;; ============================================================================
;;
;; Renders the current month as a grid on the desktop background.
;; Highlights today and shows ISO week numbers.
;; Auto-refreshes every 30 minutes.
;;
;; Original Spoon by ashfinal <ashfinal@gmail.com>
;; Ported to Fennel module.

;; ============================================================================
;; Configuration
;; ============================================================================

(local calw 260)
(local calh 184)

;; ============================================================================
;; Colors
;; ============================================================================

(local today-color {:red 1 :green 1 :blue 1 :alpha 0.3})
(local cal-color {:red (/ 235 255) :green (/ 235 255) :blue (/ 235 255)})
(local bg-color {:red 0 :green 0 :blue 0 :alpha 0.3})
(local weeknum-color {:red (/ 246 255) :green (/ 246 255) :blue (/ 246 255) :alpha 0.5})

;; ============================================================================
;; Layout helpers
;; ============================================================================

(local cell-w (/ (- calw 20) 8))
(local cell-h (/ (- calh 20) 8))

(fn cell-x [col]
  "X position for a given column (1-indexed)."
  (tostring (/ (+ 10 (* cell-w col)) calw)))

(fn cell-y [row]
  "Y position for a given row (1-indexed)."
  (tostring (/ (+ 10 (* cell-h row)) calh)))

(fn cell-frame [col row]
  "Frame table for a cell at the given column and row."
  {:x (cell-x col)
   :y (cell-y row)
   :w (tostring (/ cell-w calw))
   :h (tostring (/ cell-h calh))})

(fn text-element [col row text color ?id]
  "Create a text canvas element at the given grid position."
  {:type :text
   :id (or ?id nil)
   :text text
   :textFont :Courier
   :textSize 16
   :textColor color
   :textAlignment :center
   :frame (cell-frame col row)})

;; ============================================================================
;; State
;; ============================================================================

(var canvas nil)
(var timer nil)

;; ============================================================================
;; Canvas index layout
;; ============================================================================
;;
;;  1       - background rectangle
;;  2       - title (month year)
;;  3-9     - weekday headers (Mo Tu We Th Fr Sa Su)
;;  10-51   - day grid (6 rows x 7 cols)
;;  52-57   - week number column (6 rows)
;;  58      - today highlight rectangle

;; ============================================================================
;; Update logic
;; ============================================================================

(fn update-cal-canvas []
  "Refresh the calendar canvas with the current date."
  (let [title (os.date "%B %Y")
        year (os.date "%Y")
        month (os.date "%m")
        day (os.date "%d")
        first-of-next (os.time {:year year :month (+ month 1) :day 1})
        max-day (. (os.date :*t (- first-of-next (* 24 60 60))) :day)
        first-wday (. (os.date :*t (os.time {:year year :month month :day 1})) :wday)
        needed-rows (math.ceil (/ (+ first-wday max-day -1) 7))]
    ;; Title
    (tset (. canvas 2) :text title)
    ;; Day grid
    (for [i 1 needed-rows]
      (for [k 1 7]
        (let [idx (+ (* 7 (- i 1)) k)
              day-num (+ (- idx first-wday) 2)
              canvas-idx (+ 9 idx)]
          (if (or (<= day-num 0) (> day-num max-day))
              (tset (. canvas canvas-idx) :text "")
              (tset (. canvas canvas-idx) :text day-num))
          (when (= day-num (math.tointeger day))
            (tset (. canvas 58 :frame) :x (cell-x k))
            (tset (. canvas 58 :frame) :y (cell-y (+ i 1)))))))
    ;; Week numbers
    (let [yearweek-start (hs.execute "date -v1d +'%W'")]
      (for [i 1 6]
        (let [wk (+ (math.tointeger yearweek-start) i -1)]
          (tset (. canvas (+ 51 i)) :text
                (if (> i needed-rows) "" wk)))))
    ;; Trim canvas height to needed rows
    (canvas:size {:w calw
                  :h (+ 20 (* cell-h (+ needed-rows 2)))})))

;; ============================================================================
;; Initialization
;; ============================================================================

(fn show-calendar [x y]
  "Create the calendar canvas at position (x, y) and start the refresh timer."
  (do
    ;; Create canvas
    (set canvas (: (hs.canvas.new {:x x :y y :w calw :h calh})
                   :show))
    (canvas:behavior hs.canvas.windowBehaviors.canJoinAllSpaces)
    (canvas:level hs.canvas.windowLevels.desktopIcon)
    ;; Background
    (tset canvas 1 {:type :rectangle
                    :id :cal_bg
                    :action :fill
                    :fillColor bg-color
                    :roundedRectRadii {:xRadius 10 :yRadius 10}})
    ;; Title
    (tset canvas 2 {:type :text
                    :id :cal_title
                    :text ""
                    :textFont :Courier
                    :textSize 16
                    :textColor cal-color
                    :textAlignment :center
                    :frame {:x (tostring (/ 10 calw))
                            :y (tostring (/ 10 calw))
                            :w (tostring (- 1 (/ 20 calw)))
                            :h (tostring (/ cell-h calh))}})
    ;; Weekday headers
    (let [weeknames [:Mo :Tu :We :Th :Fr :Sa :Su]]
      (each [i name (ipairs weeknames)]
        (tset canvas (+ 2 i) (text-element i 1 name cal-color :cal_weekday))))
    ;; Day grid (6 rows x 7 cols)
    (for [row 1 6]
      (for [col 1 7]
        (tset canvas (+ 9 (* 7 (- row 1)) col)
              (text-element col (+ row 1) "" cal-color))))
    ;; Week number column
    (for [row 1 6]
      (tset canvas (+ 51 row)
            (text-element 0 (+ row 1) "" weeknum-color)))
    ;; Today highlight
    (tset canvas 58 {:type :rectangle
                     :action :fill
                     :fillColor today-color
                     :roundedRectRadii {:xRadius 3 :yRadius 3}
                     :frame (cell-frame 1 2)})
    ;; Timer: refresh every 30 minutes
    (if (= timer nil)
        (do
          (set timer (hs.timer.doEvery 1800 update-cal-canvas))
          (timer:setNextTrigger 0))
        (timer:start))))

;; ============================================================================
;; Public API
;; ============================================================================

{: show-calendar}
