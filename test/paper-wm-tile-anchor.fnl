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

(set _G.hs
     {:geometry {:rect rect}
      :screen (setmetatable {} {:__call (fn [_ display] (when display screen))})
      :spaces {:spaceType #:user :spaceDisplay #"screen-1" :windowSpaces #[7]}
      :timer {:doAfter (fn [] {:stop #nil}) :secondsSinceEpoch #100}
      :uielement {:watcher {:windowMoved :moved :windowResized :resized}}
      :window {:animationDuration 0
               :focusedWindow #focused
               :get #nil}})

(fn make-window [id frame]
  (let [window {:current frame :applied nil}]
    (tset window :id #id)
    (tset window :frame (fn [self] (rect self.current.x self.current.y
                                         self.current.w self.current.h)))
    (tset window :setFrame (fn [self next-frame]
                             (set self.applied next-frame)
                             (set self.current next-frame)))
    window))

(fn make-watcher [] {:stop #nil :start #nil})

(local paper-wm (require :paper-wm))
(local layout (require :paper-wm.layout))

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
  (paper-wm.record-focus! runtime 1 7 event-frame)
  (assert first.applied "event window was not tiled")
  (assert (= 100 first.applied.x) "event frame was not applied to its own window")
  (assert (= 435 second.applied.x) "neighbor was not laid out right of the anchor")
  (assert (and (= 500 event-frame.h) (= 0 event-frame.y))
          "tile-space! mutated the caller's frame"))

;; Removing a member while an untracked panel has focus still retiles.
(let [(runtime first) (make-two-column-runtime)]
  (set focused (make-window 99 (rect 0 0 10 10)))
  (paper-wm.reconcile-window-fact! runtime {:window-id 2 :fullscreen true} {})
  (assert (= nil (. runtime.tiling-state.index 2)))
  (assert first.applied "untracked focus prevented retiling the remaining member"))

(print "PaperWM tile anchor passed")
