(fn empty-state []
  {:spaces {} :index {} :focused-window-id nil})

(fn copy-spaces [spaces]
  (let [result {}]
    (each [space columns (pairs spaces)]
      (let [copied-columns []]
        (each [_ column (ipairs columns)]
          (let [copied-column []]
            (each [_ window-id (ipairs column)]
              (table.insert copied-column window-id))
            (table.insert copied-columns copied-column)))
        (tset result space copied-columns)))
    result))

(fn copy-state [state]
  {:spaces (copy-spaces state.spaces)
   :index {}
   :focused-window-id state.focused-window-id})

(fn rebuild-index! [state]
  (let [index {}]
    (each [space columns (pairs state.spaces)]
      (each [col column (ipairs columns)]
        (each [row window-id (ipairs column)]
          (tset index window-id {:space space :col col :row row}))))
    (tset state :index index)
    state))

(fn valid? [state]
  (let [seen {}]
    (each [space columns (pairs (or state.spaces {}))]
      (each [col column (ipairs columns)]
        (when (= 0 (length column))
          (lua "return false, 'empty-column'"))
        (each [row window-id (ipairs column)]
          (when (. seen window-id)
            (lua "return false, 'duplicate-window-id'"))
          (tset seen window-id true)
          (let [entry (. (or state.index {}) window-id)]
            (when (or (= nil entry) (not= space entry.space)
                      (not= col entry.col) (not= row entry.row))
              (lua "return false, 'index-mismatch'"))))))
    (each [window-id _ (pairs (or state.index {}))]
      (when (not (. seen window-id))
        (lua "return false, 'extra-index-entry'")))
    (when (and state.focused-window-id
               (not (. seen state.focused-window-id)))
      (lua "return false, 'missing-focused-window'"))
    true))

(fn add-window [state window-id space column]
  (when (. state.index window-id) (lua "return state"))
  (let [next-state (copy-state state)
        columns (or (. next-state.spaces space) [])
        insertion-column (math.max 1 (math.min column (+ (length columns) 1)))]
    (tset next-state.spaces space columns)
    (table.insert columns insertion-column [window-id])
    (rebuild-index! next-state)))

(fn remove-window [state window-id]
  (let [entry (. state.index window-id)]
    (when (= nil entry) (lua "return state"))
    (let [next-state (copy-state state)
          columns (. next-state.spaces entry.space)
          column (. columns entry.col)]
      (table.remove column entry.row)
      (when (= 0 (length column)) (table.remove columns entry.col))
      (when (= 0 (length columns)) (tset next-state.spaces entry.space nil))
      (when (= window-id next-state.focused-window-id)
        (tset next-state :focused-window-id nil))
      (rebuild-index! next-state))))

(fn move-window [state window-id space column]
  (when (= nil (. state.index window-id)) (lua "return state"))
  (let [focused state.focused-window-id
        moved (add-window (remove-window state window-id) window-id space column)]
    (tset moved :focused-window-id focused)
    moved))

(fn slurp-window [state window-id]
  (let [entry (. state.index window-id)]
    (when (or (= nil entry) (<= entry.col 1)) (lua "return state"))
    (let [next-state (copy-state state)
          columns (. next-state.spaces entry.space)
          source (. columns entry.col)
          target (. columns (- entry.col 1))]
      (table.remove source entry.row)
      (when (= 0 (length source)) (table.remove columns entry.col))
      (table.insert target window-id)
      (rebuild-index! next-state))))

(fn barf-window [state window-id]
  (let [entry (. state.index window-id)]
    (when (= nil entry) (lua "return state"))
    (when (<= (length (. state.spaces entry.space entry.col)) 1)
      (lua "return state"))
    (let [next-state (copy-state state)
          columns (. next-state.spaces entry.space)
          source (. columns entry.col)]
      (table.remove source entry.row)
      (table.insert columns (+ entry.col 1) [window-id])
      (rebuild-index! next-state))))

(fn swap-window [state window-id direction]
  (let [entry (. state.index window-id)]
    (when (= nil entry) (lua "return state"))
    (let [next-state (copy-state state)
          columns (. next-state.spaces entry.space)]
      (if (or (= direction :left) (= direction :right))
          (let [offset (if (= direction :left) -1 1)
                target-col (+ entry.col offset)]
            (when (or (< target-col 1) (> target-col (length columns)))
              (lua "return state"))
            (let [source (. columns entry.col)]
              (tset columns entry.col (. columns target-col))
              (tset columns target-col source)))
          (or (= direction :up) (= direction :down))
          (let [column (. columns entry.col)
                offset (if (= direction :up) -1 1)
                target-row (+ entry.row offset)]
            (when (or (< target-row 1) (> target-row (length column)))
              (lua "return state"))
            (let [target-id (. column target-row)]
              (tset column target-row window-id)
              (tset column entry.row target-id)))
          (lua "return state"))
      (rebuild-index! next-state))))

(fn focus-target [state window-id direction]
  (let [entry (. state.index window-id)]
    (when (= nil entry) (lua "return nil"))
    (if (or (= direction :left) (= direction :right))
        (let [offset (if (= direction :left) -1 1)
              column (. state.spaces entry.space (+ entry.col offset))]
          (when column
            (for [row entry.row 1 -1]
              (let [target (. column row)]
                (when target (lua "return target"))))))
        (or (= direction :up) (= direction :down))
        (let [offset (if (= direction :up) -1 1)]
          (. state.spaces entry.space entry.col (+ entry.row offset)))
        nil)))

(fn set-focused-window [state window-id]
  (when (and window-id (= nil (. state.index window-id)))
    (lua "return state"))
  (let [next-state (copy-state state)]
    (tset next-state :focused-window-id window-id)
    (rebuild-index! next-state)))

{: empty-state
 : valid?
 : add-window
 : remove-window
 : move-window
 : slurp-window
 : barf-window
 : swap-window
 : focus-target
 : set-focused-window}
