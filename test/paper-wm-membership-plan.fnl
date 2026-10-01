(local {: plan-membership} (require :paper-wm.membership))
(local layout (require :paper-wm.layout))

(fn fact [window-id space-id overrides]
  (let [result {:window-id window-id :space-id space-id
                :subrole "AXStandardWindow" :has-titlebar true :visible true
                :fullscreen false :tab-count 0}]
    (each [key value (pairs (or overrides {}))] (tset result key value))
    result))

(fn contains? [list value]
  (var found false)
  (each [_ item (ipairs list)] (when (= item value) (set found true)))
  found)

(local live-all {:live? #true})

(local tracked
  (-> (layout.empty-state)
      (layout.add-window 1 7 1)
      (layout.add-window 2 7 2)))

;; Tracked-then-ineligible windows are removed and reported as removed.
(let [plan (plan-membership tracked [(fact 2 7 {:fullscreen true})] live-all)]
  (assert (= nil (. plan.state.index 2)))
  (assert (contains? plan.report.removed 2) "ineligible removal not reported as removed")
  (assert (not (contains? plan.report.rejected 2)) "ineligible removal reported as rejected")
  (assert (contains? plan.detach 2)))

;; Conflicting facts for one untracked window leave no handle to attach.
(let [plan (plan-membership tracked [(fact 6 7) (fact 6 7 {:visible false})] live-all)]
  (assert (= nil (. plan.state.index 6)))
  (assert (= 0 (length plan.attach)) "attached a window that ended untracked")
  (assert (= 0 (length plan.detach)) "detached a window that was never tracked"))

;; Untracked ineligible or unresolvable windows are rejected without changes.
(let [plan (plan-membership tracked [(fact 3 7 {:visible false}) (fact 4 7)]
                            {:live? #(not= $1 4)})]
  (assert (= tracked plan.state))
  (assert (and (contains? plan.report.rejected 3) (contains? plan.report.rejected 4)))
  (assert (= 0 (length plan.attach)))
  (assert (= 0 (length plan.touched-spaces))))

;; Unchanged members touch nothing; additions and moves touch their Spaces once.
(let [plan (plan-membership tracked [(fact 1 7) (fact 2 8) (fact 5 7) (fact 5 7)]
                            live-all)]
  (assert (contains? plan.report.added 5))
  (assert (= 1 (length plan.report.added)) "duplicate fact added twice")
  (assert (contains? plan.report.moved 2))
  (assert (= 8 (. plan.state.index 2 :space)))
  (assert (= 2 (length plan.touched-spaces)) "each touched Space must appear once")
  (assert (contains? plan.touched-spaces 7))
  (assert (contains? plan.touched-spaces 8)))

;; Snapshot plans remove unseen members only when asked.
(let [off-space (layout.add-window tracked 9 8 1)
      single (plan-membership off-space [(fact 1 7)] live-all)
      snapshot (plan-membership off-space [(fact 1 7)]
                                {:live? #true :observed-spaces [7]})]
  (assert (= 2 (. single.state.index 2 :col)) "single fact removed an unseen member")
  (assert (= nil (. snapshot.state.index 2)) "unseen member of an observed Space kept")
  (assert (contains? snapshot.report.removed 2))
  (assert (= 8 (. snapshot.state.index 9 :space))
          "snapshot removed a member of a Space it cannot observe")
  (assert (not (contains? snapshot.report.removed 9)))
  (assert (layout.valid? snapshot.state)))

;; New windows join right of the recorded focused column (upstream PaperWM);
;; without focus on that Space, by horizontal position among column heads.
(fn framed [window-id space-id x]
  (fact window-id space-id {:frame {:x x :y 0 :w 100 :h 100}}))
(let [three (layout.add-window tracked 3 7 3)
      focused (layout.set-focused-window three 1)
      plan (plan-membership focused [(framed 4 7 900)] live-all)]
  (assert (= 2 (. plan.state.index 4 :col)) "new window not inserted right of focus"))
(let [centers {1 50 2 450}
      plan (plan-membership tracked [(framed 5 7 200)]
                            {:live? #true :center-x #(. centers $1)})]
  (assert (= 2 (. plan.state.index 5 :col)) "new window not placed by position")
  (assert (= 3 (. plan.state.index 2 :col))))
(let [plan (plan-membership tracked [(framed 6 7 2000)]
                            {:live? #true :center-x #(. {1 50 2 450} $1)})]
  (assert (= 3 (. plan.state.index 6 :col)) "rightmost window not appended"))

(print "PaperWM membership plan passed")
