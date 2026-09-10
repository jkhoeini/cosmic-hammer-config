;; event_sources/desktop-snapshot.fnl
;; Shared snapshot of the current desktop layout


(fn snapshot-desktop []
  "Snapshot spaces, active spaces, and screen geometry in screen order."
  (let [spaces-layout (hs.spaces.allSpaces)
        all-spaces []
        screens []]
    (each [_ screen (ipairs (hs.screen.allScreens))]
      (let [uuid (screen:getUUID)]
        (table.insert all-spaces [uuid (. spaces-layout uuid)])
        (table.insert screens {:uuid uuid :frame (screen:frame)})))
    {:all-spaces all-spaces
     :active-spaces (hs.spaces.activeSpaces)
     :screens screens}))


{: snapshot-desktop}
