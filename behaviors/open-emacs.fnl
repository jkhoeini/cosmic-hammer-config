
;; behaviors/open-emacs.fnl
;; Exports behavior data (pure, no registry dependency)

(local {: make-behavior} (require :sheaf.behavior-registry))

(local open-emacs-behavior
  (make-behavior
   {:name :emacs.behaviors/open-emacs
    :description "Open a new emacsclient frame on hotkey press"
    :respond-to [:event.kind.hotkey/pressed]
    :commands {:open-emacs :emacs.commands/open-emacs}
    :fn (fn [event cmd]
          (cmd.open-emacs {}))}))

{: open-emacs-behavior}
