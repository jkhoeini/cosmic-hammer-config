(local {: add-window : remove-window : move-window} (require :paper-wm.layout))
(local {: eligible?} (require :paper-wm.eligibility))

(fn append-column [state space]
  (+ 1 (length (or (. state.spaces space) []))))

(fn sorted-keys [members]
  (let [keys (icollect [key _ (pairs members)] key)]
    (table.sort keys)
    keys))

(fn membership-effects [before after]
  "Diff two layout states into handle attach/detach IDs and touched Spaces."
  (let [attach {}
        detach {}
        touched {}]
    (each [window-id entry (pairs after.index)]
      (let [prior (. before.index window-id)]
        (when (or (= nil prior) (not= prior.space entry.space))
          (tset attach window-id true)
          (tset touched entry.space true)
          (when prior (tset touched prior.space true)))))
    (each [window-id prior (pairs before.index)]
      (when (= nil (. after.index window-id))
        (tset detach window-id true)
        (tset touched prior.space true)))
    {:attach (sorted-keys attach)
     :detach (sorted-keys detach)
     :touched-spaces (sorted-keys touched)}))

(fn plan-membership [state facts opts]
  "Fold window facts into the next layout state without effects.
   opts.live? (window-id -> bool) gates additions on a resolvable window;
   opts.remove-unseen? also removes tracked windows absent from facts.
   Returns {:state :report :attach :detach :touched-spaces}. Report lists
   :added/:moved/:removed IDs that changed membership and :rejected IDs that
   were ineligible or unresolvable and never tracked."
  (var next-state state)
  (let [report {:added [] :moved [] :removed [] :rejected []}
        seen {}
        remove! (fn [window-id]
                  (set next-state (remove-window next-state window-id))
                  (table.insert report.removed window-id))]
    (each [_ fact (ipairs facts)]
      (let [window-id fact.window-id
            entry (. next-state.index window-id)]
        (tset seen window-id true)
        (if (and (eligible? fact) (or entry (opts.live? window-id)))
            (if (= nil entry)
                (do
                  (set next-state (add-window next-state window-id fact.space-id
                                              (append-column next-state fact.space-id)))
                  (table.insert report.added window-id))
                (not= entry.space fact.space-id)
                (do
                  (set next-state (move-window next-state window-id fact.space-id
                                               (append-column next-state fact.space-id)))
                  (table.insert report.moved window-id)))
            entry
            (remove! window-id)
            (table.insert report.rejected window-id))))
    (when opts.remove-unseen?
      (each [_ window-id (ipairs (sorted-keys next-state.index))]
        (when (= nil (. seen window-id))
          (remove! window-id))))
    (let [effects (membership-effects state next-state)]
      {:state next-state
       :report report
       :attach effects.attach
       :detach effects.detach
       :touched-spaces effects.touched-spaces})))

{: plan-membership}
