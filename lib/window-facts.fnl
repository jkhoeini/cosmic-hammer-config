(fn safe-call [object method]
  (when (= nil object) (lua "return nil"))
  (let [callable (. object method)]
    (when (= :function (type callable))
      (let [(ok value) (pcall callable object)]
        (when ok value)))))

(fn snapshot-window [window]
  "Snapshot PaperWM suitability facts without propagating torn-window errors."
  (let [window-id (safe-call window :id)]
    (when (= nil window-id) (lua "return nil"))
    (let [app (safe-call window :application)
          frame (safe-call window :frame)
          spaces (let [(ok value) (pcall hs.spaces.windowSpaces window)]
                   (and ok value))]
      (when (= nil frame) (lua "return nil"))
      {:window-id window-id
       :app-name (safe-call app :name)
       :bundle-id (safe-call app :bundleID)
       :window-title (safe-call window :title)
       :frame frame
       :role (safe-call window :role)
       :subrole (safe-call window :subrole)
       :has-titlebar (not= nil (safe-call window :zoomButtonRect))
       :visible (safe-call window :isVisible)
       :fullscreen (safe-call window :isFullScreen)
       :tab-count (safe-call window :tabCount)
       :space-id (and spaces (. spaces 1))})))

(fn snapshot-windows []
  "Snapshot every currently available window, skipping torn-down handles.
   Only windows on the active Spaces are reported; see snapshot-observed-windows."
  (let [entries []
        (ok all-windows) (pcall hs.window.allWindows)]
    (when ok
      (each [_ window (ipairs all-windows)]
        (let [entry (snapshot-window window)]
          (when entry (table.insert entries entry)))))
    entries))

(fn active-space-ids []
  "Return the sorted active Space IDs (one per display), or [] if unknown."
  (let [(ok active) (pcall hs.spaces.activeSpaces)
        result (icollect [_ space-id (pairs (or (and ok active) {}))] space-id)]
    (table.sort result)
    result))

(fn same-ids? [left right]
  (and (= (length left) (length right))
       (accumulate [same? true index id (ipairs left)]
         (and same? (= id (. right index))))))

(fn snapshot-observed-windows []
  "Snapshot windows with the Space IDs the snapshot covers.
   :observed-spaces is [] (observe nothing) when the active Spaces are unknown
   or changed while the windows were enumerated."
  (let [before (active-space-ids)
        windows (snapshot-windows)
        after (active-space-ids)]
    {:windows windows
     :observed-spaces (if (same-ids? before after) after [])}))

{: snapshot-window : snapshot-windows : snapshot-observed-windows}
