(local layout (require :paper-wm.layout))

(local state (layout.empty-state))
(assert (layout.valid? state))

(local s1 (layout.add-window state 10 1 1))
(assert (= nil (. state.spaces 1)) "add mutated prior state")
(assert (= 10 (. s1.spaces 1 1 1)))
(assert (= 1 (. s1.index 10 :col)))

(local duplicate (layout.add-window s1 10 1 1))
(assert (= s1 duplicate) "duplicate add must be idempotent")

(local s2 (layout.add-window s1 20 1 2))
(local s3 (layout.add-window s2 30 1 2))
(assert (= 10 (. s3.spaces 1 1 1)))
(assert (= 30 (. s3.spaces 1 2 1)))
(assert (= 20 (. s3.spaces 1 3 1)))
(assert (layout.valid? s3))

(local stacked (layout.slurp-window s3 30))
(assert (= 30 (. stacked.spaces 1 1 2)))
(assert (= 2 (. stacked.index 30 :row)))
(assert (= 20 (. stacked.spaces 1 2 1)))
(assert (layout.valid? stacked))

(local barfed (layout.barf-window stacked 30))
(assert (= 10 (. barfed.spaces 1 1 1)))
(assert (= 30 (. barfed.spaces 1 2 1)))
(assert (= 20 (. barfed.spaces 1 3 1)))
(assert (layout.valid? barfed))

(local swapped-horizontal (layout.swap-window barfed 30 :right))
(assert (= 20 (. swapped-horizontal.spaces 1 2 1)))
(assert (= 30 (. swapped-horizontal.spaces 1 3 1)))
(assert (= 3 (. swapped-horizontal.index 30 :col)))
(assert (layout.valid? swapped-horizontal))

(local vertical-base (layout.slurp-window barfed 30))
(local swapped-vertical (layout.swap-window vertical-base 30 :up))
(assert (= 30 (. swapped-vertical.spaces 1 1 1)))
(assert (= 10 (. swapped-vertical.spaces 1 1 2)))
(assert (layout.valid? swapped-vertical))

(assert (= 10 (layout.focus-target vertical-base 30 :up)))
(assert (= 20 (layout.focus-target vertical-base 30 :right)))
(assert (= nil (layout.focus-target vertical-base 30 :left)))

(local removed (layout.remove-window vertical-base 10))
(assert (= 30 (. removed.spaces 1 1 1)))
(assert (= nil (. removed.index 10)))
(assert (= 1 (. removed.index 30 :row)))
(assert (layout.valid? removed))

(local removed-column (layout.remove-window barfed 30))
(assert (= 20 (. removed-column.spaces 1 2 1)))
(assert (= 2 (. removed-column.index 20 :col)))
(assert (layout.valid? removed-column))

(local moved-space (layout.move-window s2 20 2 1))
(assert (= nil (. moved-space.spaces 1 2)))
(assert (= 20 (. moved-space.spaces 2 1 1)))
(assert (= 2 (. moved-space.index 20 :space)))
(assert (layout.valid? moved-space))

(local focused (layout.set-focused-window s2 20))
(assert (= 20 focused.focused-window-id))
(local focus-removed (layout.remove-window focused 20))
(assert (= nil focus-removed.focused-window-id))

(local invalid {:spaces {1 [[[10] [10]]]}
                :index {10 {:space 1 :col 1 :row 1}}
                :focused-window-id nil})
(local ok reason (layout.valid? invalid))
(assert (= false ok))
(assert (= :duplicate-window-id reason))

(print "PaperWM layout transitions passed")
