(local eligibility (require :paper-wm.eligibility))

(local standard {:window-id 1
                 :role "AXWindow"
                 :subrole "AXStandardWindow"
                 :has-titlebar true
                 :visible true
                 :fullscreen false
                 :tab-count 0
                 :space-id 2})

(assert (eligibility.eligible? standard))

(each [key value (pairs {:subrole "AXDialog"
                         :has-titlebar false
                         :visible false
                         :fullscreen true
                         :tab-count 1
                         :space-id nil})]
  (let [candidate {}]
    (each [fact-key fact-value (pairs standard)]
      (tset candidate fact-key fact-value))
    (tset candidate key value)
    (assert (= false (eligibility.eligible? candidate))
            (.. "accepted unsuitable " (tostring key)))))

(assert (= false (eligibility.eligible? nil)))

(print "PaperWM eligibility passed")
