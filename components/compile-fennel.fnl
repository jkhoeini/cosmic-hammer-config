
;; components/compile-fennel.fnl
;; Component type: Fennel compiler (stateless)

(local {: make-component-type} (require :sheaf.component-registry))

(local compile-fennel-type
  (make-component-type
   :component.type/compile-fennel
   "Fennel source file compiler"
   {:start-fn (fn [config] {})}))

{: compile-fennel-type}
