(local observations (require :paper-wm.observations))

(local state {:sequences {} :latest {}})
(local first (observations.next-observation state 10 :moved {:x 1} 3))
(local second (observations.next-observation state 10 :resized {:x 2} 3))

(assert (= 1 first.sequence))
(assert (= 2 second.sequence))
(assert (= second (. state.latest 10)))
(assert (= nil (observations.consume-latest state 10 3 1)))
(assert (= nil (observations.consume-latest state 10 2 2)))
(assert (= second (observations.consume-latest state 10 3 2)))
(assert (= nil (. state.latest 10)))

(print "PaperWM observations passed")
