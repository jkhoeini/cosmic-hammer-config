(local {: add-window : remove-window : move-window} (require :paper-wm.layout))
(local {: eligible?} (require :paper-wm.eligibility))

(fn frame-center-x [frame]
  (when frame (+ frame.x (/ frame.w 2))))

(fn insertion-column [state fact center-x]
  "Upstream PaperWM placement: right of the recorded focused window when it is
   a different member on the same Space; otherwise before the first column
   whose head is centered right of this window; otherwise at the end."
  (let [columns (or (. state.spaces fact.space-id) [])
        focused-id state.focused-window-id
        focused-entry (and focused-id (. state.index focused-id))
        center (frame-center-x fact.frame)]
    (if (and focused-entry (= focused-entry.space fact.space-id)
             (not= focused-id fact.window-id))
        (+ focused-entry.col 1)
        (or (and center
                 (accumulate [column nil index head-ids (ipairs columns) &until column]
                   (let [head (center-x (. head-ids 1))]
                     (when (and head (< center head)) index))))
            (+ 1 (length columns))))))

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
   opts.center-x (window-id -> x or nil) locates existing column heads for
   insertion (facts in this plan supply their own frames);
   opts.observed-spaces (Space IDs) marks facts as a snapshot of those Spaces:
   tracked windows indexed there but absent from facts are removed, while
   members of unobserved Spaces are kept.
   Returns {:state :report :attach :detach :touched-spaces}. Report lists
   :added/:moved/:removed IDs that changed membership and :rejected IDs that
   were ineligible or unresolvable and never tracked."
  (var next-state state)
  (let [report {:added [] :moved [] :removed [] :rejected []}
        seen {}
        fact-centers (collect [_ fact (ipairs facts)]
                       fact.window-id (frame-center-x fact.frame))
        center-x (fn [window-id]
                   (or (. fact-centers window-id)
                       (and opts.center-x (opts.center-x window-id))))
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
                                              (insertion-column next-state fact center-x)))
                  (table.insert report.added window-id))
                (not= entry.space fact.space-id)
                (do
                  (set next-state (move-window next-state window-id fact.space-id
                                               (insertion-column next-state fact center-x)))
                  (table.insert report.moved window-id)))
            entry
            (remove! window-id)
            (table.insert report.rejected window-id))))
    (when opts.observed-spaces
      (let [observed (collect [_ space (ipairs opts.observed-spaces)] space true)]
        (each [_ window-id (ipairs (sorted-keys next-state.index))]
          (when (and (= nil (. seen window-id))
                     (. observed (. next-state.index window-id :space)))
            (remove! window-id)))))
    (let [effects (membership-effects state next-state)]
      {:state next-state
       :report report
       :attach effects.attach
       :detach effects.detach
       :touched-spaces effects.touched-spaces})))

{: plan-membership}
