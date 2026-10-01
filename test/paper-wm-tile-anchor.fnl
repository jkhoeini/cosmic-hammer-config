;; tile-space! anchors on the window that owns the anchor frame, never mutates
;; the caller's frame, and falls back to a visible member when focus is untracked.

(local rect-meta
  {:__index (fn [rect key]
              (if (= key :x2) (+ rect.x rect.w)
                  (= key :y2) (+ rect.y rect.h)
                  nil))})

(fn rect [x y w h]
  (setmetatable {: x : y : w : h} rect-meta))

(local screen {:frame #(rect 0 0 1000 800) :getUUID #"screen-1"})
(var focused nil)
(var space-type-calls 0)
(local live-windows {})

(set _G.hs
     {:geometry {:rect rect}
      :screen (setmetatable {} {:__call (fn [_ display] (when display screen))})
      :spaces {:spaceType (fn [] (set space-type-calls (+ 1 space-type-calls)) :user)
               :spaceDisplay #"screen-1" :windowSpaces #[7]}
      :timer {:doAfter (fn [] {:stop #nil}) :secondsSinceEpoch #100}
      :uielement {:watcher {:windowMoved :moved :windowResized :resized}}
      :window {:animationDuration 0
               :focusedWindow #focused
               :get #(. live-windows $1)}})

(fn make-watcher [] {:stop #nil :start #nil})

(fn make-window [id frame]
  (let [window {:current frame :applied nil}]
    (tset window :id #id)
    (tset window :frame (fn [self] (rect self.current.x self.current.y
                                         self.current.w self.current.h)))
    (tset window :setFrame (fn [self next-frame]
                             (set self.applied next-frame)
                             (set self.current next-frame)))
    (tset window :newWatcher make-watcher)
    (tset live-windows id window)
    window))

(fn focus-fact [window-id space-id frame]
  {:window-id window-id :space-id space-id :frame frame
   :subrole "AXStandardWindow" :has-titlebar true :visible true
   :fullscreen false :tab-count 0})

(local paper-wm (require :paper-wm))
(local layout (require :paper-wm.layout))
(local {: next-observation} (require :paper-wm.observations))

(fn make-two-column-runtime []
  (let [runtime (paper-wm.make-runtime {:epoch 1})
        first (make-window 1 (rect 40 35 300 700))
        second (make-window 2 (rect 380 35 300 700))]
    (tset runtime :tiling-state
          (-> (layout.add-window runtime.tiling-state 1 7 1)
              (layout.add-window 2 7 2)))
    (tset runtime.resources :windows {1 first 2 second})
    (tset runtime.resources :ui-watchers {1 (make-watcher) 2 (make-watcher)})
    (values runtime first second)))

;; Focus event for window 1 arrives while window 2 is live-focused.
(let [(runtime first second) (make-two-column-runtime)
      event-frame (rect 100 0 300 500)]
  (set focused second)
  (paper-wm.record-focus! runtime (focus-fact 1 7 event-frame))
  (assert first.applied "event window was not tiled")
  (assert (= 100 first.applied.x) "event frame was not applied to its own window")
  (assert (= 435 second.applied.x) "neighbor was not laid out right of the anchor")
  (assert (and (= 500 event-frame.h) (= 0 event-frame.y))
          "tile-space! mutated the caller's frame"))

;; A focused window that moved to another Space follows it in the layout.
(let [(runtime first second) (make-two-column-runtime)]
  (set focused first)
  (paper-wm.record-focus! runtime (focus-fact 1 9 (rect 40 35 300 700)))
  (assert (= 9 (. runtime.tiling-state.index 1 :space))
          "focused window kept its stale Space")
  (assert (= 1 runtime.tiling-state.focused-window-id))
  (assert (= 1 (. runtime.tiling-state.index 2 :col))
          "old Space columns were not compacted")
  (assert second.applied "old Space was not retiled after the move"))

;; Focusing an untracked eligible window (e.g. first visit to its Space) joins it.
(let [(runtime) (make-two-column-runtime)
      third (make-window 3 (rect 0 35 300 700))]
  (set focused third)
  (paper-wm.record-focus! runtime (focus-fact 3 11 (rect 0 35 300 700)))
  (assert (= 11 (. runtime.tiling-state.index 3 :space)) "focused window did not join")
  (assert (= 3 runtime.tiling-state.focused-window-id))
  (assert (. runtime.resources.ui-watchers 3) "joined window has no frame watcher"))

;; A focus fact whose Space lookup failed keeps membership and still records focus.
(let [(runtime first) (make-two-column-runtime)]
  (set focused first)
  (paper-wm.record-focus! runtime (focus-fact 1 nil (rect 40 35 300 700)))
  (assert (= 7 (. runtime.tiling-state.index 1 :space))
          "transient missing Space ID evicted a member")
  (assert (= 1 runtime.tiling-state.focused-window-id)))

;; Removing a member while an untracked panel has focus still retiles.
(let [(runtime first) (make-two-column-runtime)]
  (set focused (make-window 99 (rect 0 0 10 10)))
  (paper-wm.reconcile-window-fact! runtime {:window-id 2 :fullscreen true} {})
  (assert (= nil (. runtime.tiling-state.index 2)))
  (assert first.applied "untracked focus prevented retiling the remaining member"))

;; A snapshot reconcile tiles each touched Space once, not once per fact.
(let [(runtime first) (make-two-column-runtime)
      eligible {:window-id 1 :space-id 7 :subrole "AXStandardWindow"
                :has-titlebar true :visible true :fullscreen false :tab-count 0}]
  (set focused first)
  (set space-type-calls 0)
  (let [(_ report) (paper-wm.reconcile-layout! runtime [eligible] [7])]
    (assert (= 2 (. report.removed 1)))
    (assert (= 1 space-type-calls) "reconcile tiled the Space more than once")))

;; Frame observations retile once, only for the latest sequence of a live watcher.
(let [(runtime first) (make-two-column-runtime)
      observations runtime.resources.frame-observations
      retile (fn [sequence]
               (set first.applied nil)
               (paper-wm.retile-observed-frame!
                runtime {:window-id 1 :frame (rect 60 35 300 700)
                         :generation 1 :sequence sequence})
               (not= nil first.applied))]
  (set focused first)
  (tset runtime.resources.watcher-generations 1 1)
  (next-observation observations 1 "moved" (rect 50 35 300 700) 1)
  (next-observation observations 1 "moved" (rect 60 35 300 700) 1)
  (assert (not (retile 1)) "superseded observation retiled")
  (assert (retile 2) "latest observation did not retile")
  (assert (not (retile 2)) "consumed observation retiled again")
  (next-observation observations 1 "moved" (rect 70 35 300 700) 1)
  (tset runtime.resources.watcher-generations 1 2)
  (assert (not (retile 3)) "observation from a replaced watcher retiled"))

(print "PaperWM tile anchor passed")
