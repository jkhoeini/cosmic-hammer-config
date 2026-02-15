
;; lib/event-loop.fnl
;; Event queue processing loop.
;; Data-oriented event loop - no global state.
;;
;; An event-loop is a data structure:
;;   {:event-registry er   ; the event registry to process
;;    :timer nil}          ; the hs.timer instance (nil when stopped)


;; ============================================================================
;; Constructors
;; ============================================================================

(fn make-event-loop [event-registry]
  "Create a new event loop.
   event-registry - the event registry whose queue and handlers to process (required)"
  (when (= nil event-registry)
    (error "make-event-loop: event-registry is required"))
  {:event-registry event-registry
   :timer nil})


;; ============================================================================
;; Event Processing
;; ============================================================================

(fn process-event! [event-loop]
  "Process one event from the queue.
   Pops the first event and runs it through all handlers.
   Returns true if an event was processed, false if queue was empty."
  (let [registry event-loop.event-registry]
    (if (< 0 (length registry.queue))
        (let [event (table.remove registry.queue 1)]
          (each [_ handler (pairs registry.handlers)]
            (handler event))
          true)
        false)))


;; ============================================================================
;; Lifecycle
;; ============================================================================

(fn start-event-loop! [event-loop]
  "Start timer-based event processing loop.
   Timer fires every 10ms and drains the queue completely."
  (when event-loop.timer
    (event-loop.timer:stop))
  (let [timer (hs.timer.new 0.01
                             (fn []
                               (while (process-event! event-loop)
                                 nil)))]
    (tset event-loop :timer timer)
    (timer:start)
    (print "[INFO] Event loop started")))


(fn stop-event-loop! [event-loop]
  "Stop the event processing loop."
  (when event-loop.timer
    (event-loop.timer:stop)
    (tset event-loop :timer nil)
    (print "[INFO] Event loop stopped")))


{: make-event-loop
 : process-event!
 : start-event-loop!
 : stop-event-loop!}
