(tset package.loaded :paper-wm
      {:Direction {:LEFT -1 :RIGHT 1 :UP -2 :DOWN 2
                   :WIDTH 3 :HEIGHT 4 :ASCENDING 5 :DESCENDING 6}
       :run-with-runtime! (fn [runtime action args]
                            (action runtime (table.unpack (or args [])))
                            runtime)
       :focus-window (fn [runtime direction] (tset runtime :called [:focus direction]))
       :swap-windows! (fn [runtime direction] (tset runtime :called [:swap direction]))
       :center-window! (fn [runtime] (tset runtime :called [:center]))
       :set-window-full-width! (fn [runtime] (tset runtime :called [:full-width]))
       :cycle-window-size! (fn [runtime direction cycle-direction]
                             (tset runtime :called [:cycle direction cycle-direction]))
       :slurp-window! (fn [runtime] (tset runtime :called [:slurp]))
       :barf-window! (fn [runtime] (tset runtime :called [:barf]))
       :switch-to-space! (fn [runtime index] (tset runtime :called [:space index]))
       :increment-space! (fn [runtime direction] (tset runtime :called [:increment direction]))
       :refresh-windows! (fn [runtime] (tset runtime :called [:refresh]))})

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

(each [export-name _ (pairs expected)]
  (let [command (. commands export-name)]
    (assert (= :trait/has-paper-wm-runtime (. command.requires-traits 1))
            (.. "missing PaperWM runtime trait on " (tostring command.name)))))

(local runtime {:active? true})
(local component {:state runtime})
(local returned (commands.focus-command.fn component {:direction :left}))
(assert (= runtime returned) "PaperWM command must return the complete runtime")
(assert (= :focus (. runtime.called 1)))
(assert (= -1 (. runtime.called 2)))

(print "PaperWM command contracts passed")
