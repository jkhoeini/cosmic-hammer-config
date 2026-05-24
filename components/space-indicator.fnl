
;; components/space-indicator.fnl
;; Component type: space indicator menubar

(local {: make-component-type} (require :sheaf.component-registry))

(local space-indicator-type
  (make-component-type
   :component.type/space-indicator
   "Space indicator menubar component"
   {:traits [:trait/has-menubar]
    :start-fn (fn [config]
                (let [menubar (hs.menubar.new true "cosmicHammerSpaceIndicator")]
                  (when menubar
                    (menubar:setTitle "..."))
                  {:menubar menubar}))
    :stop-fn (fn [state]
               (when state.menubar
                 (state.menubar:delete)))}))

{: space-indicator-type}
