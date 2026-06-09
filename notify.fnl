"Module for showing custom styled notifications using hs.drawing"

;; Duration in seconds for how long the notification is shown
(local notification-duration 30)

;; Margin from screen edge
(local margin 64)

;; Gap between stacked notifications
(local stack-gap 8)

;; Path to icons directory (resolved relative to the config dir, not a fixed name)
(local icons-dir (.. hs.configdir "/icons"))

;; Icon paths for each notification type
(local icon-paths
  {:info (.. icons-dir "/info.png")
   :warn (.. icons-dir "/warn.png")
   :error (.. icons-dir "/error.png")})

;; Header background colors for each notification type
(local header-colors
  {:info {:red 0.2 :green 0.4 :blue 0.6 :alpha 1}
   :warn {:red 0.7 :green 0.5 :blue 0.1 :alpha 1}
   :error {:red 0.7 :green 0.2 :blue 0.2 :alpha 1}})

;; Store active notification drawings for cleanup
(var active-notifications [])

(fn move-notification-up [notif offset]
  "Move all drawings in a notification up by offset pixels"
  (each [_ drawing (ipairs (. notif :drawings))]
    (let [current-frame (: drawing :frame)
          new-y (- (. current-frame :y) offset)]
      (: drawing :setFrame {:x (. current-frame :x)
                            :y new-y
                            :w (. current-frame :w)
                            :h (. current-frame :h)}))))

(fn push-existing-notifications-up [new-height]
  "Push all existing notifications up to make room for a new one"
  (let [offset (+ new-height stack-gap)]
    (each [_ notif (ipairs active-notifications)]
      (move-notification-up notif offset))))

(fn remove-notification [notif]
  "Remove a specific notification and clean up"
  (when (. notif :timer)
    (: (. notif :timer) :stop))
  (each [_ drawing (ipairs (. notif :drawings))]
    (: drawing :delete))
  ;; Remove from active-notifications array
  (var idx nil)
  (each [i n (ipairs active-notifications)]
    (when (= n notif)
      (set idx i)))
  (when idx
    (table.remove active-notifications idx)))

