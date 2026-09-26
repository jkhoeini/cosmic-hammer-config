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
  "Snapshot every currently available window, skipping torn-down handles."
  (let [entries []
        (ok all-windows) (pcall hs.window.allWindows)]
    (when ok
      (each [_ window (ipairs all-windows)]
        (let [entry (snapshot-window window)]
          (when entry (table.insert entries entry)))))
    entries))

{: snapshot-window : snapshot-windows}
