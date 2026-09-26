(local noop #nil)
(tset package.loaded :paper-wm
      {:Direction {:LEFT -1 :RIGHT 1 :UP -2 :DOWN 2
                   :WIDTH 3 :HEIGHT 4 :ASCENDING 1 :DESCENDING -1}
       :focus-window noop
       :swap-windows! noop
       :center-window! noop
       :set-window-full-width! noop
       :cycle-window-size! noop
       :slurp-window! noop
       :barf-window! noop
       :switch-to-space! noop
       :increment-space! noop
       :refresh-windows! noop})

(local commands (require :commands.paper-wm))

(local function? #(= :function (type $1)))
(local table? #(= :table (type $1)))

(local expected
  {:focus-command {:direction function?}
   :swap-command {:direction function?}
   :center-window-command {}
   :set-full-width-command {}
   :cycle-window-size-command {:direction function? :cycle-direction function?}
   :slurp-window-command {}
   :barf-window-command {}
   :switch-to-space-command {:index number?}
   :increment-space-command {:direction function?}
   :refresh-windows-command {}})

(fn assert-schema [command expected-schema]
  (each [key predicate (pairs expected-schema)]
    (assert (= predicate (. command.schema key))
            (.. "unexpected schema entry " (tostring key) " for "
                (tostring command.name))))
  (each [key _ (pairs command.schema)]
    (assert (. expected-schema key)
            (.. "extra schema entry " (tostring key) " for "
                (tostring command.name)))))

(each [export-name schema (pairs expected)]
  (let [command (. commands export-name)]
    (assert command (.. "missing command export " (tostring export-name)))
    (assert-schema command schema)))
(assert (= nil commands.set-pending-window-command)
        "obsolete set-pending-window command remains exported")
(assert (= nil commands.clear-pending-window-command)
        "obsolete clear-pending-window command remains exported")

(print "PaperWM command contracts passed")
