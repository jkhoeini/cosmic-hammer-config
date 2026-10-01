;; Every PaperWM command declares a params schema that accepts exactly the
;; values its subscriptions send, and the traits it depends on.
(tset package.loaded :paper-wm {})

(local commands (require :commands.paper-wm))

(local member? (fn [members value]
                 (not= nil (. members value))))

(local table-value? #(= :table (type $1)))
(local number-value? #(= :number (type $1)))

(local expected
  {:reconcile-snapshot-command {:windows table-value? :observed-spaces table-value?}
   :reconcile-window-command {:window table-value?}
   :record-focus-command {:window table-value?}
   :retile-observed-frame-command {:window-id number-value? :frame table-value?
                                   :generation number-value?
                                   :sequence number-value?}
   :retry-space-focus-command {:generation number-value?}
   :focus-command {:direction #(member? {:left true :right true :up true :down true} $1)}
   :swap-command {:direction #(member? {:left true :right true :up true :down true} $1)}
   :center-window-command {}
   :set-full-width-command {}
   :cycle-window-size-command
   {:direction #(member? {:width true :height true} $1)
    :cycle-direction #(member? {:ascending true :descending true} $1)}
   :slurp-window-command {}
   :barf-window-command {}
   :switch-to-space-command {:index #(and (= :number (type $1)) (<= 1 $1 9))}
   :increment-space-command {:direction #(member? {:left true :right true} $1)}})

(fn assert-schema [command expected-schema]
  (each [key expected-predicate (pairs expected-schema)]
    (let [actual-predicate (. command.schema key)]
      (assert actual-predicate
              (.. "missing schema entry " (tostring key) " for "
                  (tostring command.name)))
      (each [_ value (ipairs [:left :right :up :down :width :height
                              :ascending :descending 0 1 9 10 "1" {}])]
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

;; Every command reads tiling-state except the Space-focus retry, which only
;; advances runtime resources.
(each [export-name _ (pairs expected)]
  (let [command (. commands export-name)
        needs-tiling-state? (not= export-name :retry-space-focus-command)]
    (assert (= :trait/has-paper-wm-runtime (. command.requires-traits 1))
            (.. "missing PaperWM runtime trait on " (tostring command.name)))
    (assert (= needs-tiling-state?
               (= :trait/has-tiling-state (. command.requires-traits 2)))
            (.. "tiling-state trait mismatch on " (tostring command.name)))))

(print "PaperWM command contracts passed")
