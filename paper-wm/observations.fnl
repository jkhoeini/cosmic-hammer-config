(fn next-observation [state window-id event-kind frame generation]
  "Record the latest bounded frame observation for one window."
  (let [sequence (+ 1 (or (. state.sequences window-id) 0))
        observation {:window-id window-id
                     :event-kind event-kind
                     :frame frame
                     :generation generation
                     :sequence sequence}]
    (tset state.sequences window-id sequence)
    (tset state.latest window-id observation)
    observation))

(fn consume-latest [state window-id generation sequence]
  "Consume only the latest matching observation; stale deliveries are no-ops."
  (let [observation (. state.latest window-id)]
    (when (and observation
               (= generation observation.generation)
               (= sequence observation.sequence))
      (tset state.latest window-id nil)
      observation)))

{: next-observation : consume-latest}
