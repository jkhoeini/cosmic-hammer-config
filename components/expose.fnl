
;; components/expose.fnl
;; Component type: Expose window picker

(local {: make-component-type} (require :sheaf.component-registry))

(local expose-type
  (make-component-type
   :component.type/expose
   "Expose window picker component"
   {:traits [:trait/has-expose]
    :start-fn (fn [config]
                {:expose (hs.expose.new)})}))

{: expose-type}
