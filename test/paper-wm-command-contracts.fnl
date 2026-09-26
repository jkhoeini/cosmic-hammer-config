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

(local member? (fn [members value]
                 (not= nil (. members value))))

(local expected
  {:focus-command {:direction #(member? {:left true :right true :up true :down true} $1)}
   :swap-command {:direction #(member? {:left true :right true :up true :down true} $1)}
   :center-window-command {}
   :set-full-width-command {}
   :cycle-window-size-command
   {:direction #(member? {:width true :height true} $1)
    :cycle-direction #(member? {:ascending true :descending true} $1)}
   :slurp-window-command {}
   :barf-window-command {}
   :switch-to-space-command {:index #(and (= :number (type $1)) (<= 1 $1 9))}
   :increment-space-command {:direction #(member? {:left true :right true} $1)}
   :refresh-windows-command {}})

(fn assert-schema [command expected-schema]
  (each [key expected-predicate (pairs expected-schema)]
    (let [actual-predicate (. command.schema key)]
      (assert actual-predicate
              (.. "missing schema entry " (tostring key) " for "
                  (tostring command.name)))
      (each [_ value (ipairs [:left :right :up :down :width :height
                              :ascending :descending 0 1 9 10 "1" nil])]
        (assert (= (not (not (expected-predicate value)))
                   (not (not (actual-predicate value))))
                (.. "unexpected validation for " (tostring key) "="
                    (tostring value) " in " (tostring command.name))))))
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
