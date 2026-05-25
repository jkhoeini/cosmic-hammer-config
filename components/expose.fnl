
;; components/expose.fnl
;; Component type: Expose window picker

(local {: make-component-type} (require :sheaf.component-registry))

(local expose-type
  (make-component-type
   :component.type/expose
   "Expose window picker component"
   {:traits [:trait/has-expose]
    :sources [{:type :event-source.type/hotkey
               :config {:mods [:ctrl :cmd] :key :e}
               :instance-name "toggle"
               :tags [:tag/expose-hotkey]}]
    :start-fn (fn [config]
                {:expose (hs.expose.new)})}))

{: expose-type}
