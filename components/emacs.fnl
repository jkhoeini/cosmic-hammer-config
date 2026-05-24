
;; components/emacs.fnl
;; Component type: Emacs integration (stateless)

(local {: make-component-type} (require :sheaf.component-registry))

(local emacs-type
  (make-component-type
   :component.type/emacs
   "Emacs integration component"
   {:start-fn (fn [config] {})}))

{: emacs-type}
