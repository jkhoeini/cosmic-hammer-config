
;; commands/open-emacs.fnl
;; Command: open a new emacsclient frame

(local {: make-command} (require :sheaf.command-registry))

(local emacsclient-path
  (-> "Emacs" hs.application.find (: :path) (: :gsub "Emacs.app" "bin/emacsclient")))

(local open-emacs-command
  (make-command
   :emacs.commands/open-emacs
   "Open a new emacsclient frame"
   {:fn (fn [params]
          (io.popen (.. "'" emacsclient-path "' -n -c &"))
          (hs.timer.doAfter 0.3
            (fn []
              (let [app (hs.application.find "Emacs")]
                (when app (: app :activate))))))}))

{: open-emacs-command}
