(fn copy-frame [frame]
  {:x frame.x :y frame.y :w frame.w :h frame.h
   :x2 frame.x2 :y2 frame.y2})

(fn update-edges! [frame]
  (tset frame :x2 (+ frame.x frame.w))
  (tset frame :y2 (+ frame.y frame.h))
  frame)

(fn plan-column [entries bounds opts]
  "Return inert frame intents and the computed column width.
   Each window keeps at least opts.min-height (default 1), reserving room for
   the windows below it, so an oversized anchor or neighbor cannot squeeze
   later windows to a zero or negative height. When the column cannot hold
   every window at that height, the minimum shrinks to an equal share."
  (let [plan []
        gap (or opts.gap 0)
        count (length entries)
        fair-share (math.floor (/ (- bounds.y2 bounds.y (* (- count 1) gap))
                                  (math.max 1 count)))
        min-height (math.max 1 (math.min (or opts.min-height 1) fair-share))
        first-entry (. entries 1)
        column-width (or opts.width (and first-entry first-entry.frame.w))]
    (var y-start bounds.y)
    (each [index entry (ipairs entries)]
      (let [frame (copy-frame entry.frame)
            height (if (and opts.anchor-window-id opts.anchor-height
                            (= entry.window-id opts.anchor-window-id))
                       opts.anchor-height
                       (or opts.height frame.h))
            below (- (length entries) index)
            room (- bounds.y2 y-start (* below (+ min-height gap)))]
        (set frame.x (if bounds.x bounds.x (- bounds.x2 column-width)))
        (set frame.y y-start)
        (set frame.w column-width)
        (set frame.h (math.max min-height (math.min height room)))
        (update-edges! frame)
        (table.insert plan {:window-id entry.window-id :frame frame})
        (set y-start (math.min (+ frame.y2 gap) bounds.y2))))
    (let [last-intent (. plan (length plan))]
      (when (and last-intent (< last-intent.frame.y2 bounds.y2))
        (set last-intent.frame.h (- bounds.y2 last-intent.frame.y))
        (update-edges! last-intent.frame)))
    (values plan column-width)))

{: plan-column}
