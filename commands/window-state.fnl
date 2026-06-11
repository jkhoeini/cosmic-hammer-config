
;; commands/window-state.fnl
;; Commands for tracking window state: initialize, upsert, remove.

(local {: make-command} (require :sheaf.command-registry))


(local initialize-windows-command
  (make-command
   :window-state.commands/initialize-windows
   "Populate window state from initial snapshot"
   {:requires-traits [:trait/has-window-state]
    :fn (fn [component params]
          (let [windows {}]
            (each [_ entry (ipairs params.windows)]
              (tset windows entry.window-id
                    {:window-id entry.window-id
                     :app-name entry.app-name
                     :bundle-id entry.bundle-id
                     :window-title entry.window-title
                     :frame entry.frame
                     :fullscreen (or entry.fullscreen false)}))
            {:windows windows}))}))


(local upsert-window-command
  (make-command
   :window-state.commands/upsert-window
   "Add or update a tracked window"
   {:requires-traits [:trait/has-window-state]
    :fn (fn [component params]
          (let [windows component.state.windows
                wid params.window-id
                existing (or (. windows wid) {})]
            (tset windows wid
                  {:window-id wid
                   :app-name (or params.app-name existing.app-name)
                   :bundle-id (or params.bundle-id existing.bundle-id)
                   :window-title (or params.window-title existing.window-title)
                   :frame (or params.frame existing.frame)
                   :fullscreen (if (not= nil params.fullscreen)
                                   params.fullscreen
                                   existing.fullscreen)})
            {:windows windows}))}))


(local remove-window-command
  (make-command
   :window-state.commands/remove-window
   "Remove a window from tracking"
   {:requires-traits [:trait/has-window-state]
    :fn (fn [component params]
          (let [windows component.state.windows]
            (tset windows params.window-id nil)
            {:windows windows}))}))


{: initialize-windows-command
 : upsert-window-command
 : remove-window-command}
