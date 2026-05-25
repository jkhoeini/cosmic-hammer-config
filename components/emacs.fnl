
;; components/emacs.fnl
;; Component type: Emacs integration (stateless)

(local {: make-component-type} (require :sheaf.component-registry))

(local emacs-type
  (make-component-type
   :component.type/emacs
   "Emacs integration component"
   {:sources [{:type :event-source.type/hotkey
               :config {:mods [:cmd :alt] :key :return}
               :instance-name "open"
               :tags [:tag/emacs-hotkey]}]
    :start-fn (fn [config] {})}))

{: emacs-type}
