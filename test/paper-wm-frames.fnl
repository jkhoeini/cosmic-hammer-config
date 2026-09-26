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

(print "PaperWM frame planning passed")