(fn show-notification [title type message]
  "Display a custom styled notification at bottom-right corner"
  (let [screen (hs.screen.mainScreen)
        frame (: screen :frame)
        icon-path (. icon-paths type)
        icon-image (hs.image.imageFromPath icon-path)
        header-color (or (. header-colors type) (. header-colors :info))
        
        ;; Font settings
        title-font "SF Pro Text Bold"
        message-font "SF Pro Text"
        font-size 14
        
        ;; Dimensions (following 8pt grid system for spacing)
        outer-padding 8          ;; Padding around entire dialog (inset for header/message)
        section-gap 8            ;; Gap between header and message sections
        inner-padding 8          ;; Padding inside header
        icon-size 18
        icon-padding 10
        notif-width 300
        header-height 36         ;; Header height
        message-padding 12       ;; Padding inside message area
        close-btn-size 18
        close-btn-margin 8
        
        ;; Calculate message height based on content
        message-size (hs.drawing.getTextDrawingSize 
                       message 
                       {:font message-font :size font-size})
        wrapped-lines (math.ceil (/ (. message-size :w) (- notif-width (* message-padding 2) (* outer-padding 2))))
        actual-message-height (* (. message-size :h) (math.max 1 wrapped-lines))
        message-height (+ actual-message-height (* message-padding 2))
        ;; Total: outer-padding + header + section-gap + message + outer-padding
        total-height (+ (* outer-padding 2) header-height section-gap message-height)
        
        ;; Position at bottom-right
        x (- (+ (. frame :x) (. frame :w)) notif-width margin)
        y (- (+ (. frame :y) (. frame :h)) total-height margin 50)]  ;; 50px extra for dock
    
    ;; Push existing notifications up before creating new one
    (push-existing-notifications-up total-height)
    
    (let [;; Create drawings array
          drawings []
          
          ;; Main container background (outer shell)
          container-rect (hs.drawing.rectangle 
                           {:x x :y y :w notif-width :h total-height})
          
          ;; Header background (inset inside container)
          header-rect (hs.drawing.rectangle 
                        {:x (+ x outer-padding) 
                         :y (+ y outer-padding) 
                         :w (- notif-width (* outer-padding 2)) 
                         :h header-height})
          
          ;; Message background (inset inside container, with section-gap from header)
          message-rect (hs.drawing.rectangle 
                         {:x (+ x outer-padding) 
                          :y (+ y outer-padding header-height section-gap) 
                          :w (- notif-width (* outer-padding 2)) 
                          :h message-height})
          
          ;; Icon image
          icon-drawing (when icon-image
                         (hs.drawing.image 
                           {:x (+ x outer-padding icon-padding) 
                            :y (+ y outer-padding (/ (- header-height icon-size) 2))
                            :w icon-size 
                            :h icon-size}
                           icon-image))
          
          ;; Header text (title only, icon is separate)
          ;; Text height is roughly font-size + 4 for line height
          text-height 18
          text-x-offset (if icon-image (+ outer-padding icon-padding icon-size 8) (+ outer-padding inner-padding))
          header-text (hs.drawing.text 
                        {:x (+ x text-x-offset) 
                         :y (+ y outer-padding (/ (- header-height text-height) 2)) 
                         :w (- notif-width text-x-offset inner-padding close-btn-size close-btn-margin outer-padding) 
                         :h text-height}
                        title)
          
          ;; Message text
          message-text (hs.drawing.text 
                         {:x (+ x outer-padding message-padding) 
                          :y (+ y outer-padding header-height section-gap message-padding) 
                          :w (- notif-width (* outer-padding 2) (* message-padding 2)) 
                          :h actual-message-height}
                         message)
          
          ;; Close button (X)
          close-btn-x (- (+ x notif-width) close-btn-size close-btn-margin outer-padding)
          close-btn-y (+ y outer-padding (/ (- header-height close-btn-size) 2))
          close-btn (hs.drawing.text
                      {:x close-btn-x
                       :y close-btn-y
                       :w close-btn-size
                       :h close-btn-size}
                      "×")]
      
      ;; Style container (outer shell - dark border/background)
      (: container-rect :setFill true)
      (: container-rect :setFillColor {:white 0.12 :alpha 0.98})
      (: container-rect :setStroke true)
      (: container-rect :setStrokeWidth 1)
      (: container-rect :setStrokeColor {:white 0.25 :alpha 1})
      (: container-rect :setRoundedRectRadii 12 12)
      
      ;; Style header background (colored, inset)
      (: header-rect :setFill true)
      (: header-rect :setFillColor header-color)
      (: header-rect :setStroke false)
      (: header-rect :setRoundedRectRadii 8 8)
      
      ;; Style message background (darker, inset)
      (: message-rect :setFill true)
      (: message-rect :setFillColor {:white 0.06 :alpha 1})
      (: message-rect :setStroke false)
      (: message-rect :setRoundedRectRadii 8 8)
      
      ;; Style header text
      (: header-text :setTextFont title-font)
      (: header-text :setTextSize 14)
      (: header-text :setTextColor {:white 1 :alpha 1})
      
      ;; Style message text
      (: message-text :setTextFont message-font)
      (: message-text :setTextSize font-size)
      (: message-text :setTextColor {:white 0.9 :alpha 1})
      
      ;; Style close button
      (: close-btn :setTextFont "SF Pro Text")
      (: close-btn :setTextSize 16)
      (: close-btn :setTextColor {:white 1 :alpha 0.6})
      
      ;; Show all drawings (order matters for layering)
      (: container-rect :show)
      (: header-rect :show)
      (: message-rect :show)
      (when icon-drawing (: icon-drawing :show))
      (: header-text :show)
      (: message-text :show)
      (: close-btn :show)
      
      ;; Store drawings for cleanup
      (table.insert drawings container-rect)
      (table.insert drawings header-rect)
      (table.insert drawings message-rect)
      (when icon-drawing (table.insert drawings icon-drawing))
      (table.insert drawings header-text)
      (table.insert drawings message-text)
      (table.insert drawings close-btn)
      
      ;; Create notification object
      (let [notif {:drawings drawings :height total-height :timer nil}]
        
        ;; Set up close button click behavior
        (: close-btn :setBehaviorByLabels [:canvasClickable])
        (: close-btn :setClickCallback (fn [] (remove-notification notif)))
        
        ;; Set timer to clean up this specific notification
        (tset notif :timer 
              (hs.timer.doAfter 
                notification-duration 
                (fn [] (remove-notification notif))))
        
        ;; Store reference for potential manual cleanup
        (table.insert active-notifications notif)))))

(fn notify [title type message]
  "Display a styled notification.
   Parameters:
   - title: The notification title (shown bold at top with icon)
   - type: The notification type (:info, :warn, or :error)
   - message: The notification body message"
  (show-notification title type message))

(fn info [message]
  "Display an info notification with 'Cosmic Hammer' branding"
  (notify "Cosmic Hammer" :info message))

(fn warn [message]
  "Display a warning notification with 'Cosmic Hammer' branding"
  (notify "Cosmic Hammer" :warn message))

(fn error [message]
  "Display an error notification with 'Cosmic Hammer' branding"
  (notify "Cosmic Hammer" :error message))

(fn close-all []
  "Close all active notifications"
  (each [_ notif (ipairs active-notifications)]
    (when (. notif :timer)
      (: (. notif :timer) :stop))
    (each [_ drawing (ipairs (. notif :drawings))]
      (: drawing :delete)))
  (set active-notifications []))

{: info
 : warn
 : error
 : close-all}
