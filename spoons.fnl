
(local {: and-use! : add-repo!} (require :lib.spoon-install))

(and-use! "Calendar" {})

;; spoon.SpoonInstall:andUse("HCalendar", { start = true}))
;; Pomodoro Menubar: spoon.SpoonInstall:andUse("Cherry", {})
(and-use! "CircleClock" {})
(and-use! "ClipboardTool" {:start true})
(and-use! "Emojis" {})

;; Make setFrame behave more correctly. e.g. terminal windows)
;; hs.window.setFrameCorrectness = true

(fn toggle-emojis []
  (if (spoon.Emojis.chooser:isVisible)
    (spoon.Emojis.chooser:hide)
    (spoon.Emojis.chooser:show)))


(and-use! "HSKeybindings" {})

(var hammerspoon-keybindings-shown? false)

(fn toggle-show-keybindings []
  (set hammerspoon-keybindings-shown? (not hammerspoon-keybindings-shown?))
  (if hammerspoon-keybindings-shown?
    (spoon.HSKeybindings:show)
    (spoon.HSKeybindings:hide)))

(and-use! "KSheet" {})

(add-repo! :PaperWM
           {:url "https://github.com/mogenson/PaperWM.spoon"
            :desc "PaperWM.spoon repository"
            :branch "release"})

(local paper-wm
       (and-use!
        "PaperWM"
        {:repo "PaperWM"
         :config {:window_gap 35
                  :screen_margin 16
                  :window_ratios [0.3125 0.421875 0.625 0.843750]}
         :fn #(: $1 :bindHotkeys (. $1 :default_hotkeys))
         :start true}))

{}
