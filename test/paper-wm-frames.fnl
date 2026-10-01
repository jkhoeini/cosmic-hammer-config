(local frames (require :paper-wm.frames))

(local entries
  [{:window-id 10 :frame {:x 20 :y 20 :w 400 :h 200 :x2 420 :y2 220}}
   {:window-id 20 :frame {:x 20 :y 240 :w 400 :h 300 :x2 420 :y2 540}}])
(local bounds {:x 100 :x2 nil :y 50 :y2 650})

(local (plan width)
  (frames.plan-column entries bounds
                      {:gap 10 :height 295 :width 500
                       :anchor-window-id 20 :anchor-height 200}))

(assert (= 500 width))
(assert (= 10 (. plan 1 :window-id)))
(assert (= 100 (. plan 1 :frame :x)))
(assert (= 50 (. plan 1 :frame :y)))
(assert (= 500 (. plan 1 :frame :w)))
(assert (= 295 (. plan 1 :frame :h)))
(assert (= 20 (. plan 2 :window-id)))
(assert (= 355 (. plan 2 :frame :y)))
(assert (= 295 (. plan 2 :frame :h)))
(assert (= 650 (. plan 2 :frame :y2)))
(assert (= 20 (. entries 1 :frame :x)) "planner mutated input frame")
(assert (= 50 bounds.y) "planner mutated bounds")

(local (right-plan right-width)
  (frames.plan-column [(. entries 1)] {:x nil :x2 900 :y 0 :y2 300}
                      {:gap 10}))
(assert (= 400 right-width))
(assert (= 500 (. right-plan 1 :frame :x)))
(assert (= 300 (. right-plan 1 :frame :h)))

;; An anchor taller than the column leaves later windows their minimum height.
(local (squeezed)
  (frames.plan-column
   [{:window-id 1 :frame {:x 0 :y 0 :w 300 :h 500}}
    {:window-id 2 :frame {:x 0 :y 0 :w 300 :h 500}}
    {:window-id 3 :frame {:x 0 :y 0 :w 300 :h 500}}]
   {:x 0 :y 0 :y2 600}
   {:gap 10 :height 0 :min-height 80 :anchor-window-id 1 :anchor-height 600}))
(each [_ intent (ipairs squeezed)]
  (assert (<= 80 intent.frame.h)
          (.. "window " intent.window-id " squeezed to height " intent.frame.h)))
(assert (= 600 (. squeezed 3 :frame :y2)) "column does not reach the bottom")
(assert (<= (+ (. squeezed 1 :frame :y2) 10) (. squeezed 2 :frame :y))
        "windows overlap")

;; A column too short for every window at min-height shares it without overlap.
(local (crowded)
  (frames.plan-column
   (fcollect [id 1 8] {:window-id id :frame {:x 0 :y 0 :w 300 :h 300}})
   {:x 0 :y 0 :y2 600}
   {:gap 10 :min-height 80}))
(for [index 2 8]
  (assert (<= (+ (. crowded (- index 1) :frame :y2) 10) (. crowded index :frame :y))
          (.. "window " index " overlaps the one above")))
(assert (= 600 (. crowded 8 :frame :y2)) "crowded column overflows its bounds")

(print "PaperWM frame planning passed")
