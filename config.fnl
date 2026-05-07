
(fn activator [app-name]
  #(hs.application.launchOrFocus app-name))

(local music-app "Spotify")

(local return {:key :space :title "Back" :action :previous})

(local app-bindings
       [return
        {:key :e :title "Emacs"   :action (activator "Emacs")}
        {:key :g :title "Chrome"  :action (activator "Google Chrome")}
        {:key :f :title "Firefox" :action (activator "Firefox")}
        {:key :i :title "iTerm"   :action (activator "iterm")}
        {:key :s :title "Slack"   :action (activator "Slack")}
        {:key :b :title "Brave"   :action (activator "brave browser")}
        {:key :m :title music-app :action (activator music-app)}])

(local yabai-bindings
       [return
        {:key :e :title "Enable"  :action #(hs.execute "yabai --start-service" true)}
        {:key :d :title "Disable" :action #(hs.execute "yabai --stop-service" true)}
        {:key :r :title "Restart" :action #(hs.execute "yabai --restart-service" true)}])

(local menu-items
       [{:key :space :title "Alfred" :action (activator "Alfred 4")}
        {:key :a     :title "Apps"   :items app-bindings}
        {:key :y     :title "Yabai"  :items yabai-bindings}])

(local hammerspoon-config
       {:key "Hammerspoon"
        :keys []
        :items [{:key :space :title "Alfred"          :action (activator "Alfred 4")}
                {:key :a     :title "Apps"             :items app-bindings}
                {:key :y     :title "Yabai"            :items yabai-bindings}
                {:key :r     :title "Reload Console"   :action hs.reload}
                {:key :c     :title "Clear Console"    :action hs.console.clearConsole}]})

{:title "Main Menu"
 :items menu-items
 :apps  [hammerspoon-config]}
