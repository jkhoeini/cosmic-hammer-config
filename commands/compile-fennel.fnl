
;; commands/compile-fennel.fnl
;; Command: compile Fennel source files

(local {: make-command} (require :sheaf.command-registry))


(local compile-command
  (make-command
   :compile-fennel.commands/compile
   "Compile Fennel source files"
   {:fn (fn [params] (print (hs.execute "./compile.sh" true)))}))


{: compile-command}
