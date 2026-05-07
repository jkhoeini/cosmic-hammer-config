
(local core (require :lib.cljlib-shim))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn activator [app-name]
  "Returns a function that launches or focuses the named app."
  #(hs.application.launchOrFocus app-name))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local music-app "Spotify")

(local return
       {:key :space
        :title "Back"
        :action :previous})


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Apps Menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local app-bindings
       [return
        {:key :e
         :title "Emacs"
         :action (activator "Emacs")}
        {:key :g
         :title "Chrome"
         :action (activator "Google Chrome")}
        {:key :f
         :title "Firefox"
         :action (activator "Firefox")}
        {:key :i
         :title "iTerm"
         :action (activator "iterm")}
        {:key :s
         :title "Slack"
         :action (activator "Slack")}
        {:key :b
         :title "Brave"
         :action (activator "brave browser")}
        {:key :m
         :title music-app
         :action (activator music-app)}])

(local yabai-bindings
       [return
        {:key :e
         :title "Enable"
         :action #(hs.execute "yabai --start-service" true)}
        {:key :d
         :title "Disable"
         :action #(hs.execute "yabai --stop-service" true)}
        {:key :r
         :title "Restart"
         :action #(hs.execute "yabai --restart-service" true)}])


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Menu & Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local menu-items
       [{:key    :space
         :title  "Alfred"
         :action (activator "Alfred 4")}
        {:key   :a
         :title "Apps"
         :items app-bindings}
        {:key   :y
         :title "Yabai"
         :items yabai-bindings}])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; App Specific Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local brave-config
       {:key "Brave Browser"
        :keys []
        :items menu-items})

(local chrome-config
       {:key "Google Chrome"
        :keys []
        :items menu-items})

(local firefox-config
       {:key "Firefox"
        :keys []
        :items menu-items})

(local hammerspoon-config
       {:key "Hammerspoon"
        :items (core.concat
                menu-items
                [{:key :r
                  :title "Reload Console"
                  :action hs.reload}
                 {:key :c
                  :title "Clear Console"
                  :action hs.console.clearConsole}])
        :keys []})


(local apps
       [brave-config
        chrome-config
        firefox-config
        hammerspoon-config])

{:title "Main Menu"
 :items menu-items
 :apps  apps}
