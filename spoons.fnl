
(local {: and-use! : add-repo!} (require :lib.spoon-install))

(add-repo! :PaperWM
           {:url "https://github.com/mogenson/PaperWM.spoon"
            :desc "PaperWM.spoon repository"
            :branch "release"})

(and-use! :PaperWM {:repo :PaperWM
                    :config {:window_gap 35
                             :screen_margin 16
                             :window_ratios [0.3125 0.421875 0.625 0.843750]}
                    :fn #(: $1 :bindHotkeys (. $1 :default_hotkeys))
                    :start true})

{}
