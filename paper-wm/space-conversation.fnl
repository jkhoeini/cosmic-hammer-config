(fn start [state target-space target-window-id now timeout]
  "Start a generation-scoped Space focus operation."
  (let [generation (+ 1 state.next-generation)
        operation {:generation generation
                   :target-space target-space
                   :target-window-id target-window-id
                   :attempt 0
                   :stable-count 0
                   :deadline (+ now timeout)}]
    (tset state :next-generation generation)
    (tset state :active operation)
    operation))

(fn advance [state generation now space-focused? window-focused?]
  "Advance one retry observation to stale, retry, timeout, or complete."
  (let [operation state.active]
    (when (or (= nil operation) (not= generation operation.generation))
      (lua "return {outcome = 'stale'}"))
    (when (> now operation.deadline)
      (tset state :active nil)
      (lua "return {outcome = 'timeout'}"))
    (tset operation :attempt (+ operation.attempt 1))
    (if (and space-focused?
             (or (= nil operation.target-window-id) window-focused?))
        (tset operation :stable-count (+ operation.stable-count 1))
        (tset operation :stable-count 0))
    (if (>= operation.stable-count 3)
        (do
          (tset state :active nil)
          {:outcome :complete :operation operation})
        {:outcome :retry :operation operation})))

{: start : advance}
