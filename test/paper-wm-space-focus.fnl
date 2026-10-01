;; Space focus retries re-act only while unstable and never busy-loop.

(local rect-meta
  {:__index (fn [rect key]
              (if (= key :x2) (+ rect.x rect.w)
                  (= key :y2) (+ rect.y rect.h)
                  nil))})

(fn rect [x y w h]
  (setmetatable {: x : y : w : h} rect-meta))

(local screen {:frame #(rect 0 25 1000 775) :getUUID #"screen-1"})
(var focused-space 5)
(var focused-window nil)
(var clicks 0)
(local delays [])
(var centered nil)

(set _G.hs
     {:geometry {:rect rect :rectMidPoint (fn [frame] {:x (+ frame.x (/ frame.w 2))})}
      :eventtap {:leftClick (fn [] (set clicks (+ 1 clicks)))}
      :mouse {:absolutePosition (fn [point] (set centered point))}
      :screen (setmetatable {:allScreens #[screen]}
                            {:__call (fn [_ display] (when display screen))})
      :spaces {:allSpaces #{:screen-1 [5 6]}
               :spaceDisplay #"screen-1"
               :focusedSpace #focused-space
               :gotoSpace #nil}
      :timer {:doAfter (fn [delay callback]
                         (table.insert delays {: delay : callback})
                         {:stop #nil})
              :secondsSinceEpoch #100}
      :uielement {:watcher {}}
      :window {:animationDuration 0 :focusedWindow #focused-window}})

(local paper-wm (require :paper-wm))
(local layout (require :paper-wm.layout))

(fn make-window [id]
  (let [window {:focus-count 0}]
    (tset window :id #id)
    (tset window :frame #(rect 50 60 400 700))
    (tset window :focus (fn [self] (set self.focus-count (+ 1 self.focus-count))))
    window))

(fn capture-outbox [runtime]
  (let [emitted []]
    (tset runtime.resources :outbox
          (fn [event-name data] (table.insert emitted [event-name data])))
    emitted))

;; Window target: one focus attempt, then stable observations do not re-focus.
(let [runtime (paper-wm.make-runtime {:epoch 1})
      emitted (capture-outbox runtime)
      target (make-window 1)]
  (tset runtime :tiling-state (layout.add-window runtime.tiling-state 1 6 1))
  (tset runtime.resources :windows {1 target})
  (paper-wm.start-space-focus! runtime 2)
  (assert (= 1 target.focus-count))
  (local retry (. delays (length delays)))
  (assert (<= 0.05 retry.delay) "zero animation duration made retries a busy loop")
  (local generation runtime.resources.space-focus.active.generation)
  (retry.callback)
  (assert (= :paper-wm.events/space-focus-retry (. emitted 1 1))
          "retry timer did not publish through the component outbox")
  (assert (= generation (. emitted 1 2 :generation)))
  (paper-wm.retry-space-focus! runtime generation)
  (assert (= 2 target.focus-count) "unstable observation did not re-focus")
  (set focused-space 6)
  (set focused-window target)
  (for [_ 1 3] (paper-wm.retry-space-focus! runtime generation))
  (assert (= 2 target.focus-count) "stable observations re-focused the target")
  (assert (= nil runtime.resources.space-focus.active) "conversation did not complete")
  (assert centered "cursor was not centered on completion"))

;; Empty Space: click until the Space is focused, then stop clicking.
(set focused-space 5)
(set focused-window nil)
(set clicks 0)
(let [runtime (paper-wm.make-runtime {:epoch 2})]
  (paper-wm.start-space-focus! runtime 2)
  (assert (= 1 clicks))
  (local generation runtime.resources.space-focus.active.generation)
  (set focused-space 6)
  (for [_ 1 3] (paper-wm.retry-space-focus! runtime generation))
  (assert (= 1 clicks) "clicked again after the Space was focused"))

;; A window-targeted operation whose window vanished never falls back to clicks.
(set focused-space 5)
(set clicks 0)
(let [runtime (paper-wm.make-runtime {:epoch 3})
      target (make-window 1)]
  (tset runtime :tiling-state (layout.add-window runtime.tiling-state 1 6 1))
  (tset runtime.resources :windows {1 target})
  (paper-wm.start-space-focus! runtime 2)
  (tset runtime.resources :windows {})
  (local generation runtime.resources.space-focus.active.generation)
  (for [_ 1 3] (paper-wm.retry-space-focus! runtime generation))
  (assert (= 0 clicks) "lost target window turned retries into menu-bar clicks"))

;; Absolute indices span displays in allScreens order and relative moves wrap;
;; a display missing from allSpaces is skipped instead of throwing.
(let [left {:frame #(rect 0 25 1000 775) :getUUID #"left"}
      right {:frame #(rect 1000 25 1000 775) :getUUID #"right"}
      orphan {:frame #(rect 2000 25 1000 775) :getUUID #"orphan"}]
  (tset hs.screen :allScreens #[left orphan right])
  (tset hs.spaces :allSpaces #{:left [1 2] :right [7]})
  (set focused-space 7)
  (assert (= 1 (paper-wm.space-index-after-direction :right)) "right did not wrap")
  (assert (= 2 (paper-wm.space-index-after-direction :left)))
  (set focused-space 99)
  (assert (= nil (paper-wm.space-index-after-direction :right))
          "unknown focused Space produced an index"))

(print "PaperWM Space focus passed")
