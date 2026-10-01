hs.console.clearConsole()
hs.opentelemetry.configure({enabled = true, serviceName = "cosmic-hammer-config", exporter = "otlp", protocol = "http/protobuf", endpoint = "http://localhost:4318", traces = true, logs = true, metrics = true, capturePrint = "on", captureLogger = true, callbackSampleRates = {["hs.eventtap"] = 0.01, ["hs.sqlite3.progressHandler"] = 0}, attributeLimits = {maxCount = 64, maxValueLength = 4096}})
_G["event-bus.debug-mode?"] = false
hs.ipc.cliInstall()
hs.window.animationDuration = 0.0
local notify
package.preload["notify"] = package.preload["notify"] or function(...)
  local notification_duration = 30
  local margin = 64
  local stack_gap = 8
  local icons_dir = (hs.configdir .. "/icons")
  local icon_paths = {info = (icons_dir .. "/info.png"), warn = (icons_dir .. "/warn.png"), error = (icons_dir .. "/error.png")}
  local header_colors = {info = {red = 0.2, green = 0.4, blue = 0.6, alpha = 1}, warn = {red = 0.7, green = 0.5, blue = 0.1, alpha = 1}, error = {red = 0.7, green = 0.2, blue = 0.2, alpha = 1}}
  local active_notifications = {}
  local function move_notification_up(notif, offset)
    for _, drawing in ipairs(notif.drawings) do
      local current_frame = drawing:frame()
      local new_y = (current_frame.y - offset)
      drawing:setFrame({x = current_frame.x, y = new_y, w = current_frame.w, h = current_frame.h})
    end
    return nil
  end
  local function push_existing_notifications_up(new_height)
    local offset = (new_height + stack_gap)
    for _, notif in ipairs(active_notifications) do
      move_notification_up(notif, offset)
    end
    return nil
  end
  local function remove_notification(notif)
    if notif.timer then
      notif.timer:stop()
    else
    end
    for _, drawing in ipairs(notif.drawings) do
      drawing:delete()
    end
    local idx = nil
    for i, n in ipairs(active_notifications) do
      if (n == notif) then
        idx = i
      else
      end
    end
    if idx then
      return table.remove(active_notifications, idx)
    else
      return nil
    end
  end
  local function show_notification(title, type, message)
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    local icon_path = icon_paths[type]
    local icon_image = hs.image.imageFromPath(icon_path)
    local header_color = (header_colors[type] or header_colors.info)
    local title_font = "SF Pro Text Bold"
    local message_font = "SF Pro Text"
    local font_size = 14
    local outer_padding = 8
    local section_gap = 8
    local inner_padding = 8
    local icon_size = 18
    local icon_padding = 10
    local notif_width = 300
    local header_height = 36
    local message_padding = 12
    local close_btn_size = 18
    local close_btn_margin = 8
    local message_size = hs.drawing.getTextDrawingSize(message, {font = message_font, size = font_size})
    local wrapped_lines = math.ceil((message_size.w / (notif_width - (message_padding * 2) - (outer_padding * 2))))
    local actual_message_height = (message_size.h * math.max(1, wrapped_lines))
    local message_height = (actual_message_height + (message_padding * 2))
    local total_height = ((outer_padding * 2) + header_height + section_gap + message_height)
    local x = ((frame.x + frame.w) - notif_width - margin)
    local y = ((frame.y + frame.h) - total_height - margin - 50)
    push_existing_notifications_up(total_height)
    local drawings = {}
    local container_rect = hs.drawing.rectangle({x = x, y = y, w = notif_width, h = total_height})
    local header_rect = hs.drawing.rectangle({x = (x + outer_padding), y = (y + outer_padding), w = (notif_width - (outer_padding * 2)), h = header_height})
    local message_rect = hs.drawing.rectangle({x = (x + outer_padding), y = (y + outer_padding + header_height + section_gap), w = (notif_width - (outer_padding * 2)), h = message_height})
    local icon_drawing
    if icon_image then
      icon_drawing = hs.drawing.image({x = (x + outer_padding + icon_padding), y = (y + outer_padding + ((header_height - icon_size) / 2)), w = icon_size, h = icon_size}, icon_image)
    else
      icon_drawing = nil
    end
    local text_height = 18
    local text_x_offset
    if icon_image then
      text_x_offset = (outer_padding + icon_padding + icon_size + 8)
    else
      text_x_offset = (outer_padding + inner_padding)
    end
    local header_text = hs.drawing.text({x = (x + text_x_offset), y = (y + outer_padding + ((header_height - text_height) / 2)), w = (notif_width - text_x_offset - inner_padding - close_btn_size - close_btn_margin - outer_padding), h = text_height}, title)
    local message_text = hs.drawing.text({x = (x + outer_padding + message_padding), y = (y + outer_padding + header_height + section_gap + message_padding), w = (notif_width - (outer_padding * 2) - (message_padding * 2)), h = actual_message_height}, message)
    local close_btn_x = ((x + notif_width) - close_btn_size - close_btn_margin - outer_padding)
    local close_btn_y = (y + outer_padding + ((header_height - close_btn_size) / 2))
    local close_btn = hs.drawing.text({x = close_btn_x, y = close_btn_y, w = close_btn_size, h = close_btn_size}, "\195\151")
    container_rect:setFill(true)
    container_rect:setFillColor({white = 0.12, alpha = 0.98})
    container_rect:setStroke(true)
    container_rect:setStrokeWidth(1)
    container_rect:setStrokeColor({white = 0.25, alpha = 1})
    container_rect:setRoundedRectRadii(12, 12)
    header_rect:setFill(true)
    header_rect:setFillColor(header_color)
    header_rect:setStroke(false)
    header_rect:setRoundedRectRadii(8, 8)
    message_rect:setFill(true)
    message_rect:setFillColor({white = 0.06, alpha = 1})
    message_rect:setStroke(false)
    message_rect:setRoundedRectRadii(8, 8)
    header_text:setTextFont(title_font)
    header_text:setTextSize(14)
    header_text:setTextColor({white = 1, alpha = 1})
    message_text:setTextFont(message_font)
    message_text:setTextSize(font_size)
    message_text:setTextColor({white = 0.9, alpha = 1})
    close_btn:setTextFont("SF Pro Text")
    close_btn:setTextSize(16)
    close_btn:setTextColor({white = 1, alpha = 0.6})
    container_rect:show()
    header_rect:show()
    message_rect:show()
    if icon_drawing then
      icon_drawing:show()
    else
    end
    header_text:show()
    message_text:show()
    close_btn:show()
    table.insert(drawings, container_rect)
    table.insert(drawings, header_rect)
    table.insert(drawings, message_rect)
    if icon_drawing then
      table.insert(drawings, icon_drawing)
    else
    end
    table.insert(drawings, header_text)
    table.insert(drawings, message_text)
    table.insert(drawings, close_btn)
    local notif = {drawings = drawings, height = total_height, timer = nil}
    close_btn:setBehaviorByLabels({"canvasClickable"})
    local function _8_()
      return remove_notification(notif)
    end
    close_btn:setClickCallback(_8_)
    local function _9_()
      return remove_notification(notif)
    end
    notif["timer"] = hs.timer.doAfter(notification_duration, _9_)
    return table.insert(active_notifications, notif)
  end
  local function notify(title, type, message)
    return show_notification(title, type, message)
  end
  local function info(message)
    return notify("Cosmic Hammer", "info", message)
  end
  local function warn(message)
    return notify("Cosmic Hammer", "warn", message)
  end
  local function error(message)
    return notify("Cosmic Hammer", "error", message)
  end
  local function close_all()
    for _, notif in ipairs(active_notifications) do
      if notif.timer then
        notif.timer:stop()
      else
      end
      for _0, drawing in ipairs(notif.drawings) do
        drawing:delete()
      end
    end
    active_notifications = {}
    return nil
  end
  return {info = info, warn = warn, error = error, ["close-all"] = close_all}
end
notify = require("notify")
package.preload["events"] = package.preload["events"] or function(...)
  local _local_11_ = require("lib.cljlib-shim")
  local string_3f = _local_11_["string?"]
  local _local_42_ = require("sheaf.event-registry")
  local make_event_registry = _local_42_["make-event-registry"]
  local define_event_21 = _local_42_["define-event!"]
  local _local_43_ = require("lib.hierarchy")
  local make_hierarchy = _local_43_["make-hierarchy"]
  local derive_21 = _local_43_["derive!"]
  local number_3f
  local function _44_(x)
    return (type(x) == "number")
  end
  number_3f = _44_
  local table_3f
  local function _45_(x)
    return (type(x) == "table")
  end
  table_3f = _45_
  local boolean_3f
  local function _46_(x)
    return (type(x) == "boolean")
  end
  boolean_3f = _46_
  local nil_or_string_3f
  local function _47_(x)
    return ((x == nil) or string_3f(x))
  end
  nil_or_string_3f = _47_
  local nil_or_number_3f
  local function _48_(x)
    return ((x == nil) or number_3f(x))
  end
  nil_or_number_3f = _48_
  local event_hierarchy = make_hierarchy()
  derive_21(event_hierarchy, "event.kind.fs/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.fs/file-change", "event.kind.fs/any")
  derive_21(event_hierarchy, "event.kind.fs/file-move", "event.kind.fs/any")
  derive_21(event_hierarchy, "event.kind.window/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.window/visible", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/not-visible", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/focused", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/unfocused", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/fullscreened", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/unfullscreened", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/moved", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/resized", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/initial", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/created", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/destroyed", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/minimized", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/deminimized", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/title-changed", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/placed", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/placement-ready", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.mouse/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.mouse/window-hovered", "event.kind.mouse/any")
  derive_21(event_hierarchy, "event.kind.app/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.app/launched", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/terminated", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/activated", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/deactivated", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.app/hidden", "event.kind.app/any")
  derive_21(event_hierarchy, "event.kind.screen/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.screen/added", "event.kind.screen/any")
  derive_21(event_hierarchy, "event.kind.screen/removed", "event.kind.screen/any")
  derive_21(event_hierarchy, "event.kind.screen/layout-changed", "event.kind.screen/any")
  derive_21(event_hierarchy, "event.kind.space/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.space/changed", "event.kind.space/any")
  derive_21(event_hierarchy, "event.kind.space/created", "event.kind.space/any")
  derive_21(event_hierarchy, "event.kind.space/destroyed", "event.kind.space/any")
  derive_21(event_hierarchy, "event.kind.system/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.system/wake", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.system/sleep", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.system/screens-changed", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.system/session-lock", "event.kind.system/any")
  derive_21(event_hierarchy, "event.kind.hotkey/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.hotkey/pressed", "event.kind.hotkey/any")
  derive_21(event_hierarchy, "event.kind.usb/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.usb/attached", "event.kind.usb/any")
  derive_21(event_hierarchy, "event.kind.usb/detached", "event.kind.usb/any")
  derive_21(event_hierarchy, "event.kind.wifi/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.wifi/changed", "event.kind.wifi/any")
  derive_21(event_hierarchy, "event.kind.battery/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.battery/changed", "event.kind.battery/any")
  derive_21(event_hierarchy, "event.kind.url/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.url/opened", "event.kind.url/any")
  local event_registry = make_event_registry({hierarchy = event_hierarchy})
  define_event_21(event_registry, "file-watcher.events/file-change", "File change detected in watched directory", {["file-path"] = string_3f})
  derive_21(event_hierarchy, "file-watcher.events/file-change", "event.kind.fs/file-change")
  define_event_21(event_registry, "hotkey.events/pressed", "Hotkey was pressed", {mods = table_3f, key = string_3f})
  derive_21(event_hierarchy, "hotkey.events/pressed", "event.kind.hotkey/pressed")
  define_event_21(event_registry, "space-watcher.events/space-changed", "Active space/desktop changed", {["space-number"] = number_3f, ["all-spaces"] = table_3f, ["active-spaces"] = table_3f, screens = table_3f})
  derive_21(event_hierarchy, "space-watcher.events/space-changed", "event.kind.space/changed")
  define_event_21(event_registry, "desktop-layout.events/space-created", "Space/desktop was created", {["space-id"] = number_3f, ["screen-uuid"] = string_3f, ["all-spaces"] = table_3f, ["active-spaces"] = table_3f})
  derive_21(event_hierarchy, "desktop-layout.events/space-created", "event.kind.space/created")
  define_event_21(event_registry, "desktop-layout.events/space-destroyed", "Space/desktop was destroyed", {["space-id"] = number_3f, ["screen-uuid"] = string_3f, ["all-spaces"] = table_3f, ["active-spaces"] = table_3f})
  derive_21(event_hierarchy, "desktop-layout.events/space-destroyed", "event.kind.space/destroyed")
  define_event_21(event_registry, "screen-watcher.events/screen-changed", "Screen layout changed", {["all-spaces"] = table_3f, ["active-spaces"] = table_3f, screens = table_3f, windows = table_3f, ["observed-spaces"] = table_3f})
  derive_21(event_hierarchy, "screen-watcher.events/screen-changed", "event.kind.screen/layout-changed")
  define_event_21(event_registry, "mouse-window-watcher.events/window-hovered", "Cursor entered a different standard window", {["window-id"] = number_3f})
  derive_21(event_hierarchy, "mouse-window-watcher.events/window-hovered", "event.kind.mouse/window-hovered")
  define_event_21(event_registry, "mouse-window-management.events/window-placement-ready", "Likely-new window is ready for placement policy", {["window-id"] = number_3f, ["created-at"] = number_3f, ["cursor-screen-uuid"] = string_3f})
  derive_21(event_hierarchy, "mouse-window-management.events/window-placement-ready", "event.kind.window/placement-ready")
  define_event_21(event_registry, "mouse-window-management.events/window-placed", "Window moved to the cursor's screen", {["window-id"] = number_3f, windows = table_3f, ["observed-spaces"] = table_3f})
  derive_21(event_hierarchy, "mouse-window-management.events/window-placed", "event.kind.window/placed")
  local window_fact_schema = {["window-id"] = number_3f, ["app-name"] = nil_or_string_3f, ["bundle-id"] = nil_or_string_3f, ["window-title"] = nil_or_string_3f, frame = table_3f, role = nil_or_string_3f, subrole = nil_or_string_3f, ["has-titlebar"] = boolean_3f, visible = boolean_3f, fullscreen = boolean_3f, ["tab-count"] = number_3f, ["space-id"] = nil_or_number_3f}
  define_event_21(event_registry, "window-watcher.events/focused", "Window gained focus", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/focused", "event.kind.window/focused")
  define_event_21(event_registry, "window-watcher.events/visible", "Window became visible", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/visible", "event.kind.window/visible")
  define_event_21(event_registry, "window-watcher.events/not-visible", "Window is no longer visible", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/not-visible", "event.kind.window/not-visible")
  define_event_21(event_registry, "window-watcher.events/fullscreened", "Window entered fullscreen", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/fullscreened", "event.kind.window/fullscreened")
  define_event_21(event_registry, "window-watcher.events/unfullscreened", "Window exited fullscreen", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/unfullscreened", "event.kind.window/unfullscreened")
  define_event_21(event_registry, "window-watcher.events/moved", "Window was moved or resized", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/moved", "event.kind.window/moved")
  define_event_21(event_registry, "window-watcher.events/created", "Window was created", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/created", "event.kind.window/created")
  define_event_21(event_registry, "window-watcher.events/destroyed", "Window was destroyed (closed)", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/destroyed", "event.kind.window/destroyed")
  define_event_21(event_registry, "window-watcher.events/minimized", "Window was minimized", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/minimized", "event.kind.window/minimized")
  define_event_21(event_registry, "window-watcher.events/deminimized", "Window was unminimized (restored)", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/deminimized", "event.kind.window/deminimized")
  define_event_21(event_registry, "window-watcher.events/title-changed", "Window title changed", window_fact_schema)
  derive_21(event_hierarchy, "window-watcher.events/title-changed", "event.kind.window/title-changed")
  define_event_21(event_registry, "window-watcher.events/initial-windows", "Snapshot of windows on the active Spaces at source startup", {windows = table_3f, ["observed-spaces"] = table_3f})
  derive_21(event_hierarchy, "window-watcher.events/initial-windows", "event.kind.window/initial")
  define_event_21(event_registry, "paper-wm.events/frame-observed", "Latest coalesced frame observation for a PaperWM window", {["window-id"] = number_3f, ["event-kind"] = string_3f, frame = table_3f, generation = number_3f, sequence = number_3f})
  derive_21(event_hierarchy, "paper-wm.events/frame-observed", "event.kind.window/moved")
  define_event_21(event_registry, "paper-wm.events/space-focus-retry", "Retry one generation-scoped PaperWM Space focus operation", {generation = number_3f})
  derive_21(event_hierarchy, "paper-wm.events/space-focus-retry", "event.kind/any")
  define_event_21(event_registry, "window-element-watcher.events/moved", "Window was moved", {["window-id"] = number_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-element-watcher.events/moved", "event.kind.window/moved")
  define_event_21(event_registry, "window-element-watcher.events/resized", "Window was resized", {["window-id"] = number_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-element-watcher.events/resized", "event.kind.window/resized")
  define_event_21(event_registry, "app-watcher.events/launched", "Application launched", {["app-name"] = string_3f, ["bundle-id"] = string_3f, pid = number_3f})
  derive_21(event_hierarchy, "app-watcher.events/launched", "event.kind.app/launched")
  define_event_21(event_registry, "app-watcher.events/terminated", "Application terminated", {["app-name"] = string_3f, ["bundle-id"] = string_3f, pid = number_3f})
  derive_21(event_hierarchy, "app-watcher.events/terminated", "event.kind.app/terminated")
  define_event_21(event_registry, "app-watcher.events/activated", "Application activated (brought to front)", {["app-name"] = string_3f, ["bundle-id"] = string_3f, pid = number_3f})
  derive_21(event_hierarchy, "app-watcher.events/activated", "event.kind.app/activated")
  define_event_21(event_registry, "app-watcher.events/deactivated", "Application deactivated (lost focus)", {["app-name"] = string_3f, ["bundle-id"] = string_3f, pid = number_3f})
  derive_21(event_hierarchy, "app-watcher.events/deactivated", "event.kind.app/deactivated")
  define_event_21(event_registry, "app-watcher.events/hidden", "Application hidden", {["app-name"] = string_3f, ["bundle-id"] = string_3f, pid = number_3f})
  derive_21(event_hierarchy, "app-watcher.events/hidden", "event.kind.app/hidden")
  define_event_21(event_registry, "url-handler.events/url-opened", "URL opened via default browser handler", {url = string_3f, original = string_3f, scheme = string_3f, host = nil_or_string_3f, path = nil_or_string_3f, params = table_3f, sender = nil_or_string_3f, ["sender-bundle-id"] = nil_or_string_3f})
  derive_21(event_hierarchy, "url-handler.events/url-opened", "event.kind.url/opened")
  return {["event-registry"] = event_registry}
end
package.preload["sheaf.event-registry"] = package.preload["sheaf.event-registry"] or function(...)
  local _local_35_ = require("lib.hierarchy")
  local isa_3f = _local_35_["isa?"]
  local function make_event_registry(opts)
    if (nil == opts.hierarchy) then
      error("make-event-registry: :hierarchy is required")
    else
    end
    return {events = {}, hierarchy = opts.hierarchy, handlers = {}, queue = {}}
  end
  local function define_event_21(registry, event_name, description, schema)
    if (nil ~= registry.events[event_name]) then
      error(("Event already defined: " .. tostring(event_name)))
    else
    end
    registry.events[event_name] = {description = description, schema = schema}
    return nil
  end
  local function event_defined_3f(registry, event_name)
    return (nil ~= registry.events[event_name])
  end
  local function valid_event_selector_3f(registry, selector)
    local or_38_ = event_defined_3f(registry, selector)
    if not or_38_ then
      local found = false
      for event_name, _ in pairs(registry.events) do
        if found then break end
        if isa_3f(registry.hierarchy, event_name, selector) then
          found = true
        else
        end
      end
      or_38_ = found
    end
    return or_38_
  end
  local function add_event_handler_21(registry, key, handler)
    if (nil ~= registry.handlers[key]) then
      error(("Event handler already registered: " .. tostring(key)))
    else
    end
    registry.handlers[key] = handler
    return nil
  end
  local function remove_event_handler_21(registry, key)
    registry.handlers[key] = nil
    return nil
  end
  local function dispatch_event_21(registry, event_name, event_source, event_data)
    if not event_defined_3f(registry, event_name) then
      print(("[WARN] dispatch-event!: event '" .. tostring(event_name) .. "' not defined"))
    else
    end
    local event = {timestamp = hs.timer.secondsSinceEpoch(), ["event-name"] = event_name, ["event-source"] = event_source, ["event-data"] = event_data}
    return table.insert(registry.queue, event)
  end
  return {["make-event-registry"] = make_event_registry, ["define-event!"] = define_event_21, ["event-defined?"] = event_defined_3f, ["valid-event-selector?"] = valid_event_selector_3f, ["add-event-handler!"] = add_event_handler_21, ["remove-event-handler!"] = remove_event_handler_21, ["dispatch-event!"] = dispatch_event_21}
end
package.preload["lib.hierarchy"] = package.preload["lib.hierarchy"] or function(...)
  local _local_12_ = require("lib.cljlib-shim")
  local hash_set = _local_12_["hash-set"]
  local conj = _local_12_.conj
  local disj = _local_12_.disj
  local contains_3f = _local_12_["contains?"]
  local into = _local_12_.into
  local mapcat = _local_12_.mapcat
  local empty_3f = _local_12_["empty?"]
  local seq = _local_12_.seq
  local function ensure_entry(h, tag)
    if (nil == h[tag]) then
      h[tag] = {parents = hash_set(), children = hash_set()}
      return nil
    else
      return nil
    end
  end
  local function parents(h, tag)
    local _15_
    do
      local t_14_ = h
      if (nil ~= t_14_) then
        t_14_ = t_14_[tag]
      else
      end
      if (nil ~= t_14_) then
        t_14_ = t_14_.parents
      else
      end
      _15_ = t_14_
    end
    return (_15_ or hash_set())
  end
  local function children(h, tag)
    local _19_
    do
      local t_18_ = h
      if (nil ~= t_18_) then
        t_18_ = t_18_[tag]
      else
      end
      if (nil ~= t_18_) then
        t_18_ = t_18_.children
      else
      end
      _19_ = t_18_
    end
    return (_19_ or hash_set())
  end
  local function ancestors(h, tag)
    local ps = parents(h, tag)
    if empty_3f(ps) then
      return ps
    else
      local function _22_(_241)
        return ancestors(h, _241)
      end
      return into(ps, mapcat(_22_, seq(ps)))
    end
  end
  local function descendants(h, tag)
    local cs = children(h, tag)
    if empty_3f(cs) then
      return cs
    else
      local function _24_(_241)
        return descendants(h, _241)
      end
      return into(cs, mapcat(_24_, seq(cs)))
    end
  end
  local function isa_3f(h, child, parent)
    if (child == parent) then
      return true
    else
      local visited = hash_set()
      local queue = {child}
      local found = false
      while (not found and (0 < #queue)) do
        local current = table.remove(queue, 1)
        local current_parents = parents(h, current)
        for p in pairs(current_parents) do
          if found then break end
          if (p == parent) then
            found = true
          else
            if not contains_3f(visited, p) then
              conj(visited, p)
              table.insert(queue, p)
            else
            end
          end
        end
      end
      return found
    end
  end
  local function derive_21(h, child, parent)
    if (child == parent) then
      error("Cannot derive a keyword from itself")
    else
    end
    if isa_3f(h, parent, child) then
      error(("Cycle detected: " .. tostring(parent) .. " already derives from " .. tostring(child)))
    else
    end
    ensure_entry(h, child)
    ensure_entry(h, parent)
    h[child]["parents"] = conj(h[child].parents, parent)
    h[parent]["children"] = conj(h[parent].children, child)
    return h
  end
  local function underive_21(h, child, parent)
    do
      local child_entry = h[child]
      if child_entry then
        child_entry["parents"] = disj(child_entry.parents, parent)
      else
      end
    end
    do
      local parent_entry = h[parent]
      if parent_entry then
        parent_entry["children"] = disj(parent_entry.children, child)
      else
      end
    end
    return h
  end
  local function make_hierarchy(_3finit_pairs)
    local h = {}
    if _3finit_pairs then
      for i = 1, #_3finit_pairs, 2 do
        local child = _3finit_pairs[i]
        local parent = _3finit_pairs[(i + 1)]
        if (child and parent) then
          derive_21(h, child, parent)
        else
        end
      end
    else
    end
    return h
  end
  return {["make-hierarchy"] = make_hierarchy, ["derive!"] = derive_21, ["underive!"] = underive_21, parents = parents, children = children, ancestors = ancestors, descendants = descendants, ["isa?"] = isa_3f}
end
local _local_49_ = require("events")
local event_registry = _local_49_["event-registry"]
package.preload["traits"] = package.preload["traits"] or function(...)
  local _local_50_ = require("lib.hierarchy")
  local make_hierarchy = _local_50_["make-hierarchy"]
  local derive_21 = _local_50_["derive!"]
  local _local_69_ = require("sheaf.trait-registry")
  local make_trait_registry = _local_69_["make-trait-registry"]
  local make_trait = _local_69_["make-trait"]
  local add_trait_21 = _local_69_["add-trait!"]
  local boolean_3f
  local function _70_(_241)
    return (type(_241) == "boolean")
  end
  boolean_3f = _70_
  local number_3f
  local function _71_(_241)
    return (type(_241) == "number")
  end
  number_3f = _71_
  local table_3f
  local function _72_(_241)
    return (type(_241) == "table")
  end
  table_3f = _72_
  local function non_nil_3f(v)
    return (nil ~= v)
  end
  local trait_hierarchy = make_hierarchy()
  derive_21(trait_hierarchy, "trait.kind/ui", "trait.kind/any")
  derive_21(trait_hierarchy, "trait.kind/windowing", "trait.kind/any")
  derive_21(trait_hierarchy, "trait.kind/scheduling", "trait.kind/any")
  derive_21(trait_hierarchy, "trait/has-menubar", "trait.kind/ui")
  derive_21(trait_hierarchy, "trait/has-expose", "trait.kind/ui")
  derive_21(trait_hierarchy, "trait/has-chooser", "trait.kind/ui")
  derive_21(trait_hierarchy, "trait/has-canvas", "trait.kind/ui")
  derive_21(trait_hierarchy, "trait/has-window-filter", "trait.kind/windowing")
  derive_21(trait_hierarchy, "trait/has-layout", "trait.kind/windowing")
  derive_21(trait_hierarchy, "trait/has-paper-wm-runtime", "trait.kind/windowing")
  derive_21(trait_hierarchy, "trait/has-tiling-state", "trait.kind/windowing")
  derive_21(trait_hierarchy, "trait/has-delayed-timer", "trait.kind/scheduling")
  derive_21(trait_hierarchy, "trait.kind/data", "trait.kind/any")
  derive_21(trait_hierarchy, "trait/has-url-routing-rules", "trait.kind/data")
  derive_21(trait_hierarchy, "trait/has-url-history", "trait.kind/data")
  derive_21(trait_hierarchy, "trait/has-window-state", "trait.kind/data")
  derive_21(trait_hierarchy, "trait/has-desktop-layout", "trait.kind/data")
  derive_21(trait_hierarchy, "trait/has-mouse-window-management-state", "trait.kind/data")
  local trait_registry = make_trait_registry({hierarchy = trait_hierarchy})
  add_trait_21(trait_registry, make_trait("trait/has-menubar", "Component state includes an hs.menubar object", {menubar = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-expose", "Component state includes an hs.expose object", {expose = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-chooser", "Component state includes an hs.chooser object", {chooser = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-canvas", "Component state includes hs.canvas objects", {["active-canvas"] = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-window-filter", "Component state includes an hs.window.filter", {["window-filter"] = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-layout", "Component state includes window layout tables", {["window-list"] = non_nil_3f, ["index-table"] = non_nil_3f}))
  local function _73_(state)
    local resources = state.resources
    return (("table" == type(resources.windows)) and ("table" == type(resources["ui-watchers"])) and ("table" == type(resources["watcher-restart-timers"])) and ("table" == type(resources["frame-observations"])))
  end
  add_trait_21(trait_registry, make_trait("trait/has-paper-wm-runtime", "Component state owns PaperWM resources during migration", {["active?"] = boolean_3f, epoch = number_3f, config = table_3f, ["tiling-state"] = table_3f, resources = table_3f}, _73_))
  local function _74_(state)
    local tiling_state = state["tiling-state"]
    return (("table" == type(tiling_state.spaces)) and ("table" == type(tiling_state.index)))
  end
  add_trait_21(trait_registry, make_trait("trait/has-tiling-state", "Component state includes serializable PaperWM tiling facts", {["tiling-state"] = table_3f}, _74_))
  add_trait_21(trait_registry, make_trait("trait/has-delayed-timer", "Component state includes an hs.timer.delayed", {timer = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-url-routing-rules", "Component state includes URL routing configuration: browsers, fallback, and rules", {browsers = non_nil_3f, fallback = non_nil_3f, rules = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-url-history", "Component state includes URL visit history", {history = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-window-state", "Component state includes a map of tracked window states", {windows = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-desktop-layout", "Component state includes the ordered desktop layout", {["all-spaces"] = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-mouse-window-management-state", "Component state tracks hover focus, Space changes, and delayed placement", {["pending-placement-timers"] = non_nil_3f, ["hover-focus-window-ids"] = non_nil_3f}))
  return {["trait-registry"] = trait_registry}
end
package.preload["sheaf.trait-registry"] = package.preload["sheaf.trait-registry"] or function(...)
  local _local_51_ = require("lib.hierarchy")
  local isa_3f = _local_51_["isa?"]
  local function make_trait_registry(opts)
    if (nil == opts.hierarchy) then
      error("make-trait-registry: :hierarchy is required")
    else
    end
    return {traits = {}, hierarchy = opts.hierarchy}
  end
  local function trait_attrs(trait)
    return (trait.attrs or trait.schema)
  end
  local function normalize_attrs(attrs)
    local _54_
    do
      local t_53_ = attrs
      if (nil ~= t_53_) then
        t_53_ = t_53_.attrs
      else
      end
      _54_ = t_53_
    end
    local or_56_ = _54_
    if not or_56_ then
      local t_57_ = attrs
      if (nil ~= t_57_) then
        t_57_ = t_57_.schema
      else
      end
      or_56_ = t_57_
    end
    return (or_56_ or attrs)
  end
  local function normalize_pred(attrs, pred)
    local or_59_ = pred
    if not or_59_ then
      local t_60_ = attrs
      if (nil ~= t_60_) then
        t_60_ = t_60_.pred
      else
      end
      or_59_ = t_60_
    end
    return or_59_
  end
  local function make_trait(name, description, attrs, _3fpred)
    local normalized_attrs = normalize_attrs(attrs)
    local normalized_pred = normalize_pred(attrs, _3fpred)
    if (nil == normalized_attrs) then
      error(("make-trait: attrs are required for " .. tostring(name)))
    else
    end
    return {name = name, description = description, attrs = normalized_attrs, pred = normalized_pred}
  end
  local function add_trait_21(registry, trait)
    local name = trait.name
    if (nil == name) then
      error("add-trait!: trait must have a :name")
    else
    end
    if (nil ~= registry.traits[name]) then
      error(("Trait already registered: " .. tostring(name)))
    else
    end
    registry.traits[name] = trait
    return nil
  end
  local function trait_defined_3f(registry, name)
    return (nil ~= registry.traits[name])
  end
  local function get_trait(registry, name)
    return registry.traits[name]
  end
  local function list_traits(registry)
    local names = {}
    for name, _ in pairs(registry.traits) do
      table.insert(names, name)
    end
    return names
  end
  local function satisfies_3f(registry, trait_name, state)
    local trait = get_trait(registry, trait_name)
    if (nil == trait) then
      error(("satisfies?: trait not found: " .. tostring(trait_name)))
    else
    end
    local ok = true
    for key, pred in pairs(trait_attrs(trait)) do
      if not ok then break end
      local val = (state or {})[key]
      if not pred(val) then
        ok = false
      else
      end
    end
    if (ok and trait.pred and not trait.pred((state or {}))) then
      ok = false
    else
    end
    return ok
  end
  local function satisfies_all_3f(registry, trait_names, state)
    local ok = true
    for _, trait_name in ipairs(trait_names) do
      if not ok then break end
      if not satisfies_3f(registry, trait_name, state) then
        ok = false
      else
      end
    end
    return ok
  end
  local function trait_isa_3f(registry, child, parent)
    return isa_3f(registry.hierarchy, child, parent)
  end
  return {["make-trait-registry"] = make_trait_registry, ["make-trait"] = make_trait, ["add-trait!"] = add_trait_21, ["trait-defined?"] = trait_defined_3f, ["get-trait"] = get_trait, ["list-traits"] = list_traits, ["satisfies?"] = satisfies_3f, ["satisfies-all?"] = satisfies_all_3f, ["trait-isa?"] = trait_isa_3f}
end
local _local_75_ = require("traits")
local trait_registry = _local_75_["trait-registry"]
package.preload["shapes"] = package.preload["shapes"] or function(...)
  local _local_92_ = require("sheaf.shape-registry")
  local make_shape_registry = _local_92_["make-shape-registry"]
  local make_shape = _local_92_["make-shape"]
  local add_shape_21 = _local_92_["add-shape!"]
  local _local_93_ = require("traits")
  local trait_registry = _local_93_["trait-registry"]
  local shape_registry = make_shape_registry({["trait-registry"] = trait_registry})
  add_shape_21(shape_registry, make_shape("shape/url-routing-rules", "URL routing configuration: browsers, fallback action, and ordered rules", {{name = "default", traits = {"trait/has-url-routing-rules"}}}))
  add_shape_21(shape_registry, make_shape("shape/window-state", "Live index of all tracked windows by window-id", {{name = "default", traits = {"trait/has-window-state"}}}))
  add_shape_21(shape_registry, make_shape("shape/desktop-layout", "Ordered spaces grouped by screen", {{name = "default", traits = {"trait/has-desktop-layout"}}}))
  add_shape_21(shape_registry, make_shape("shape/mouse-window-management-state", "Mouse window management Space-change and placement state", {{name = "default", traits = {"trait/has-mouse-window-management-state"}}}))
  return {["shape-registry"] = shape_registry}
end
package.preload["sheaf.shape-registry"] = package.preload["sheaf.shape-registry"] or function(...)
  local _local_76_ = require("sheaf.trait-registry")
  local satisfies_all_3f = _local_76_["satisfies-all?"]
  local trait_defined_3f = _local_76_["trait-defined?"]
  local function make_shape_registry(opts)
    if ((nil == opts) or (nil == opts["trait-registry"])) then
      error("make-shape-registry: :trait-registry is required")
    else
    end
    return {shapes = {}, ["trait-registry"] = opts["trait-registry"]}
  end
  local function validate_alt(shape_name, alt, index, seen_names)
    if (nil == alt) then
      error(("make-shape: alt at index " .. tostring(index) .. " is nil in " .. tostring(shape_name)))
    else
    end
    if ("table" ~= type(alt)) then
      error(("make-shape: alt at index " .. tostring(index) .. " is not a table in " .. tostring(shape_name)))
    else
    end
    if (nil == alt.name) then
      error(("make-shape: alt at index " .. tostring(index) .. " has no :name in " .. tostring(shape_name)))
    else
    end
    if (nil == alt.traits) then
      error(("make-shape: alt " .. tostring(alt.name) .. " has no :traits in " .. tostring(shape_name)))
    else
    end
    if ("table" ~= type(alt.traits)) then
      error(("make-shape: alt " .. tostring(alt.name) .. " :traits is not a table in " .. tostring(shape_name)))
    else
    end
    if seen_names[alt.name] then
      error(("make-shape: duplicate alt name " .. tostring(alt.name) .. " in " .. tostring(shape_name)))
    else
    end
    seen_names[alt.name] = true
    return nil
  end
  local function make_shape(name, description, alts)
    if (nil == name) then
      error("make-shape: :name is required")
    else
    end
    if (nil == description) then
      error("make-shape: :description is required")
    else
    end
    if ((nil == alts) or (0 == #alts)) then
      error(("make-shape: :alts must not be empty for " .. tostring(name)))
    else
    end
    do
      local seen_names = {}
      for i, alt in ipairs(alts) do
        validate_alt(name, alt, i, seen_names)
      end
    end
    return {name = name, description = description, alts = alts}
  end
  local function add_shape_21(registry, shape)
    local name = shape.name
    if (nil == name) then
      error("add-shape!: shape must have a :name")
    else
    end
    if (nil ~= registry.shapes[name]) then
      error(("Shape already registered: " .. tostring(name)))
    else
    end
    for _, alt in ipairs(shape.alts) do
      for _0, trait_name in ipairs(alt.traits) do
        if not trait_defined_3f(registry["trait-registry"], trait_name) then
          error(("add-shape! " .. tostring(name) .. ": trait '" .. tostring(trait_name) .. "' in alt '" .. tostring(alt.name) .. "' not found in trait-registry"))
        else
        end
      end
    end
    registry.shapes[name] = shape
    return nil
  end
  local function shape_defined_3f(registry, name)
    return (nil ~= registry.shapes[name])
  end
  local function get_shape(registry, name)
    return registry.shapes[name]
  end
  local function list_shapes(registry)
    local names = {}
    for name, _ in pairs(registry.shapes) do
      table.insert(names, name)
    end
    return names
  end
  local function conforms_3f(registry, shape_name, state)
    local shape = get_shape(registry, shape_name)
    if (nil == shape) then
      error(("conforms?: shape not found: " .. tostring(shape_name)))
    else
    end
    local matched = nil
    for _, alt in ipairs(shape.alts) do
      if matched then break end
      if satisfies_all_3f(registry["trait-registry"], alt.traits, (state or {})) then
        matched = alt
      else
      end
    end
    return matched
  end
  return {["make-shape-registry"] = make_shape_registry, ["make-shape"] = make_shape, ["add-shape!"] = add_shape_21, ["shape-defined?"] = shape_defined_3f, ["get-shape"] = get_shape, ["list-shapes"] = list_shapes, ["conforms?"] = conforms_3f}
end
local _local_94_ = require("shapes")
local shape_registry = _local_94_["shape-registry"]
package.preload["event_sources"] = package.preload["event_sources"] or function(...)
  local _local_105_ = require("sheaf.source-registry")
  local make_source_registry = _local_105_["make-source-registry"]
  local add_source_type_21 = _local_105_["add-source-type!"]
  local _local_106_ = require("events")
  local event_registry = _local_106_["event-registry"]
  local _local_112_ = require("event_sources.file-watcher")
  local file_watcher_source_type = _local_112_["file-watcher-source-type"]
  local _local_118_ = require("event_sources.hotkey")
  local hotkey_source_type = _local_118_["hotkey-source-type"]
  local _local_123_ = require("event_sources.space-watcher")
  local space_watcher_source_type = _local_123_["space-watcher-source-type"]
  local _local_140_ = require("event_sources.screen-watcher")
  local screen_watcher_source_type = _local_140_["screen-watcher-source-type"]
  local _local_149_ = require("event_sources.window-watcher")
  local window_watcher_source_type = _local_149_["window-watcher-source-type"]
  local _local_178_ = require("event_sources.mouse-window-watcher")
  local mouse_window_watcher_source_type = _local_178_["mouse-window-watcher-source-type"]
  local _local_187_ = require("event_sources.window-element-watcher")
  local window_element_watcher_source_type = _local_187_["window-element-watcher-source-type"]
  local _local_191_ = require("event_sources.paper-wm-outbox")
  local paper_wm_outbox_source_type = _local_191_["paper-wm-outbox-source-type"]
  local _local_200_ = require("event_sources.app-watcher")
  local app_watcher_source_type = _local_200_["app-watcher-source-type"]
  local _local_238_ = require("event_sources.url-handler")
  local url_handler_source_type = _local_238_["url-handler-source-type"]
  local source_registry = make_source_registry({["event-registry"] = event_registry})
  add_source_type_21(source_registry, file_watcher_source_type)
  add_source_type_21(source_registry, hotkey_source_type)
  add_source_type_21(source_registry, space_watcher_source_type)
  add_source_type_21(source_registry, screen_watcher_source_type)
  add_source_type_21(source_registry, window_watcher_source_type)
  add_source_type_21(source_registry, mouse_window_watcher_source_type)
  add_source_type_21(source_registry, window_element_watcher_source_type)
  add_source_type_21(source_registry, paper_wm_outbox_source_type)
  add_source_type_21(source_registry, app_watcher_source_type)
  add_source_type_21(source_registry, url_handler_source_type)
  return {["source-registry"] = source_registry}
end
package.preload["sheaf.source-registry"] = package.preload["sheaf.source-registry"] or function(...)
  local _local_95_ = require("sheaf.event-registry")
  local dispatch_event_21 = _local_95_["dispatch-event!"]
  local function make_source_registry(opts)
    if (nil == opts["event-registry"]) then
      error("make-source-registry: :event-registry is required")
    else
    end
    return {types = {}, instances = {}, ["event-registry"] = opts["event-registry"]}
  end
  local function make_source_type(type_name, description, opts)
    if (nil == opts["start-fn"]) then
      error(("make-source-type: :start-fn is required for " .. tostring(type_name)))
    else
    end
    return {name = type_name, description = description, ["config-schema"] = (opts["config-schema"] or {}), emits = (opts.emits or {}), ["start-fn"] = opts["start-fn"], ["stop-fn"] = opts["stop-fn"]}
  end
  local function add_source_type_21(registry, source_type)
    local type_name = source_type.name
    if (nil == type_name) then
      error("add-source-type!: source-type must have a :name")
    else
    end
    if (nil ~= registry.types[type_name]) then
      error(("Source type already registered: " .. tostring(type_name)))
    else
    end
    registry.types[type_name] = source_type
    return nil
  end
  local function source_type_defined_3f(registry, type_name)
    return (nil ~= registry.types[type_name])
  end
  local function get_source_type(registry, type_name)
    return registry.types[type_name]
  end
  local function list_source_types(registry)
    local names = {}
    for name, _ in pairs(registry.types) do
      table.insert(names, name)
    end
    return names
  end
  local function source_instance_exists_3f(registry, instance_name)
    return (nil ~= registry.instances[instance_name])
  end
  local function get_source_instance(registry, instance_name)
    return registry.instances[instance_name]
  end
  local function list_source_instances(registry)
    local names = {}
    for name, _ in pairs(registry.instances) do
      table.insert(names, name)
    end
    return names
  end
  local function start_event_source_21(registry, instance_name, type_name, config)
    if source_instance_exists_3f(registry, instance_name) then
      error(("Source instance already exists: " .. tostring(instance_name)))
    else
    end
    local source_type = get_source_type(registry, type_name)
    if (nil == source_type) then
      error(("Source type not found: " .. tostring(type_name)))
    else
    end
    local self = {name = instance_name, type = type_name, config = (config or {})}
    local emit
    local function _102_(event_name, event_data)
      return dispatch_event_21(registry["event-registry"], event_name, instance_name, event_data)
    end
    emit = _102_
    local state = source_type["start-fn"](self, emit)
    registry.instances[instance_name] = {type = type_name, config = (config or {}), state = state}
    return print(("[INFO] Started source instance: " .. tostring(instance_name)))
  end
  local function stop_event_source_21(registry, instance_name)
    local instance = get_source_instance(registry, instance_name)
    if (nil == instance) then
      print(("[WARN] stop-event-source!: instance not found: " .. tostring(instance_name)))
      return nil
    else
    end
    local source_type = get_source_type(registry, instance.type)
    if source_type["stop-fn"] then
      source_type["stop-fn"](instance.state)
    else
    end
    registry.instances[instance_name] = nil
    return print(("[INFO] Stopped source instance: " .. tostring(instance_name)))
  end
  local function stop_all_event_sources_21(registry)
    local names = list_source_instances(registry)
    for _, instance_name in ipairs(names) do
      stop_event_source_21(registry, instance_name)
    end
    return nil
  end
  return {["make-source-registry"] = make_source_registry, ["make-source-type"] = make_source_type, ["add-source-type!"] = add_source_type_21, ["source-type-defined?"] = source_type_defined_3f, ["get-source-type"] = get_source_type, ["list-source-types"] = list_source_types, ["source-instance-exists?"] = source_instance_exists_3f, ["get-source-instance"] = get_source_instance, ["list-source-instances"] = list_source_instances, ["start-event-source!"] = start_event_source_21, ["stop-event-source!"] = stop_event_source_21, ["stop-all-event-sources!"] = stop_all_event_sources_21}
end
package.preload["event_sources.file-watcher"] = package.preload["event_sources.file-watcher"] or function(...)
  local _local_107_ = require("lib.cljlib-shim")
  local mapv = _local_107_.mapv
  local assoc = _local_107_.assoc
  local string_3f = _local_107_["string?"]
  local _local_108_ = require("sheaf.source-registry")
  local make_source_type = _local_108_["make-source-type"]
  local function start_file_watcher(self, emit)
    local path = self.config.path
    local handler
    local function _109_(files, attrs)
      local evs
      local function _110_(_241, _242)
        return assoc(_241, "file-path", _242)
      end
      evs = mapv(_110_, attrs, files)
      for _, ev in ipairs(evs) do
        emit("file-watcher.events/file-change", ev)
      end
      return nil
    end
    handler = _109_
    local watcher = hs.pathwatcher.new(path, handler)
    watcher:start()
    return watcher
  end
  local function stop_file_watcher(state)
    if state then
      return state:stop()
    else
      return nil
    end
  end
  local file_watcher_source_type = make_source_type("event-source.type/file-watcher", "Watches a directory for file changes", {["config-schema"] = {path = string_3f}, emits = {"file-watcher.events/file-change"}, ["start-fn"] = start_file_watcher, ["stop-fn"] = stop_file_watcher})
  return {["file-watcher-source-type"] = file_watcher_source_type}
end
package.preload["event_sources.hotkey"] = package.preload["event_sources.hotkey"] or function(...)
  local _local_113_ = require("lib.cljlib-shim")
  local string_3f = _local_113_["string?"]
  local _local_114_ = require("sheaf.source-registry")
  local make_source_type = _local_114_["make-source-type"]
  local table_3f
  local function _115_(_241)
    return (type(_241) == "table")
  end
  table_3f = _115_
  local function start_hotkey(self, emit)
    local mods = self.config.mods
    local key = self.config.key
    local handler
    local function _116_()
      return emit("hotkey.events/pressed", {mods = mods, key = key})
    end
    handler = _116_
    return hs.hotkey.bind(mods, key, handler)
  end
  local function stop_hotkey(state)
    if state then
      return state:delete()
    else
      return nil
    end
  end
  local hotkey_source_type = make_source_type("event-source.type/hotkey", "Emits an event when a hotkey is pressed", {["config-schema"] = {mods = table_3f, key = string_3f}, emits = {"hotkey.events/pressed"}, ["start-fn"] = start_hotkey, ["stop-fn"] = stop_hotkey})
  return {["hotkey-source-type"] = hotkey_source_type}
end
package.preload["event_sources.space-watcher"] = package.preload["event_sources.space-watcher"] or function(...)
  local _local_119_ = require("sheaf.source-registry")
  local make_source_type = _local_119_["make-source-type"]
  local _local_120_ = require("event_sources.desktop-snapshot")
  local snapshot_desktop = _local_120_["snapshot-desktop"]
  local function start_space_watcher(self, emit)
    local handler
    local function _121_(space_number)
      local snapshot = snapshot_desktop()
      return emit("space-watcher.events/space-changed", {["space-number"] = space_number, ["all-spaces"] = snapshot["all-spaces"], ["active-spaces"] = snapshot["active-spaces"], screens = snapshot.screens})
    end
    handler = _121_
    local watcher = hs.spaces.watcher.new(handler)
    watcher:start()
    return watcher
  end
  local function stop_space_watcher(state)
    if state then
      return state:stop()
    else
      return nil
    end
  end
  local space_watcher_source_type = make_source_type("event-source.type/space-watcher", "Emits an event when the active space/desktop changes", {["config-schema"] = {}, emits = {"space-watcher.events/space-changed"}, ["start-fn"] = start_space_watcher, ["stop-fn"] = stop_space_watcher})
  return {["space-watcher-source-type"] = space_watcher_source_type}
end
package.preload["event_sources.desktop-snapshot"] = package.preload["event_sources.desktop-snapshot"] or function(...)
  local function snapshot_desktop()
    local spaces_layout = hs.spaces.allSpaces()
    local all_spaces = {}
    local screens = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
      local uuid = screen:getUUID()
      table.insert(all_spaces, {uuid, spaces_layout[uuid]})
      table.insert(screens, {uuid = uuid, frame = screen:frame()})
    end
    return {["all-spaces"] = all_spaces, ["active-spaces"] = hs.spaces.activeSpaces(), screens = screens}
  end
  return {["snapshot-desktop"] = snapshot_desktop}
end
package.preload["event_sources.screen-watcher"] = package.preload["event_sources.screen-watcher"] or function(...)
  local _local_124_ = require("sheaf.source-registry")
  local make_source_type = _local_124_["make-source-type"]
  local _local_125_ = require("event_sources.desktop-snapshot")
  local snapshot_desktop = _local_125_["snapshot-desktop"]
  local _local_137_ = require("lib.window-facts")
  local snapshot_observed_windows = _local_137_["snapshot-observed-windows"]
  local function start_screen_watcher(self, emit)
    local handler
    local function _138_()
      local snapshot = snapshot_desktop()
      local windows = snapshot_observed_windows()
      snapshot["windows"] = windows.windows
      snapshot["observed-spaces"] = windows["observed-spaces"]
      return emit("screen-watcher.events/screen-changed", snapshot)
    end
    handler = _138_
    local watcher = hs.screen.watcher.new(handler)
    watcher:start()
    return watcher
  end
  local function stop_screen_watcher(state)
    if state then
      return state:stop()
    else
      return nil
    end
  end
  local screen_watcher_source_type = make_source_type("event-source.type/screen-watcher", "Emits an event when the screen layout changes", {["config-schema"] = {}, emits = {"screen-watcher.events/screen-changed"}, ["start-fn"] = start_screen_watcher, ["stop-fn"] = stop_screen_watcher})
  return {["screen-watcher-source-type"] = screen_watcher_source_type}
end
package.preload["lib.window-facts"] = package.preload["lib.window-facts"] or function(...)
  local function safe_call(object, method)
    if (nil == object) then
      return nil
    else
    end
    local callable = object[method]
    if ("function" == type(callable)) then
      local ok, value = pcall(callable, object)
      if ok then
        return value
      else
        return nil
      end
    else
      return nil
    end
  end
  local function snapshot_window(window)
    local window_id = safe_call(window, "id")
    if (nil == window_id) then
      return nil
    else
    end
    local app = safe_call(window, "application")
    local frame = safe_call(window, "frame")
    local spaces
    do
      local ok, value = pcall(hs.spaces.windowSpaces, window)
      spaces = (ok and value)
    end
    if (nil == frame) then
      return nil
    else
    end
    return {["window-id"] = window_id, ["app-name"] = safe_call(app, "name"), ["bundle-id"] = safe_call(app, "bundleID"), ["window-title"] = safe_call(window, "title"), frame = frame, role = safe_call(window, "role"), subrole = safe_call(window, "subrole"), ["has-titlebar"] = (nil ~= safe_call(window, "zoomButtonRect")), visible = safe_call(window, "isVisible"), fullscreen = safe_call(window, "isFullScreen"), ["tab-count"] = safe_call(window, "tabCount"), ["space-id"] = (spaces and spaces[1])}
  end
  local function snapshot_windows()
    local entries = {}
    local ok, all_windows = pcall(hs.window.allWindows)
    if ok then
      for _, window in ipairs(all_windows) do
        local entry = snapshot_window(window)
        if entry then
          table.insert(entries, entry)
        else
        end
      end
    else
    end
    return entries
  end
  local function active_space_ids()
    local ok, active = pcall(hs.spaces.activeSpaces)
    local result
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for _, space_id in pairs(((ok and active) or {})) do
        local val_28_ = space_id
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      result = tbl_26_
    end
    table.sort(result)
    return result
  end
  local function same_ids_3f(left, right)
    local and_134_ = (#left == #right)
    if and_134_ then
      local same_3f = true
      for index, id in ipairs(left) do
        same_3f = (same_3f and (id == right[index]))
      end
      and_134_ = same_3f
    end
    return and_134_
  end
  local function snapshot_observed_windows()
    local before = active_space_ids()
    local windows = snapshot_windows()
    local after = active_space_ids()
    local _135_
    if same_ids_3f(before, after) then
      _135_ = after
    else
      _135_ = {}
    end
    return {windows = windows, ["observed-spaces"] = _135_}
  end
  return {["snapshot-window"] = snapshot_window, ["snapshot-windows"] = snapshot_windows, ["snapshot-observed-windows"] = snapshot_observed_windows}
end
package.preload["event_sources.window-watcher"] = package.preload["event_sources.window-watcher"] or function(...)
  local _local_141_ = require("sheaf.source-registry")
  local make_source_type = _local_141_["make-source-type"]
  local _local_142_ = require("lib.window-facts")
  local snapshot_window = _local_142_["snapshot-window"]
  local snapshot_observed_windows = _local_142_["snapshot-observed-windows"]
  local WindowFilter = hs.window.filter
  local function make_event_data(window, appName)
    local data = snapshot_window(window)
    if (data and (nil == data["app-name"])) then
      data["app-name"] = appName
    else
    end
    return data
  end
  local function start_window_watcher(self, emit)
    local wf = WindowFilter.new():setOverrideFilter({allowRoles = {"AXUnknown", "AXStandardWindow", "AXDialog", "AXSystemDialog"}})
    local handler
    local function _144_(window, appName, event)
      if window then
        local data = make_event_data(window, appName)
        if data then
          if (event == WindowFilter.windowFocused) then
            return emit("window-watcher.events/focused", data)
          elseif (event == WindowFilter.windowVisible) then
            return emit("window-watcher.events/visible", data)
          elseif (event == WindowFilter.windowNotVisible) then
            return emit("window-watcher.events/not-visible", data)
          elseif (event == WindowFilter.windowFullscreened) then
            return emit("window-watcher.events/fullscreened", data)
          elseif (event == WindowFilter.windowUnfullscreened) then
            return emit("window-watcher.events/unfullscreened", data)
          elseif (event == WindowFilter.windowMoved) then
            return emit("window-watcher.events/moved", data)
          elseif (event == WindowFilter.windowCreated) then
            return emit("window-watcher.events/created", data)
          elseif (event == WindowFilter.windowDestroyed) then
            return emit("window-watcher.events/destroyed", data)
          elseif (event == WindowFilter.windowMinimized) then
            return emit("window-watcher.events/minimized", data)
          elseif (event == WindowFilter.windowUnminimized) then
            return emit("window-watcher.events/deminimized", data)
          elseif (event == WindowFilter.windowTitleChanged) then
            return emit("window-watcher.events/title-changed", data)
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    end
    handler = _144_
    wf:subscribe({WindowFilter.windowFocused, WindowFilter.windowVisible, WindowFilter.windowNotVisible, WindowFilter.windowFullscreened, WindowFilter.windowUnfullscreened, WindowFilter.windowMoved, WindowFilter.windowCreated, WindowFilter.windowDestroyed, WindowFilter.windowMinimized, WindowFilter.windowUnminimized, WindowFilter.windowTitleChanged}, handler)
    emit("window-watcher.events/initial-windows", snapshot_observed_windows())
    return wf
  end
  local function stop_window_watcher(state)
    if state then
      state:unsubscribeAll()
      return state:delete()
    else
      return nil
    end
  end
  local window_watcher_source_type = make_source_type("event-source.type/window-watcher", "Emits events on window focus, visibility, and fullscreen changes", {["config-schema"] = {}, emits = {"window-watcher.events/focused", "window-watcher.events/visible", "window-watcher.events/not-visible", "window-watcher.events/fullscreened", "window-watcher.events/unfullscreened", "window-watcher.events/moved", "window-watcher.events/created", "window-watcher.events/destroyed", "window-watcher.events/minimized", "window-watcher.events/deminimized", "window-watcher.events/title-changed", "window-watcher.events/initial-windows"}, ["start-fn"] = start_window_watcher, ["stop-fn"] = stop_window_watcher})
  return {["window-watcher-source-type"] = window_watcher_source_type}
end
package.preload["event_sources.mouse-window-watcher"] = package.preload["event_sources.mouse-window-watcher"] or function(...)
  local _local_150_ = require("sheaf.source-registry")
  local make_source_type = _local_150_["make-source-type"]
  local number_3f
  local function _151_(_241)
    return (type(_241) == "number")
  end
  number_3f = _151_
  local function window_at_point(point)
    local ok, element = pcall(hs.axuielement.systemElementAtPosition, point)
    if ok then
      local window_element
      local _153_
      do
        local t_152_ = element
        if (nil ~= t_152_) then
          t_152_ = t_152_.AXRole
        else
        end
        _153_ = t_152_
      end
      if (_153_ == "AXWindow") then
        window_element = element
      else
        local t_155_ = element
        if (nil ~= t_155_) then
          t_155_ = t_155_.AXWindow
        else
        end
        window_element = t_155_
      end
      if window_element then
        local converted_ok, window
        local function _158_()
          return window_element:asHSWindow()
        end
        converted_ok, window = pcall(_158_)
        if (converted_ok and window and window:id() and window:isStandard() and (window:pid() ~= hs.processInfo.processID)) then
          return window
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  end
  local function mouse_buttons_down_3f()
    local buttons = hs.eventtap.checkMouseButtons()
    return (buttons.left or buttons.right or buttons.middle)
  end
  local function start_mouse_window_watcher(self, emit)
    local dwell = (self.config.dwell or 0.06)
    local state = {["candidate-window-id"] = nil, ["last-window-id"] = nil, ["dwell-timer"] = nil, eventtap = nil}
    local observe_21
    local function _162_(position)
      if not mouse_buttons_down_3f() then
        local ok, window = pcall(window_at_point, position)
        local window_id = (ok and window and window:id())
        if (window_id ~= state["candidate-window-id"]) then
          if state["dwell-timer"] then
            state["dwell-timer"]:stop()
            state["dwell-timer"] = nil
          else
          end
          state["candidate-window-id"] = window_id
          if (window_id and (window_id ~= state["last-window-id"])) then
            local candidate_id = window_id
            local dwell_timer
            local function _164_()
              if (candidate_id == state["candidate-window-id"]) then
                state["last-window-id"] = candidate_id
                state["dwell-timer"] = nil
                return emit("mouse-window-watcher.events/window-hovered", {["window-id"] = candidate_id})
              else
                return nil
              end
            end
            dwell_timer = hs.timer.doAfter(dwell, _164_)
            state["dwell-timer"] = dwell_timer
            return nil
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    end
    observe_21 = _162_
    local eventtap
    local function _169_(event)
      observe_21(event:location())
      return false
    end
    eventtap = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, _169_)
    state["eventtap"] = eventtap
    eventtap:start()
    return state
  end
  local function stop_mouse_window_watcher(state)
    local _171_
    do
      local t_170_ = state
      if (nil ~= t_170_) then
        t_170_ = t_170_["dwell-timer"]
      else
      end
      _171_ = t_170_
    end
    if _171_ then
      state["dwell-timer"]:stop()
    else
    end
    local _175_
    do
      local t_174_ = state
      if (nil ~= t_174_) then
        t_174_ = t_174_.eventtap
      else
      end
      _175_ = t_174_
    end
    if _175_ then
      return state.eventtap:stop()
    else
      return nil
    end
  end
  local mouse_window_watcher_source_type = make_source_type("event-source.type/mouse-window-watcher", "Emits when the standard window under a moving cursor changes", {["config-schema"] = {dwell = number_3f}, emits = {"mouse-window-watcher.events/window-hovered"}, ["start-fn"] = start_mouse_window_watcher, ["stop-fn"] = stop_mouse_window_watcher})
  return {["mouse-window-watcher-source-type"] = mouse_window_watcher_source_type, ["window-at-point"] = window_at_point}
end
package.preload["event_sources.window-element-watcher"] = package.preload["event_sources.window-element-watcher"] or function(...)
  local _local_179_ = require("sheaf.source-registry")
  local make_source_type = _local_179_["make-source-type"]
  local Watcher = hs.uielement.watcher
  local number_3f
  local function _180_(x)
    return (type(x) == "number")
  end
  number_3f = _180_
  local function start_window_element_watcher(self, emit)
    local window_id = self.config["window-id"]
    local window = hs.window.get(window_id)
    if not window then
      print(("window-element-watcher: window not found for id " .. tostring(window_id)))
      return nil
    else
      local callback
      local function _181_(element, event_name, _watcher_obj, _user_data)
        local ok, frame
        local function _182_()
          return element:frame()
        end
        ok, frame = pcall(_182_)
        if ok then
          if (event_name == "AXWindowMoved") then
            return emit("window-element-watcher.events/moved", {["window-id"] = window_id, frame = frame})
          elseif (event_name == "AXWindowResized") then
            return emit("window-element-watcher.events/resized", {["window-id"] = window_id, frame = frame})
          else
            return nil
          end
        else
          return nil
        end
      end
      callback = _181_
      local watcher = window:newWatcher(callback)
      watcher:start({Watcher.windowMoved, Watcher.windowResized})
      return watcher
    end
  end
  local function stop_window_element_watcher(state)
    if state then
      return state:stop()
    else
      return nil
    end
  end
  local window_element_watcher_source_type = make_source_type("event-source.type/window-element-watcher", "Per-window uielement watcher for move/resize events", {["config-schema"] = {["window-id"] = number_3f}, emits = {"window-element-watcher.events/moved", "window-element-watcher.events/resized"}, ["start-fn"] = start_window_element_watcher, ["stop-fn"] = stop_window_element_watcher})
  return {["window-element-watcher-source-type"] = window_element_watcher_source_type}
end
package.preload["event_sources.paper-wm-outbox"] = package.preload["event_sources.paper-wm-outbox"] or function(...)
  local _local_188_ = require("sheaf.source-registry")
  local make_source_type = _local_188_["make-source-type"]
  local table_3f
  local function _189_(_241)
    return (type(_241) == "table")
  end
  table_3f = _189_
  local function start_outbox(self, emit)
    local runtime = self.config.runtime
    runtime.resources["outbox"] = emit
    return {runtime = runtime, emit = emit}
  end
  local function stop_outbox(state)
    if (state.emit == state.runtime.resources.outbox) then
      state.runtime.resources["outbox"] = nil
      return nil
    else
      return nil
    end
  end
  local paper_wm_outbox_source_type = make_source_type("event-source.type/paper-wm-outbox", "Emits PaperWM asynchronous outcomes: coalesced frame observations and Space focus retries", {["config-schema"] = {runtime = table_3f}, emits = {"paper-wm.events/frame-observed", "paper-wm.events/space-focus-retry"}, ["start-fn"] = start_outbox, ["stop-fn"] = stop_outbox})
  return {["paper-wm-outbox-source-type"] = paper_wm_outbox_source_type}
end
package.preload["event_sources.app-watcher"] = package.preload["event_sources.app-watcher"] or function(...)
  local _local_192_ = require("sheaf.source-registry")
  local make_source_type = _local_192_["make-source-type"]
  local AppWatcher = hs.application.watcher
  local function make_event_data(appName, appObject)
    local _193_
    if appObject then
      _193_ = appObject:bundleID()
    else
      _193_ = ""
    end
    local _195_
    if appObject then
      _195_ = appObject:pid()
    else
      _195_ = 0
    end
    return {["app-name"] = (appName or ""), ["bundle-id"] = _193_, pid = _195_}
  end
  local function start_app_watcher(self, emit)
    local handler
    local function _197_(appName, eventType, appObject)
      local data = make_event_data(appName, appObject)
      if (eventType == AppWatcher.launched) then
        return emit("app-watcher.events/launched", data)
      elseif (eventType == AppWatcher.terminated) then
        return emit("app-watcher.events/terminated", data)
      elseif (eventType == AppWatcher.activated) then
        return emit("app-watcher.events/activated", data)
      elseif (eventType == AppWatcher.deactivated) then
        return emit("app-watcher.events/deactivated", data)
      elseif (eventType == AppWatcher.hidden) then
        return emit("app-watcher.events/hidden", data)
      else
        return nil
      end
    end
    handler = _197_
    local watcher = AppWatcher.new(handler)
    watcher:start()
    return watcher
  end
  local function stop_app_watcher(state)
    if state then
      return state:stop()
    else
      return nil
    end
  end
  local app_watcher_source_type = make_source_type("event-source.type/app-watcher", "Emits events on application lifecycle changes", {["config-schema"] = {}, emits = {"app-watcher.events/launched", "app-watcher.events/terminated", "app-watcher.events/activated", "app-watcher.events/deactivated", "app-watcher.events/hidden"}, ["start-fn"] = start_app_watcher, ["stop-fn"] = stop_app_watcher})
  return {["app-watcher-source-type"] = app_watcher_source_type}
end
package.preload["event_sources.url-handler"] = package.preload["event_sources.url-handler"] or function(...)
  local _local_201_ = require("sheaf.source-registry")
  local make_source_type = _local_201_["make-source-type"]
  local _local_218_ = require("event_sources.url-decoders")
  local run_decoders = _local_218_["run-decoders"]
  local default_decoders = _local_218_["default-decoders"]
  local parse_url_parts = _local_218_["parse-url-parts"]
  local table_3f
  local function _219_(x)
    return (type(x) == "table")
  end
  table_3f = _219_
  local number_3f
  local function _220_(x)
    return (type(x) == "number")
  end
  number_3f = _220_
  local function resolve_sender(sender_pid)
    if ((sender_pid == nil) or (sender_pid == -1) or (sender_pid == 0)) then
      return nil, nil
    else
      local ok, app = pcall(hs.application.applicationForPID, sender_pid)
      if (ok and app) then
        return app:name(), app:bundleID()
      else
        return nil, nil
      end
    end
  end
  local function extract_params(parts, fallback_params)
    if (parts and parts.queryItems) then
      local p = {}
      for _, item in ipairs(parts.queryItems) do
        if item.name then
          p[item.name] = item.value
        else
        end
      end
      return p
    else
      return (fallback_params or {})
    end
  end
  local function start_url_handler(self, emit)
    local decoders = (self.config.decoders or default_decoders)
    local max_depth = (self.config["decoder-max-depth"] or 5)
    local own_bundle_id = hs.processInfo.bundleID
    local raw_prev_http = hs.urlevent.getDefaultHandler("http")
    local raw_prev_https = hs.urlevent.getDefaultHandler("https")
    local prev_http
    if (raw_prev_http ~= own_bundle_id) then
      prev_http = raw_prev_http
    else
      prev_http = nil
    end
    local prev_https
    if (raw_prev_https ~= own_bundle_id) then
      prev_https = raw_prev_https
    else
      prev_https = nil
    end
    local callback
    local function _227_(scheme, host, params, full_url, sender_pid)
      print(("[INFO] url-handler: callback invoked" .. " scheme=" .. tostring(scheme) .. " url=" .. tostring(full_url) .. " senderPID=" .. tostring(sender_pid)))
      local original = full_url
      local decoded = run_decoders(decoders, max_depth, full_url)
      local parts = parse_url_parts(decoded)
      local decoded_params = extract_params(parts, params)
      local sender_name, sender_bid = resolve_sender(sender_pid)
      print(("[DEBUG] url-handler: emitting event, decoded=" .. tostring(decoded) .. " sender=" .. tostring(sender_name) .. " bid=" .. tostring(sender_bid)))
      local _228_
      if parts then
        _228_ = parts.scheme
      else
        _228_ = (scheme or "")
      end
      local _230_
      if parts then
        _230_ = parts.host
      else
        _230_ = (host or "")
      end
      local _232_
      if parts then
        _232_ = parts.path
      else
        _232_ = nil
      end
      return emit("url-handler.events/url-opened", {url = decoded, original = original, scheme = _228_, host = _230_, path = _232_, params = decoded_params, sender = sender_name, ["sender-bundle-id"] = sender_bid})
    end
    callback = _227_
    hs.urlevent.setDefaultHandler("http")
    if prev_http then
      hs.urlevent.setRestoreHandler("http", prev_http)
    else
    end
    hs.urlevent.httpCallback = callback
    print(("[INFO] url-handler: registered, prev-http=" .. tostring(prev_http)))
    return {["prev-http-handler"] = prev_http, ["prev-https-handler"] = prev_https}
  end
  local function stop_url_handler(state)
    if state then
      hs.urlevent.httpCallback = nil
      if state["prev-http-handler"] then
        hs.urlevent.setDefaultHandler("http", state["prev-http-handler"])
      else
      end
      if state["prev-https-handler"] then
        return hs.urlevent.setDefaultHandler("https", state["prev-https-handler"])
      else
        return nil
      end
    else
      return nil
    end
  end
  local url_handler_source_type = make_source_type("event-source.type/url-handler", "Registers as default browser and emits URL-opened events with decoded URLs", {["config-schema"] = {decoders = table_3f, ["decoder-max-depth"] = number_3f}, emits = {"url-handler.events/url-opened"}, ["start-fn"] = start_url_handler, ["stop-fn"] = stop_url_handler})
  return {["url-handler-source-type"] = url_handler_source_type}
end
package.preload["event_sources.url-decoders"] = package.preload["event_sources.url-decoders"] or function(...)
  local _local_202_ = require("lib.cljlib-shim")
  local string_3f = _local_202_["string?"]
  local function escape_lua_pattern(s)
    return string.gsub(s, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
  end
  local function wildcard_to_pattern(wildcard)
    local escaped = escape_lua_pattern(wildcard)
    local pattern = string.gsub(escaped, "%%%*", "(.*)")
    return ("^" .. pattern .. "$")
  end
  local function wildcard_match_3f(value, wildcard)
    if (value and wildcard) then
      local pattern = wildcard_to_pattern(wildcard)
      return (nil ~= string.match(string.lower(value), string.lower(pattern)))
    else
      return nil
    end
  end
  local function field_matches_3f(url_value, pattern)
    if (nil == pattern) then
      return true
    elseif (nil == url_value) then
      return false
    else
      return wildcard_match_3f(url_value, pattern)
    end
  end
  local function decoder_matches_3f(decoder, parts)
    local match_spec = (decoder.match or {})
    return (field_matches_3f(parts.scheme, match_spec.scheme) and field_matches_3f(parts.host, match_spec.host) and field_matches_3f(parts.path, match_spec.path))
  end
  local function parse_url_parts(url)
    local ok, parts = pcall(hs.http.urlParts, url)
    if ok then
      return parts
    else
      return nil
    end
  end
  local function valid_decode_result_3f(result, original_url)
    return (string_3f(result) and (#result > 0) and (result ~= original_url))
  end
  local function run_decoders(decoders, max_depth, url)
    local max_depth0 = (max_depth or 5)
    local current_url = url
    local seen = {}
    seen[url] = true
    local iteration = 0
    local done = false
    while (not done and (iteration < max_depth0)) do
      iteration = (iteration + 1)
      local parts = parse_url_parts(current_url)
      if (nil == parts) then
        done = true
      else
        local changed = false
        for _, decoder in ipairs(decoders) do
          if (not changed and decoder_matches_3f(decoder, parts)) then
            local ok, result = pcall(decoder["decode-fn"], {url = current_url, parts = parts})
            if (ok and valid_decode_result_3f(result, current_url)) then
              if seen[result] then
                print(("[WARN] url-decoders: loop detected, stopping at: " .. current_url))
                done = true
              else
                seen[result] = true
                current_url = result
                changed = true
              end
            else
            end
            if not ok then
              print(("[WARN] url-decoders: decoder '" .. tostring(decoder.name) .. "' failed: " .. tostring(result)))
            else
            end
          else
          end
        end
        if not changed then
          done = true
        else
        end
      end
    end
    return current_url
  end
  local slack_redir_decoder
  local function _212_(ctx)
    if ctx.parts.queryItems then
      local target = nil
      for _, item in ipairs(ctx.parts.queryItems) do
        if (not target and item.name and (item.name == "url")) then
          target = item.value
        else
        end
      end
      return target
    else
      return nil
    end
  end
  slack_redir_decoder = {name = "slack-redir", match = {host = "*.slack-redir.net"}, ["decode-fn"] = _212_}
  local outlook_safelinks_decoder
  local function _215_(ctx)
    if ctx.parts.queryItems then
      local target = nil
      for _, item in ipairs(ctx.parts.queryItems) do
        if (not target and item.name and (item.name == "url")) then
          target = item.value
        else
        end
      end
      return target
    else
      return nil
    end
  end
  outlook_safelinks_decoder = {name = "outlook-safelinks", match = {host = "safelinks.protection.outlook.com"}, ["decode-fn"] = _215_}
  local default_decoders = {slack_redir_decoder, outlook_safelinks_decoder}
  return {["run-decoders"] = run_decoders, ["default-decoders"] = default_decoders, ["wildcard-match?"] = wildcard_match_3f, ["decoder-matches?"] = decoder_matches_3f, ["parse-url-parts"] = parse_url_parts}
end
require("event_sources")
package.preload["components"] = package.preload["components"] or function(...)
  local _local_239_ = require("lib.hierarchy")
  local make_hierarchy = _local_239_["make-hierarchy"]
  local derive_21 = _local_239_["derive!"]
  local _local_279_ = require("sheaf.component-registry")
  local make_component_registry = _local_279_["make-component-registry"]
  local add_component_type_21 = _local_279_["add-component-type!"]
  local start_component_21 = _local_279_["start-component!"]
  local make_instance_name = _local_279_["make-instance-name"]
  local _local_280_ = require("sheaf.tag-registry")
  local make_tag_registry = _local_280_["make-tag-registry"]
  local attach_tag_21 = _local_280_["attach-tag!"]
  local _local_281_ = require("traits")
  local trait_registry = _local_281_["trait-registry"]
  local _local_282_ = require("event_sources")
  local source_registry = _local_282_["source-registry"]
  local _local_288_ = require("components.space-indicator")
  local space_indicator_type = _local_288_["space-indicator-type"]
  local _local_292_ = require("components.desktop-layout")
  local desktop_layout_type = _local_292_["desktop-layout-type"]
  local _local_296_ = require("components.mouse-window-management")
  local mouse_window_management_type = _local_296_["mouse-window-management-type"]
  local _local_299_ = require("components.expose")
  local expose_type = _local_299_["expose-type"]
  local _local_302_ = require("components.emacs")
  local emacs_type = _local_302_["emacs-type"]
  local _local_307_ = require("components.reload-hammerspoon")
  local reload_hammerspoon_type = _local_307_["reload-hammerspoon-type"]
  local _local_310_ = require("components.compile-fennel")
  local compile_fennel_type = _local_310_["compile-fennel-type"]
  local _local_313_ = require("components.config-watcher")
  local config_watcher_type = _local_313_["config-watcher-type"]
  local _local_316_ = require("components.window-watcher")
  local window_watcher_type = _local_316_["window-watcher-type"]
  local _local_319_ = require("components.app-watcher")
  local app_watcher_type = _local_319_["app-watcher-type"]
  local _local_325_ = require("components.window-border")
  local window_border_type = _local_325_["window-border-type"]
  local _local_329_ = require("components.url-dispatch")
  local url_dispatch_type = _local_329_["url-dispatch-type"]
  local _local_332_ = require("components.url-routing-rules")
  local url_routing_rules_type = _local_332_["url-routing-rules-type"]
  local _local_335_ = require("components.url-history")
  local url_history_type = _local_335_["url-history-type"]
  local _local_338_ = require("components.window-state")
  local window_state_type = _local_338_["window-state-type"]
  local _local_478_ = require("components.paper-wm")
  local paper_wm_type = _local_478_["paper-wm-type"]
  local component_hierarchy = make_hierarchy()
  derive_21(component_hierarchy, "component.kind/space-indicator", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/desktop-layout", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/mouse-window-management", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/expose", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/emacs", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/reload-hammerspoon", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/compile-fennel", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/config-watcher", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/window-watcher", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/app-watcher", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/window-border", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/url-dispatch", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/url-routing-rules", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/url-history", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/window-state", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/paper-wm", "component.kind/any")
  derive_21(component_hierarchy, "component.type/space-indicator", "component.kind/space-indicator")
  derive_21(component_hierarchy, "component.type/desktop-layout", "component.kind/desktop-layout")
  derive_21(component_hierarchy, "component.type/mouse-window-management", "component.kind/mouse-window-management")
  derive_21(component_hierarchy, "component.type/expose", "component.kind/expose")
  derive_21(component_hierarchy, "component.type/emacs", "component.kind/emacs")
  derive_21(component_hierarchy, "component.type/reload-hammerspoon", "component.kind/reload-hammerspoon")
  derive_21(component_hierarchy, "component.type/compile-fennel", "component.kind/compile-fennel")
  derive_21(component_hierarchy, "component.type/config-watcher", "component.kind/config-watcher")
  derive_21(component_hierarchy, "component.type/window-watcher", "component.kind/window-watcher")
  derive_21(component_hierarchy, "component.type/app-watcher", "component.kind/app-watcher")
  derive_21(component_hierarchy, "component.type/window-border", "component.kind/window-border")
  derive_21(component_hierarchy, "component.type/url-dispatch", "component.kind/url-dispatch")
  derive_21(component_hierarchy, "component.type/url-routing-rules", "component.kind/url-routing-rules")
  derive_21(component_hierarchy, "component.type/url-history", "component.kind/url-history")
  derive_21(component_hierarchy, "component.type/window-state", "component.kind/window-state")
  derive_21(component_hierarchy, "component.type/paper-wm", "component.kind/paper-wm")
  local tag_registry = make_tag_registry()
  local component_registry = make_component_registry({hierarchy = component_hierarchy, ["trait-registry"] = trait_registry, ["source-registry"] = source_registry, ["tag-registry"] = tag_registry})
  add_component_type_21(component_registry, space_indicator_type)
  add_component_type_21(component_registry, desktop_layout_type)
  add_component_type_21(component_registry, mouse_window_management_type)
  add_component_type_21(component_registry, expose_type)
  add_component_type_21(component_registry, emacs_type)
  add_component_type_21(component_registry, reload_hammerspoon_type)
  add_component_type_21(component_registry, compile_fennel_type)
  add_component_type_21(component_registry, config_watcher_type)
  add_component_type_21(component_registry, window_watcher_type)
  add_component_type_21(component_registry, app_watcher_type)
  add_component_type_21(component_registry, window_border_type)
  add_component_type_21(component_registry, url_dispatch_type)
  add_component_type_21(component_registry, url_routing_rules_type)
  add_component_type_21(component_registry, url_history_type)
  add_component_type_21(component_registry, window_state_type)
  add_component_type_21(component_registry, paper_wm_type)
  local space_indicator_name = make_instance_name("component.type/space-indicator", "main")
  local desktop_layout_name = make_instance_name("component.type/desktop-layout", "main")
  local mouse_window_management_name = make_instance_name("component.type/mouse-window-management", "main")
  local expose_name = make_instance_name("component.type/expose", "main")
  local emacs_name = make_instance_name("component.type/emacs", "main")
  local reload_hammerspoon_name = make_instance_name("component.type/reload-hammerspoon", "main")
  local compile_fennel_name = make_instance_name("component.type/compile-fennel", "main")
  local config_watcher_name = make_instance_name("component.type/config-watcher", "main")
  local window_watcher_name = make_instance_name("component.type/window-watcher", "main")
  local app_watcher_name = make_instance_name("component.type/app-watcher", "main")
  local window_border_name = make_instance_name("component.type/window-border", "main")
  local url_dispatch_name = make_instance_name("component.type/url-dispatch", "main")
  local url_routing_rules_name = make_instance_name("component.type/url-routing-rules", "default")
  local url_history_name = make_instance_name("component.type/url-history", "main")
  local window_state_name = make_instance_name("component.type/window-state", "main")
  local paper_wm_name = make_instance_name("component.type/paper-wm", "main")
  start_component_21(component_registry, "component.type/desktop-layout", desktop_layout_name, {})
  start_component_21(component_registry, "component.type/mouse-window-management", mouse_window_management_name, {})
  start_component_21(component_registry, "component.type/space-indicator", space_indicator_name, {})
  start_component_21(component_registry, "component.type/expose", expose_name, {})
  start_component_21(component_registry, "component.type/emacs", emacs_name, {})
  start_component_21(component_registry, "component.type/reload-hammerspoon", reload_hammerspoon_name, {})
  start_component_21(component_registry, "component.type/compile-fennel", compile_fennel_name, {})
  start_component_21(component_registry, "component.type/config-watcher", config_watcher_name, {})
  start_component_21(component_registry, "component.type/window-watcher", window_watcher_name, {})
  start_component_21(component_registry, "component.type/app-watcher", app_watcher_name, {})
  start_component_21(component_registry, "component.type/window-border", window_border_name, {["active-color"] = "0xffe1e3e4", ["inactive-color"] = "0xff494d64", width = 5, ["corner-radius"] = 9})
  start_component_21(component_registry, "component.type/url-dispatch", url_dispatch_name, {})
  start_component_21(component_registry, "component.type/url-routing-rules", url_routing_rules_name, {})
  start_component_21(component_registry, "component.type/url-history", url_history_name, {})
  start_component_21(component_registry, "component.type/window-state", window_state_name, {})
  start_component_21(component_registry, "component.type/paper-wm", paper_wm_name, {})
  attach_tag_21(tag_registry, space_indicator_name, "tag/space-indicator")
  attach_tag_21(tag_registry, desktop_layout_name, "tag/desktop-layout")
  attach_tag_21(tag_registry, desktop_layout_name, "tag/space-watcher")
  attach_tag_21(tag_registry, mouse_window_management_name, "tag/mouse-window-management")
  attach_tag_21(tag_registry, expose_name, "tag/expose")
  attach_tag_21(tag_registry, emacs_name, "tag/emacs")
  attach_tag_21(tag_registry, reload_hammerspoon_name, "tag/reload-hammerspoon")
  attach_tag_21(tag_registry, compile_fennel_name, "tag/compile-fennel")
  attach_tag_21(tag_registry, window_border_name, "tag/window-border")
  attach_tag_21(tag_registry, url_dispatch_name, "tag/url-dispatch")
  attach_tag_21(tag_registry, url_routing_rules_name, "tag/url-routing-rules")
  attach_tag_21(tag_registry, url_history_name, "tag/url-history")
  attach_tag_21(tag_registry, window_state_name, "tag/window-state")
  attach_tag_21(tag_registry, paper_wm_name, "tag/paper-wm")
  return {["component-registry"] = component_registry, ["tag-registry"] = tag_registry}
end
package.preload["sheaf.component-registry"] = package.preload["sheaf.component-registry"] or function(...)
  local _local_240_ = require("lib.hierarchy")
  local isa_3f = _local_240_["isa?"]
  local _local_241_ = require("sheaf.trait-registry")
  local trait_defined_3f = _local_241_["trait-defined?"]
  local satisfies_all_3f = _local_241_["satisfies-all?"]
  local _local_242_ = require("sheaf.source-registry")
  local source_type_defined_3f = _local_242_["source-type-defined?"]
  local start_event_source_21 = _local_242_["start-event-source!"]
  local stop_event_source_21 = _local_242_["stop-event-source!"]
  local _local_253_ = require("sheaf.tag-registry")
  local attach_tag_21 = _local_253_["attach-tag!"]
  local detach_tag_21 = _local_253_["detach-tag!"]
  local function type_name__3edescriptor(type_name)
    return string.match(tostring(type_name), "^component%.type/(.+)$")
  end
  local function make_instance_name(type_name, instance_id)
    local descriptor = type_name__3edescriptor(type_name)
    if (nil == descriptor) then
      error(("make-instance-name: invalid type name format: " .. tostring(type_name) .. " (expected :component.type/<descriptor>)"))
    else
    end
    return ("component." .. descriptor .. ".instance/" .. instance_id)
  end
  local function escape_pattern(s)
    return string.gsub(s, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
  end
  local function source_type_name__3edescriptor(source_type_name)
    return string.match(tostring(source_type_name), "^event%-source%.type/(.+)$")
  end
  local function make_owned_source_name(comp_instance_name, source_type_name, source_id)
    local comp_part = string.gsub(tostring(comp_instance_name), "/", ".")
    local source_descriptor = source_type_name__3edescriptor(source_type_name)
    if (nil == source_descriptor) then
      error(("make-owned-source-name: invalid source type name: " .. tostring(source_type_name)))
    else
    end
    return (comp_part .. ".event-source." .. source_descriptor .. ".instance/" .. source_id)
  end
  local function valid_instance_name_3f(type_name, instance_name)
    local descriptor = type_name__3edescriptor(type_name)
    if (nil == descriptor) then
      return false
    else
      return (nil ~= string.match(tostring(instance_name), ("^component%." .. escape_pattern(descriptor) .. "%.instance/.+$")))
    end
  end
  local function make_component_registry(opts)
    if (nil == opts.hierarchy) then
      error("make-component-registry: :hierarchy is required")
    else
    end
    if (nil == opts["trait-registry"]) then
      error("make-component-registry: :trait-registry is required")
    else
    end
    if (nil == opts["source-registry"]) then
      error("make-component-registry: :source-registry is required")
    else
    end
    if (nil == opts["tag-registry"]) then
      error("make-component-registry: :tag-registry is required")
    else
    end
    return {["component-types"] = {}, instances = {}, hierarchy = opts.hierarchy, ["trait-registry"] = opts["trait-registry"], ["source-registry"] = opts["source-registry"], ["tag-registry"] = opts["tag-registry"]}
  end
  local function make_component_type(name, description, opts)
    if (nil == opts["start-fn"]) then
      error(("make-component-type: :start-fn is required for " .. tostring(name)))
    else
    end
    return {name = name, description = description, traits = (opts.traits or {}), sources = (opts.sources or {}), ["config-schema"] = (opts["config-schema"] or {}), ["start-fn"] = opts["start-fn"], ["stop-fn"] = opts["stop-fn"]}
  end
  local function add_component_type_21(registry, component_type)
    local name = component_type.name
    if (nil == name) then
      error("add-component-type!: component-type must have a :name")
    else
    end
    if (nil ~= registry["component-types"][name]) then
      error(("Component type already registered: " .. tostring(name)))
    else
    end
    for _, trait_name in ipairs((component_type.traits or {})) do
      if not trait_defined_3f(registry["trait-registry"], trait_name) then
        error(("add-component-type! " .. tostring(name) .. ": trait '" .. tostring(trait_name) .. "' not found in trait-registry"))
      else
      end
    end
    for _, source_decl in ipairs((component_type.sources or {})) do
      if (nil == source_decl.type) then
        error(("add-component-type! " .. tostring(name) .. ": source declaration missing :type"))
      else
      end
      if (nil == source_decl["instance-name"]) then
        error(("add-component-type! " .. tostring(name) .. ": source declaration missing :instance-name"))
      else
      end
      if not source_type_defined_3f(registry["source-registry"], source_decl.type) then
        error(("add-component-type! " .. tostring(name) .. ": source type '" .. tostring(source_decl.type) .. "' not found in source-registry"))
      else
      end
      for i, tag in ipairs((source_decl.tags or {})) do
        if (nil == tag) then
          error(("add-component-type! " .. tostring(name) .. ": source declaration :tags[" .. tostring(i) .. "] is nil"))
        else
        end
      end
    end
    registry["component-types"][name] = component_type
    return nil
  end
  local function component_type_defined_3f(registry, name)
    return (nil ~= registry["component-types"][name])
  end
  local function get_component_type(registry, name)
    return registry["component-types"][name]
  end
  local function list_component_types(registry)
    local names = {}
    for name, _ in pairs(registry["component-types"]) do
      table.insert(names, name)
    end
    return names
  end
  local function component_instance_exists_3f(registry, instance_name)
    return (nil ~= registry.instances[instance_name])
  end
  local function get_component_instance(registry, instance_name)
    return registry.instances[instance_name]
  end
  local function list_component_instances(registry)
    local names = {}
    for name, _ in pairs(registry.instances) do
      table.insert(names, name)
    end
    return names
  end
  local function start_component_21(registry, type_name, instance_name, config)
    if component_instance_exists_3f(registry, instance_name) then
      error(("start-component!: instance already exists: " .. tostring(instance_name)))
    else
    end
    if not valid_instance_name_3f(type_name, instance_name) then
      error(("start-component!: instance name '" .. tostring(instance_name) .. "' does not follow naming convention for type " .. tostring(type_name) .. " (expected :component.<descriptor>.instance/<id>," .. " use make-instance-name to construct)"))
    else
    end
    local component_type = get_component_type(registry, type_name)
    if (nil == component_type) then
      error(("start-component!: type not found: " .. tostring(type_name)))
    else
    end
    local state = component_type["start-fn"]((config or {}))
    if ((0 < #component_type.traits) and (nil == state)) then
      error(("start-component!: start-fn for " .. tostring(type_name) .. " returned nil but type declares traits"))
    else
    end
    if not satisfies_all_3f(registry["trait-registry"], component_type.traits, (state or {})) then
      error(("start-component!: state from " .. tostring(type_name) .. " does not satisfy declared traits for instance " .. tostring(instance_name)))
    else
    end
    local started_sources = {}
    local start_err
    do
      local err = nil
      for _, source_decl in ipairs((component_type.sources or {})) do
        if err then break end
        local source_name = make_owned_source_name(instance_name, source_decl.type, source_decl["instance-name"])
        local source_config
        if source_decl["config-fn"] then
          source_config = source_decl["config-fn"](state, (config or {}), instance_name)
        else
          source_config = (source_decl.config or {})
        end
        local ok, result = pcall(start_event_source_21, registry["source-registry"], source_name, source_decl.type, source_config)
        if ok then
          for _0, tag in ipairs((source_decl.tags or {})) do
            attach_tag_21(registry["tag-registry"], source_name, tag)
          end
          table.insert(started_sources, {name = source_name, tags = (source_decl.tags or {})})
        else
          err = ("start-component!: failed to start source " .. tostring(source_name) .. " for " .. tostring(instance_name) .. ": " .. tostring(result))
        end
      end
      start_err = err
    end
    if start_err then
      for _, source_info in ipairs(started_sources) do
        for _0, tag in ipairs((source_info.tags or {})) do
          pcall(detach_tag_21, registry["tag-registry"], source_info.name, tag)
        end
        pcall(stop_event_source_21, registry["source-registry"], source_info.name)
      end
      error(start_err)
    else
    end
    registry.instances[instance_name] = {name = instance_name, type = type_name, config = (config or {}), state = state, ["source-instances"] = started_sources}
    return print(("[INFO] Started component instance: " .. tostring(instance_name)))
  end
  local function stop_component_21(registry, instance_name)
    local instance = get_component_instance(registry, instance_name)
    if (nil == instance) then
      error(("stop-component!: instance not found: " .. tostring(instance_name)))
    else
    end
    for _, source_info in ipairs((instance["source-instances"] or {})) do
      for _0, tag in ipairs((source_info.tags or {})) do
        detach_tag_21(registry["tag-registry"], source_info.name, tag)
      end
      stop_event_source_21(registry["source-registry"], source_info.name)
    end
    local component_type = get_component_type(registry, instance.type)
    if component_type["stop-fn"] then
      component_type["stop-fn"](instance.state)
    else
    end
    registry.instances[instance_name] = nil
    return print(("[INFO] Stopped component instance: " .. tostring(instance_name)))
  end
  local function component_type_isa_3f(registry, child, parent)
    return isa_3f(registry.hierarchy, child, parent)
  end
  return {["make-instance-name"] = make_instance_name, ["make-owned-source-name"] = make_owned_source_name, ["valid-instance-name?"] = valid_instance_name_3f, ["make-component-registry"] = make_component_registry, ["make-component-type"] = make_component_type, ["add-component-type!"] = add_component_type_21, ["component-type-defined?"] = component_type_defined_3f, ["get-component-type"] = get_component_type, ["list-component-types"] = list_component_types, ["component-instance-exists?"] = component_instance_exists_3f, ["get-component-instance"] = get_component_instance, ["list-component-instances"] = list_component_instances, ["start-component!"] = start_component_21, ["stop-component!"] = stop_component_21, ["component-type-isa?"] = component_type_isa_3f}
end
package.preload["sheaf.tag-registry"] = package.preload["sheaf.tag-registry"] or function(...)
  local _local_243_ = require("lib.cljlib-shim")
  local hash_set = _local_243_["hash-set"]
  local conj = _local_243_.conj
  local disj = _local_243_.disj
  local contains_3f = _local_243_["contains?"]
  local seq = _local_243_.seq
  local function make_tag_registry()
    return {["instance-tags"] = {}, ["tag-instances"] = {}}
  end
  local function attach_tag_21(registry, instance_name, tag)
    if (nil == instance_name) then
      error("attach-tag!: instance-name must not be nil")
    else
    end
    if (nil == tag) then
      error("attach-tag!: tag must not be nil")
    else
    end
    local inst_tags = (registry["instance-tags"][instance_name] or hash_set())
    local tag_insts = (registry["tag-instances"][tag] or hash_set())
    registry["instance-tags"][instance_name] = conj(inst_tags, tag)
    registry["tag-instances"][tag] = conj(tag_insts, instance_name)
    return nil
  end
  local function detach_tag_21(registry, instance_name, tag)
    local inst_tags = registry["instance-tags"][instance_name]
    local tag_insts = registry["tag-instances"][tag]
    if inst_tags then
      local new_set = disj(inst_tags, tag)
      local _246_
      if seq(new_set) then
        _246_ = new_set
      else
        _246_ = nil
      end
      registry["instance-tags"][instance_name] = _246_
    else
    end
    if tag_insts then
      local new_set = disj(tag_insts, instance_name)
      local _249_
      if seq(new_set) then
        _249_ = new_set
      else
        _249_ = nil
      end
      registry["tag-instances"][tag] = _249_
      return nil
    else
      return nil
    end
  end
  local function get_tags(registry, instance_name)
    return (registry["instance-tags"][instance_name] or hash_set())
  end
  local function components_with_tag(registry, tag)
    return (registry["tag-instances"][tag] or hash_set())
  end
  local function tag_attached_3f(registry, instance_name, tag)
    local inst_tags = registry["instance-tags"][instance_name]
    if inst_tags then
      return contains_3f(inst_tags, tag)
    else
      return false
    end
  end
  return {["make-tag-registry"] = make_tag_registry, ["attach-tag!"] = attach_tag_21, ["detach-tag!"] = detach_tag_21, ["get-tags"] = get_tags, ["components-with-tag"] = components_with_tag, ["tag-attached?"] = tag_attached_3f}
end
package.preload["components.space-indicator"] = package.preload["components.space-indicator"] or function(...)
  local _local_283_ = require("sheaf.component-registry")
  local make_component_type = _local_283_["make-component-type"]
  local space_indicator_type
  local function _284_(config)
    local menubar = hs.menubar.new(true, "cosmicHammerSpaceIndicator")
    if menubar then
      menubar:setTitle("...")
    else
    end
    return {menubar = menubar}
  end
  local function _286_(state)
    if state.menubar then
      return state.menubar:delete()
    else
      return nil
    end
  end
  space_indicator_type = make_component_type("component.type/space-indicator", "Space indicator menubar component", {traits = {"trait/has-menubar"}, ["start-fn"] = _284_, ["stop-fn"] = _286_})
  return {["space-indicator-type"] = space_indicator_type}
end
package.preload["components.desktop-layout"] = package.preload["components.desktop-layout"] or function(...)
  local _local_289_ = require("sheaf.component-registry")
  local make_component_type = _local_289_["make-component-type"]
  local _local_290_ = require("event_sources.desktop-snapshot")
  local snapshot_desktop = _local_290_["snapshot-desktop"]
  local desktop_layout_type
  local function _291_(config)
    local snapshot = snapshot_desktop()
    return {["all-spaces"] = snapshot["all-spaces"]}
  end
  desktop_layout_type = make_component_type("component.type/desktop-layout", "Tracks the current ordered spaces grouped by screen", {traits = {"trait/has-desktop-layout"}, sources = {{type = "event-source.type/space-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/space-watcher"}}, {type = "event-source.type/screen-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/screen-watcher"}}}, ["start-fn"] = _291_})
  return {["desktop-layout-type"] = desktop_layout_type}
end
package.preload["components.mouse-window-management"] = package.preload["components.mouse-window-management"] or function(...)
  local _local_293_ = require("sheaf.component-registry")
  local make_component_type = _local_293_["make-component-type"]
  local mouse_window_management_type
  local function _294_(config)
    return {["last-space-change-at"] = nil, ["pending-placement-timers"] = {}, ["hover-focus-window-ids"] = {}}
  end
  local function _295_(state)
    for _, timer in pairs(state["pending-placement-timers"]) do
      timer:stop()
    end
    return nil
  end
  mouse_window_management_type = make_component_type("component.type/mouse-window-management", "Mouse-driven window focus, cursor following, and window placement", {traits = {"trait/has-mouse-window-management-state"}, sources = {{type = "event-source.type/mouse-window-watcher", config = {dwell = 0.06}, ["instance-name"] = "default", tags = {"tag/mouse-window-watcher"}}}, ["start-fn"] = _294_, ["stop-fn"] = _295_})
  return {["mouse-window-management-type"] = mouse_window_management_type}
end
package.preload["components.expose"] = package.preload["components.expose"] or function(...)
  local _local_297_ = require("sheaf.component-registry")
  local make_component_type = _local_297_["make-component-type"]
  local expose_type
  local function _298_(config)
    return {expose = hs.expose.new()}
  end
  expose_type = make_component_type("component.type/expose", "Expose window picker component", {traits = {"trait/has-expose"}, sources = {{type = "event-source.type/hotkey", config = {mods = {"ctrl", "cmd"}, key = "e"}, ["instance-name"] = "toggle", tags = {"tag/expose-hotkey"}}}, ["start-fn"] = _298_})
  return {["expose-type"] = expose_type}
end
package.preload["components.emacs"] = package.preload["components.emacs"] or function(...)
  local _local_300_ = require("sheaf.component-registry")
  local make_component_type = _local_300_["make-component-type"]
  local emacs_type
  local function _301_(config)
    return {}
  end
  emacs_type = make_component_type("component.type/emacs", "Emacs integration component", {sources = {{type = "event-source.type/hotkey", config = {mods = {"cmd", "alt"}, key = "return"}, ["instance-name"] = "open", tags = {"tag/emacs-hotkey"}}}, ["start-fn"] = _301_})
  return {["emacs-type"] = emacs_type}
end
package.preload["components.reload-hammerspoon"] = package.preload["components.reload-hammerspoon"] or function(...)
  local _local_303_ = require("sheaf.component-registry")
  local make_component_type = _local_303_["make-component-type"]
  local reload_hammerspoon_type
  local function _304_(config)
    local function _305_()
      pcall(hs.opentelemetry.flush, 2)
      return hs.reload()
    end
    return {timer = hs.timer.delayed.new(0.5, _305_), ["reloading?"] = false}
  end
  local function _306_(state)
    return state.timer:stop()
  end
  reload_hammerspoon_type = make_component_type("component.type/reload-hammerspoon", "Hammerspoon config reloader with debounce timer", {traits = {"trait/has-delayed-timer"}, ["start-fn"] = _304_, ["stop-fn"] = _306_})
  return {["reload-hammerspoon-type"] = reload_hammerspoon_type}
end
package.preload["components.compile-fennel"] = package.preload["components.compile-fennel"] or function(...)
  local _local_308_ = require("sheaf.component-registry")
  local make_component_type = _local_308_["make-component-type"]
  local compile_fennel_type
  local function _309_(config)
    return {}
  end
  compile_fennel_type = make_component_type("component.type/compile-fennel", "Fennel source file compiler", {["start-fn"] = _309_})
  return {["compile-fennel-type"] = compile_fennel_type}
end
package.preload["components.config-watcher"] = package.preload["components.config-watcher"] or function(...)
  local _local_311_ = require("sheaf.component-registry")
  local make_component_type = _local_311_["make-component-type"]
  local config_watcher_type
  local function _312_(config)
    return {}
  end
  config_watcher_type = make_component_type("component.type/config-watcher", "Watches config directory for file changes", {sources = {{type = "event-source.type/file-watcher", config = {path = hs.configdir}, ["instance-name"] = "config-dir", tags = {"tag/config-watcher"}}}, ["start-fn"] = _312_})
  return {["config-watcher-type"] = config_watcher_type}
end
package.preload["components.window-watcher"] = package.preload["components.window-watcher"] or function(...)
  local _local_314_ = require("sheaf.component-registry")
  local make_component_type = _local_314_["make-component-type"]
  local window_watcher_type
  local function _315_(config)
    return {}
  end
  window_watcher_type = make_component_type("component.type/window-watcher", "Watches window focus, visibility, and fullscreen changes", {sources = {{type = "event-source.type/window-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/window-watcher"}}}, ["start-fn"] = _315_})
  return {["window-watcher-type"] = window_watcher_type}
end
package.preload["components.app-watcher"] = package.preload["components.app-watcher"] or function(...)
  local _local_317_ = require("sheaf.component-registry")
  local make_component_type = _local_317_["make-component-type"]
  local app_watcher_type
  local function _318_(config)
    return {}
  end
  app_watcher_type = make_component_type("component.type/app-watcher", "Watches application lifecycle events (launch, quit, activate, deactivate, hidden)", {sources = {{type = "event-source.type/app-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/app-watcher"}}}, ["start-fn"] = _318_})
  return {["app-watcher-type"] = app_watcher_type}
end
package.preload["components.window-border"] = package.preload["components.window-border"] or function(...)
  local _local_320_ = require("sheaf.component-registry")
  local make_component_type = _local_320_["make-component-type"]
  local function parse_argb_hex(hex_str)
    local n = tonumber(hex_str)
    local a = (((n >> 24) & 255) / 255)
    local r = (((n >> 16) & 255) / 255)
    local g = (((n >> 8) & 255) / 255)
    local b = ((n & 255) / 255)
    return {red = r, green = g, blue = b, alpha = a}
  end
  local function make_border_canvas(color, width, corner_radius)
    local outer_radius = (corner_radius + width)
    local canvas = hs.canvas.new({x = 0, y = 0, w = 100, h = 100})
    canvas:insertElement({type = "rectangle", action = "fill", fillColor = parse_argb_hex(color), roundedRectRadii = {xRadius = outer_radius, yRadius = outer_radius}})
    canvas:insertElement({type = "rectangle", action = "fill", fillColor = {red = 0, green = 0, blue = 0, alpha = 1}, compositeRule = "destinationOut", frame = {x = width, y = width, w = 80, h = 80}, roundedRectRadii = {xRadius = corner_radius, yRadius = corner_radius}})
    canvas:level(hs.canvas.windowLevels.floating)
    canvas:behavior((hs.canvas.windowBehaviors.canJoinAllSpaces | hs.canvas.windowBehaviors.stationary))
    return canvas
  end
  local window_border_type
  local function _321_(config)
    local cr = (config["corner-radius"] or 9)
    local active = make_border_canvas(config["active-color"], config.width, cr)
    local inactive = make_border_canvas(config["inactive-color"], config.width, cr)
    return {["active-canvas"] = active, ["inactive-canvas"] = inactive, ["active-window-id"] = nil, ["border-width"] = config.width, ["default-corner-radius"] = cr}
  end
  local function _322_(state)
    if state["active-canvas"] then
      state["active-canvas"]:delete()
    else
    end
    if state["inactive-canvas"] then
      return state["inactive-canvas"]:delete()
    else
      return nil
    end
  end
  window_border_type = make_component_type("component.type/window-border", "Draws colored borders around active and inactive windows", {traits = {"trait/has-canvas"}, ["start-fn"] = _321_, ["stop-fn"] = _322_})
  return {["window-border-type"] = window_border_type}
end
package.preload["components.url-dispatch"] = package.preload["components.url-dispatch"] or function(...)
  local _local_326_ = require("sheaf.component-registry")
  local make_component_type = _local_326_["make-component-type"]
  local _local_327_ = require("event_sources.url-decoders")
  local default_decoders = _local_327_["default-decoders"]
  local url_dispatch_type
  local function _328_(config)
    return {}
  end
  url_dispatch_type = make_component_type("component.type/url-dispatch", "URL dispatch handler - routes URLs through decoders and opens them", {sources = {{type = "event-source.type/url-handler", config = {decoders = default_decoders}, ["instance-name"] = "main", tags = {"tag/url-handler"}}}, ["start-fn"] = _328_})
  return {["url-dispatch-type"] = url_dispatch_type}
end
package.preload["components.url-routing-rules"] = package.preload["components.url-routing-rules"] or function(...)
  local _local_330_ = require("sheaf.component-registry")
  local make_component_type = _local_330_["make-component-type"]
  local url_routing_rules_type
  local function _331_(config)
    return {browsers = {{id = "zen", ["bundle-id"] = "app.zen-browser.zen"}, {id = "firefox", ["bundle-id"] = "org.mozilla.firefox"}, {id = "chrome", ["bundle-id"] = "com.google.Chrome"}, {id = "safari", ["bundle-id"] = "com.apple.Safari"}, {id = "brave", ["bundle-id"] = "com.brave.Browser"}, {id = "edge", ["bundle-id"] = "com.microsoft.edgemac"}, {id = "figma", ["bundle-id"] = "com.figma.Desktop"}, {id = "helium", ["bundle-id"] = "net.imput.helium"}, {id = "ora", ["bundle-id"] = "com.orabrowser.app"}, {id = "surf", ["bundle-id"] = "surf.deta"}}, fallback = {type = "choose", ["browser-ids"] = "all"}, rules = {{id = "file-url-default", match = {urls = {{scheme = "file"}}}, action = {type = "open-in-app", ["browser-id"] = "safari"}}}}
  end
  url_routing_rules_type = make_component_type("component.type/url-routing-rules", "URL routing configuration: browsers, fallback action, and ordered rules", {traits = {"trait/has-url-routing-rules"}, ["start-fn"] = _331_})
  return {["url-routing-rules-type"] = url_routing_rules_type}
end
package.preload["components.url-history"] = package.preload["components.url-history"] or function(...)
  local _local_333_ = require("sheaf.component-registry")
  local make_component_type = _local_333_["make-component-type"]
  local url_history_type
  local function _334_(config)
    return {history = {}}
  end
  url_history_type = make_component_type("component.type/url-history", "URL history - records dispatched URLs for browsing and recall", {traits = {"trait/has-url-history"}, sources = {{type = "event-source.type/hotkey", config = {mods = {"cmd", "ctrl"}, key = "l"}, ["instance-name"] = "history-hotkey", tags = {"tag/url-history-hotkey"}}}, ["start-fn"] = _334_})
  return {["url-history-type"] = url_history_type}
end
package.preload["components.window-state"] = package.preload["components.window-state"] or function(...)
  local _local_336_ = require("sheaf.component-registry")
  local make_component_type = _local_336_["make-component-type"]
  local window_state_type
  local function _337_(config)
    return {windows = {}, ["focused-window-id"] = nil}
  end
  window_state_type = make_component_type("component.type/window-state", "Tracks all visible windows \226\128\148 frame, app, fullscreen state", {traits = {"trait/has-window-state"}, ["start-fn"] = _337_})
  return {["window-state-type"] = window_state_type}
end
package.preload["components.paper-wm"] = package.preload["components.paper-wm"] or function(...)
  local _local_474_ = require("paper-wm")
  local make_runtime = _local_474_["make-runtime"]
  local stop_runtime_21 = _local_474_["stop-runtime!"]
  local _local_475_ = require("sheaf.component-registry")
  local make_component_type = _local_475_["make-component-type"]
  local sources = {}
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "left"}, ["instance-name"] = "focus-left", tags = {"tag/paper-wm-focus-left"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "right"}, ["instance-name"] = "focus-right", tags = {"tag/paper-wm-focus-right"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "up"}, ["instance-name"] = "focus-up", tags = {"tag/paper-wm-focus-up"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "down"}, ["instance-name"] = "focus-down", tags = {"tag/paper-wm-focus-down"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd", "shift"}, key = "left"}, ["instance-name"] = "swap-left", tags = {"tag/paper-wm-swap-left"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd", "shift"}, key = "right"}, ["instance-name"] = "swap-right", tags = {"tag/paper-wm-swap-right"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd", "shift"}, key = "up"}, ["instance-name"] = "swap-up", tags = {"tag/paper-wm-swap-up"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd", "shift"}, key = "down"}, ["instance-name"] = "swap-down", tags = {"tag/paper-wm-swap-down"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "c"}, ["instance-name"] = "center-window", tags = {"tag/paper-wm-center-window"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "f"}, ["instance-name"] = "set-full-width", tags = {"tag/paper-wm-set-full-width"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "r"}, ["instance-name"] = "cycle-width-up", tags = {"tag/paper-wm-cycle-width-up"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd", "shift"}, key = "r"}, ["instance-name"] = "cycle-height-up", tags = {"tag/paper-wm-cycle-height-up"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"ctrl", "alt", "cmd"}, key = "r"}, ["instance-name"] = "cycle-width-down", tags = {"tag/paper-wm-cycle-width-down"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"ctrl", "alt", "cmd", "shift"}, key = "r"}, ["instance-name"] = "cycle-height-down", tags = {"tag/paper-wm-cycle-height-down"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "i"}, ["instance-name"] = "slurp-window", tags = {"tag/paper-wm-slurp"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "o"}, ["instance-name"] = "barf-window", tags = {"tag/paper-wm-barf"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = ","}, ["instance-name"] = "prev-space", tags = {"tag/paper-wm-prev-space"}})
  table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = "."}, ["instance-name"] = "next-space", tags = {"tag/paper-wm-next-space"}})
  for i = 1, 9 do
    table.insert(sources, {type = "event-source.type/hotkey", config = {mods = {"alt", "cmd"}, key = tostring(i)}, ["instance-name"] = ("switch-to-space-" .. tostring(i)), tags = {("tag/paper-wm-switch-to-space-" .. tostring(i))}})
  end
  local paper_wm_type
  local _476_
  do
    local function _477_(state, config, instance_name)
      return {runtime = state}
    end
    table.insert(sources, {type = "event-source.type/paper-wm-outbox", ["instance-name"] = "outbox", tags = {"tag/paper-wm-outbox"}, ["config-fn"] = _477_})
    _476_ = sources
  end
  paper_wm_type = make_component_type("component.type/paper-wm", "PaperWM tiling window manager", {traits = {"trait/has-paper-wm-runtime", "trait/has-tiling-state"}, sources = _476_, ["start-fn"] = make_runtime, ["stop-fn"] = stop_runtime_21})
  return {["paper-wm-type"] = paper_wm_type}
end
package.preload["paper-wm"] = package.preload["paper-wm"] or function(...)
  local _local_367_ = require("paper-wm.layout")
  local empty_state = _local_367_["empty-state"]
  local layout_valid_3f = _local_367_["valid?"]
  local layout_slurp_window = _local_367_["slurp-window"]
  local layout_barf_window = _local_367_["barf-window"]
  local layout_swap_window = _local_367_["swap-window"]
  local focus_target = _local_367_["focus-target"]
  local set_focused_window = _local_367_["set-focused-window"]
  local _local_380_ = require("paper-wm.membership")
  local plan_membership = _local_380_["plan-membership"]
  local _local_384_ = require("paper-wm.frames")
  local plan_column = _local_384_["plan-column"]
  local _local_386_ = require("paper-wm.observations")
  local next_observation = _local_386_["next-observation"]
  local consume_latest = _local_386_["consume-latest"]
  local _local_391_ = require("paper-wm.space-conversation")
  local start_space_operation = _local_391_.start
  local advance_space_operation = _local_391_.advance
  local _local_392_ = require("lib.cljlib-shim")
  local some = _local_392_.some
  local Window = hs.window
  local Screen = hs.screen
  local Spaces = hs.spaces
  local Timer = hs.timer
  local Watcher = hs.uielement.watcher
  local Rect = hs.geometry.rect
  local default_config = {["window-gap"] = 35, ["screen-margin"] = 16, ["window-ratios"] = {0.421875, 0.84375}}
  local space_retry_min_delay = 0.05
  local function runtime_epoch(config)
    return (config.epoch or (Timer.absoluteTime and Timer.absoluteTime()) or (1000000 * Timer.secondsSinceEpoch()))
  end
  local function make_runtime(config)
    local config0 = (config or {})
    return {["active?"] = true, epoch = runtime_epoch(config0), config = {["window-gap"] = (config0["window-gap"] or default_config["window-gap"]), ["screen-margin"] = (config0["screen-margin"] or default_config["screen-margin"]), ["window-ratios"] = (config0["window-ratios"] or default_config["window-ratios"])}, ["tiling-state"] = empty_state(), resources = {windows = {}, ["ui-watchers"] = {}, ["watcher-generations"] = {}, ["watcher-restart-timers"] = {}, ["frame-observations"] = {sequences = {}, latest = {}, timers = {}}, outbox = nil, ["space-focus"] = {["next-generation"] = 0, active = nil}, ["space-focus-timer"] = nil}, ["last-reconcile-report"] = nil}
  end
  local function copy_table(source)
    local result = {}
    for key, value in pairs(source) do
      local _393_
      if ("table" == type(value)) then
        _393_ = copy_table(value)
      else
        _393_ = value
      end
      result[key] = _393_
    end
    return result
  end
  local function table_count(source)
    local count = 0
    for _, _0 in pairs((source or {})) do
      count = (count + 1)
    end
    return count
  end
  local function diagnostic_snapshot(runtime)
    return {["active?"] = runtime["active?"], epoch = runtime.epoch, ["window-list"] = copy_table(runtime["tiling-state"].spaces), ["index-table"] = copy_table(runtime["tiling-state"].index), ["focused-window-id"] = runtime["tiling-state"]["focused-window-id"], ["last-reconcile-report"] = copy_table((runtime["last-reconcile-report"] or {})), resources = {["ui-watcher-count"] = table_count(runtime.resources["ui-watchers"]), ["watcher-restart-timer-count"] = table_count(runtime.resources["watcher-restart-timers"]), ["frame-timer-count"] = table_count(runtime.resources["frame-observations"].timers), ["space-focus-timer?"] = (nil ~= runtime.resources["space-focus-timer"])}}
  end
  local function invariant_report(runtime)
    local ok, reason = layout_valid_3f(runtime["tiling-state"])
    return {["ok?"] = ok, reason = reason, epoch = runtime.epoch}
  end
  local function commit_state_21(runtime, next_state)
    local ok, reason = layout_valid_3f(next_state)
    if not ok then
      error(("PaperWM layout invariant failed: " .. tostring(reason)))
    else
    end
    runtime["tiling-state"] = next_state
    return next_state
  end
  local function resolve_window(window_id)
    local ok, window = pcall(Window.get, window_id)
    if ok then
      return window
    else
      return nil
    end
  end
  local function get_space(index)
    local layout = Spaces.allSpaces()
    local remaining = index
    local result = nil
    for _, screen in ipairs(Screen.allScreens()) do
      if result then break end
      local screen_spaces = layout[screen:getUUID()]
      if (remaining <= #screen_spaces) then
        result = screen_spaces[remaining]
      else
        remaining = (remaining - #screen_spaces)
      end
    end
    return result
  end
  local function space_index_after_direction(direction)
    local offset
    if (direction == "left") then
      offset = -1
    elseif (direction == "right") then
      offset = 1
    else
      offset = nil
    end
    if (nil == offset) then
      return nil
    else
    end
    local focused_space = Spaces.focusedSpace()
    local layout = Spaces.allSpaces()
    local focused_index = -1
    local count = 0
    for _, screen in ipairs(Screen.allScreens()) do
      local screen_spaces = layout[screen:getUUID()]
      if (focused_index < 0) then
        for index, space_id in ipairs(screen_spaces) do
          if (focused_space == space_id) then
            focused_index = (count + index)
            break
          else
          end
        end
      else
      end
      count = (count + #screen_spaces)
    end
    if ((focused_index >= 0) and (count > 0)) then
      return ((((focused_index - 1) + offset) % count) + 1)
    else
      return nil
    end
  end
  local function live_frame(window)
    local ok, frame
    local function _403_()
      return window:frame()
    end
    ok, frame = pcall(_403_)
    if (ok and frame and (frame.w > 0) and (frame.h > 0)) then
      return frame
    else
      return nil
    end
  end
  local function get_first_visible_window(runtime, columns, screen)
    local left_edge = screen:frame().x
    local result, result_frame = nil
    for _, window_ids in ipairs((columns or {})) do
      if result then break end
      local window = runtime.resources.windows[window_ids[1]]
      local frame = (window and live_frame(window))
      if (frame and (frame.x >= left_edge)) then
        result, result_frame = window, frame
      else
      end
    end
    return result, result_frame
  end
  local function get_column(runtime, space, column)
    local result = {}
    for _, window_id in ipairs((runtime["tiling-state"].spaces[space] or {})[column]) do
      local window = runtime.resources.windows[window_id]
      local frame = (window and live_frame(window))
      if frame then
        table.insert(result, {window = window, frame = frame})
      else
      end
    end
    return result
  end
  local function get_canvas(runtime, screen)
    local frame = screen:frame()
    local gap = runtime.config["window-gap"]
    return Rect((frame.x + gap), (frame.y + gap), (frame.w - (2 * gap)), (frame.h - (2 * gap)))
  end
  local function move_window_21(runtime, window, frame, _3fcurrent)
    local id = window:id()
    local watcher = runtime.resources["ui-watchers"][id]
    local current = (_3fcurrent or live_frame(window))
    if ((nil == watcher) or (nil == current) or (frame == current)) then
      return
    else
    end
    do
      local pending = runtime.resources["watcher-restart-timers"][id]
      if pending then
        pending:stop()
      else
      end
    end
    watcher:stop()
    local function _409_()
      return window:setFrame(frame)
    end
    pcall(_409_)
    local generation = runtime.resources["watcher-generations"][id]
    local function _410_()
      runtime.resources["watcher-restart-timers"][id] = nil
      local live_watcher = runtime.resources["ui-watchers"][id]
      if (runtime["active?"] and live_watcher and (generation == runtime.resources["watcher-generations"][id])) then
        return live_watcher:start({Watcher.windowMoved, Watcher.windowResized})
      else
        return nil
      end
    end
    runtime.resources["watcher-restart-timers"][id] = Timer.doAfter((Window.animationDuration + 0.02), _410_)
    return nil
  end
  local function tile_column_21(runtime, column, bounds, height, width, anchor_id, anchor_height)
    local members
    do
      local tbl_21_ = {}
      for _, member in ipairs(column) do
        local k_22_, v_23_ = member.window:id(), member
        if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
          tbl_21_[k_22_] = v_23_
        else
        end
      end
      members = tbl_21_
    end
    local entries
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for _, member in ipairs(column) do
        local val_28_ = {["window-id"] = member.window:id(), frame = member.frame}
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      entries = tbl_26_
    end
    local plan, column_width = plan_column(entries, bounds, {gap = runtime.config["window-gap"], height = height, width = width, ["anchor-window-id"] = anchor_id, ["anchor-height"] = anchor_height})
    for _, intent in ipairs(plan) do
      local member = members[intent["window-id"]]
      move_window_21(runtime, member.window, intent.frame, member.frame)
    end
    return column_width
  end
  local function tracked_window_on_space(runtime, window_id, space)
    local entry = (window_id and runtime["tiling-state"].index[window_id])
    if (entry and (entry.space == space)) then
      return runtime.resources.windows[window_id]
    else
      return nil
    end
  end
  local function live_tracked_window(runtime, window_id, space)
    local window = tracked_window_on_space(runtime, window_id, space)
    local frame = (window and live_frame(window))
    if frame then
      return window, frame
    else
      return nil
    end
  end
  local function copy_frame(frame)
    return Rect(frame.x, frame.y, frame.w, frame.h)
  end
  local function resolve_anchor(runtime, space, screen, _3fanchor)
    local explicit = (_3fanchor and _3fanchor.frame and live_tracked_window(runtime, _3fanchor["window-id"], space))
    local focused = Window.focusedWindow()
    local focused_window, focused_frame
    if (not explicit and focused) then
      focused_window, focused_frame = live_tracked_window(runtime, focused:id(), space)
    else
      focused_window, focused_frame = nil
    end
    if explicit then
      return explicit, copy_frame(_3fanchor.frame)
    elseif focused_window then
      return focused_window, copy_frame(focused_frame)
    else
      local window, frame = get_first_visible_window(runtime, runtime["tiling-state"].spaces[space], screen)
      if window then
        return window, copy_frame(frame)
      else
        return nil
      end
    end
  end
  local function tile_space_21(runtime, space, _3fanchor)
    if ((nil == space) or (Spaces.spaceType(space) ~= "user")) then
      return
    else
    end
    local screen = Screen(Spaces.spaceDisplay(space))
    if (nil == screen) then
      return
    else
    end
    local anchor, frame = resolve_anchor(runtime, space, screen, _3fanchor)
    if (nil == anchor) then
      return
    else
    end
    local anchor_index = runtime["tiling-state"].index[anchor:id()]
    local screen_frame = screen:frame()
    local left_margin = (screen_frame.x + runtime.config["screen-margin"])
    local right_margin = (screen_frame.x2 - runtime.config["screen-margin"])
    local canvas = get_canvas(runtime, screen)
    frame.x = math.max(frame.x, canvas.x)
    frame.w = math.min(frame.w, canvas.w)
    frame.h = math.min(frame.h, canvas.h)
    if (frame.x2 > canvas.x2) then
      frame.x = (canvas.x2 - frame.w)
    else
    end
    local column = get_column(runtime, space, anchor_index.col)
    if (0 == #column) then
      return
    else
    end
    if (1 == #column) then
      frame.y = canvas.y
      frame.h = canvas.h
      move_window_21(runtime, anchor, frame)
    else
      local remaining = (#column - 1)
      local height = math.floor((math.max(0, (canvas.h - frame.h - (remaining * runtime.config["window-gap"]))) / remaining))
      tile_column_21(runtime, column, {x = frame.x, x2 = nil, y = canvas.y, y2 = canvas.y2}, height, frame.w, anchor:id(), frame.h)
    end
    local x = math.min((frame.x2 + runtime.config["window-gap"]), right_margin)
    for column_index = (anchor_index.col + 1), #runtime["tiling-state"].spaces[space] do
      local width = tile_column_21(runtime, get_column(runtime, space, column_index), {x = x, x2 = nil, y = canvas.y, y2 = canvas.y2})
      if width then
        x = math.min((x + width + runtime.config["window-gap"]), right_margin)
      else
      end
    end
    local x2 = math.max((frame.x - runtime.config["window-gap"]), left_margin)
    for column_index = (anchor_index.col - 1), 1, -1 do
      local width = tile_column_21(runtime, get_column(runtime, space, column_index), {x = nil, x2 = x2, y = canvas.y, y2 = canvas.y2})
      if width then
        x2 = math.max((x2 - width - runtime.config["window-gap"]), left_margin)
      else
      end
    end
    return nil
  end
  local function emit_21(runtime, event_name, data)
    local emit = runtime.resources.outbox
    if (runtime["active?"] and emit) then
      return emit(event_name, data)
    else
      return nil
    end
  end
  local function observe_frame_21(runtime, window_id, event_kind, frame, generation)
    local observations = runtime.resources["frame-observations"]
    next_observation(observations, window_id, event_kind, frame, generation)
    if (nil == observations.timers[window_id]) then
      local function _428_()
        observations.timers[window_id] = nil
        local latest = observations.latest[window_id]
        if latest then
          return emit_21(runtime, "paper-wm.events/frame-observed", latest)
        else
          return nil
        end
      end
      observations.timers[window_id] = Timer.doAfter((1 / 60), _428_)
      return nil
    else
      return nil
    end
  end
  local function attach_window_21(runtime, window_id)
    local window = resolve_window(window_id)
    if window then
      runtime.resources.windows[window_id] = window
      if (nil == runtime.resources["ui-watchers"][window_id]) then
        local generation = (1 + (runtime.resources["watcher-generations"][window_id] or 0))
        local watcher
        local function _431_(observed_window, event_kind)
          local ok, frame
          local function _432_()
            return observed_window:frame()
          end
          ok, frame = pcall(_432_)
          if (runtime["active?"] and ok) then
            return observe_frame_21(runtime, window_id, tostring(event_kind), frame, generation)
          else
            return nil
          end
        end
        watcher = window:newWatcher(_431_)
        runtime.resources["watcher-generations"][window_id] = generation
        watcher:start({Watcher.windowMoved, Watcher.windowResized})
        runtime.resources["ui-watchers"][window_id] = watcher
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local function stop_handle_21(handle)
    if handle then
      return handle:stop()
    else
      return nil
    end
  end
  local function detach_window_21(runtime, window_id)
    local observations = runtime.resources["frame-observations"]
    stop_handle_21(runtime.resources["ui-watchers"][window_id])
    stop_handle_21(runtime.resources["watcher-restart-timers"][window_id])
    stop_handle_21(observations.timers[window_id])
    runtime.resources["ui-watchers"][window_id] = nil
    runtime.resources["watcher-restart-timers"][window_id] = nil
    observations.timers[window_id] = nil
    observations.latest[window_id] = nil
    observations.sequences[window_id] = nil
    runtime.resources.windows[window_id] = nil
    return nil
  end
  local function apply_membership_21(runtime, facts, opts)
    local plan
    local function _437_(_241)
      return (nil ~= resolve_window(_241))
    end
    plan = plan_membership(runtime["tiling-state"], facts, {["live?"] = _437_, ["observed-spaces"] = opts["observed-spaces"]})
    commit_state_21(runtime, plan.state)
    for _, window_id in ipairs(plan.detach) do
      detach_window_21(runtime, window_id)
    end
    for _, window_id in ipairs(plan.attach) do
      attach_window_21(runtime, window_id)
    end
    for _, space in ipairs(plan["touched-spaces"]) do
      if runtime["tiling-state"].spaces[space] then
        tile_space_21(runtime, space, opts.anchor)
      else
      end
    end
    return plan
  end
  local function reconcile_window_fact_21(runtime, fact, opts)
    if ((nil == opts["runtime-epoch"]) or (opts["runtime-epoch"] == runtime.epoch)) then
      apply_membership_21(runtime, {fact}, {})
    else
    end
    return runtime
  end
  local function reconcile_layout_21(runtime, window_facts, observed_spaces)
    local plan = apply_membership_21(runtime, window_facts, {["observed-spaces"] = (observed_spaces or {})})
    runtime["last-reconcile-report"] = plan.report
    return runtime, plan.report
  end
  local function record_focus_21(runtime, fact)
    do
      local anchor = {["window-id"] = fact["window-id"], frame = fact.frame}
      local plan
      if fact["space-id"] then
        plan = apply_membership_21(runtime, {fact}, {anchor = anchor})
      else
        plan = {["touched-spaces"] = {}}
      end
      local entry = runtime["tiling-state"].index[fact["window-id"]]
      if entry then
        commit_state_21(runtime, set_focused_window(runtime["tiling-state"], fact["window-id"]))
        local function _441_(_241)
          return (_241 == entry.space)
        end
        if not some(_441_, plan["touched-spaces"]) then
          tile_space_21(runtime, entry.space, anchor)
        else
        end
      else
      end
    end
    return runtime
  end
  local function retile_observed_frame_21(runtime, params)
    do
      local entry = runtime["tiling-state"].index[params["window-id"]]
      local current_3f = (params.generation == runtime.resources["watcher-generations"][params["window-id"]])
      if (entry and current_3f and consume_latest(runtime.resources["frame-observations"], params["window-id"], params.generation, params.sequence)) then
        tile_space_21(runtime, entry.space, {["window-id"] = params["window-id"], frame = params.frame})
      else
      end
    end
    return runtime
  end
  local function focused_window(runtime)
    local focused = Window.focusedWindow()
    local entry = (focused and runtime["tiling-state"].index[focused:id()])
    if entry then
      return focused, entry
    else
      return nil
    end
  end
  local function retile_around_21(runtime, focused, entry, frame)
    return tile_space_21(runtime, entry.space, {["window-id"] = focused:id(), frame = frame})
  end
  local function focus_window_21(runtime, direction)
    local focused = focused_window(runtime)
    if (nil == focused) then
      return runtime
    else
    end
    do
      local target_id = focus_target(runtime["tiling-state"], focused:id(), direction)
      local target = runtime.resources.windows[target_id]
      if target then
        target:focus()
      else
      end
    end
    return runtime
  end
  local function swap_windows_21(runtime, direction)
    local focused, entry = focused_window(runtime)
    if (nil == focused) then
      return runtime
    else
    end
    do
      local next_state = layout_swap_window(runtime["tiling-state"], focused:id(), direction)
      if (next_state ~= runtime["tiling-state"]) then
        commit_state_21(runtime, next_state)
        retile_around_21(runtime, focused, entry, focused:frame())
      else
      end
    end
    return runtime
  end
  local function center_window_21(runtime)
    local focused, entry = focused_window(runtime)
    if (nil == focused) then
      return runtime
    else
    end
    do
      local frame = focused:frame()
      local screen_frame = focused:screen():frame()
      frame.x = ((screen_frame.x + math.floor((screen_frame.w / 2))) - math.floor((frame.w / 2)))
      retile_around_21(runtime, focused, entry, frame)
    end
    return runtime
  end
  local function set_window_full_width_21(runtime)
    local focused, entry = focused_window(runtime)
    if (nil == focused) then
      return runtime
    else
    end
    do
      local canvas = get_canvas(runtime, focused:screen())
      local frame = focused:frame()
      frame.x = canvas.x
      frame.w = canvas.w
      retile_around_21(runtime, focused, entry, frame)
    end
    return runtime
  end
  local function cycle_value(candidates, current, direction)
    if (direction == "ascending") then
      local function _452_(_241)
        return ((_241 > (current + 10)) and _241)
      end
      return (some(_452_, candidates) or candidates[1])
    else
      local result = candidates[#candidates]
      for index = #candidates, 1, -1 do
        if (candidates[index] < (current - 10)) then
          result = candidates[index]
          break
        else
        end
      end
      return result
    end
  end
  local function cycle_window_size_21(runtime, dimension, direction)
    local focused, entry = focused_window(runtime)
    if (nil == focused) then
      return runtime
    else
    end
    do
      local canvas = get_canvas(runtime, focused:screen())
      local frame = focused:frame()
      local sizes
      do
        local tbl_26_ = {}
        local i_27_ = 0
        for _, ratio in ipairs(runtime.config["window-ratios"]) do
          local val_28_
          local _456_
          if (dimension == "width") then
            _456_ = canvas.w
          else
            _456_ = canvas.h
          end
          val_28_ = ((ratio * (_456_ + runtime.config["window-gap"])) - runtime.config["window-gap"])
          if (nil ~= val_28_) then
            i_27_ = (i_27_ + 1)
            tbl_26_[i_27_] = val_28_
          else
          end
        end
        sizes = tbl_26_
      end
      if (dimension == "width") then
        local size = cycle_value(sizes, frame.w, direction)
        frame.x = (frame.x + math.floor(((frame.w - size) / 2)))
        frame.w = size
      else
        local size = cycle_value(sizes, frame.h, direction)
        frame.y = math.max(canvas.y, (frame.y + math.floor(((frame.h - size) / 2))))
        frame.h = size
        frame.y = (frame.y - math.max(0, (frame.y2 - canvas.y2)))
      end
      retile_around_21(runtime, focused, entry, frame)
    end
    return runtime
  end
  local function slurp_window_21(runtime)
    local focused, entry = focused_window(runtime)
    if (nil == focused) then
      return runtime
    else
    end
    do
      local next_state = layout_slurp_window(runtime["tiling-state"], focused:id())
      if (next_state ~= runtime["tiling-state"]) then
        commit_state_21(runtime, next_state)
        retile_around_21(runtime, focused, entry, focused:frame())
      else
      end
    end
    return runtime
  end
  local function barf_window_21(runtime)
    local focused, entry = focused_window(runtime)
    if (nil == focused) then
      return runtime
    else
    end
    do
      local next_state = layout_barf_window(runtime["tiling-state"], focused:id())
      if (next_state ~= runtime["tiling-state"]) then
        commit_state_21(runtime, next_state)
        retile_around_21(runtime, focused, entry, focused:frame())
      else
      end
    end
    return runtime
  end
  local function schedule_space_retry_21(runtime, generation)
    stop_handle_21(runtime.resources["space-focus-timer"])
    local function _464_()
      runtime.resources["space-focus-timer"] = nil
      return emit_21(runtime, "paper-wm.events/space-focus-retry", {generation = generation})
    end
    runtime.resources["space-focus-timer"] = Timer.doAfter(math.max(Window.animationDuration, space_retry_min_delay), _464_)
    return nil
  end
  local function attempt_space_focus_21(runtime, operation)
    if operation["target-window-id"] then
      local target = runtime.resources.windows[operation["target-window-id"]]
      if target then
        return target:focus()
      else
        return nil
      end
    else
      local screen = Screen(Spaces.spaceDisplay(operation["target-space"]))
      if screen then
        local point = screen:frame()
        point.x = (point.x + math.floor((point.w / 2)))
        point.y = (point.y - 4)
        return hs.eventtap.leftClick(point)
      else
        return nil
      end
    end
  end
  local function start_space_focus_21(runtime, index)
    do
      local space = get_space(index)
      if (nil == space) then
        return runtime
      else
      end
      local screen = Screen(Spaces.spaceDisplay(space))
      local target = (screen and get_first_visible_window(runtime, runtime["tiling-state"].spaces[space], screen))
      local operation = start_space_operation(runtime.resources["space-focus"], space, (target and target:id()), Timer.secondsSinceEpoch(), 4)
      Spaces.gotoSpace(space)
      attempt_space_focus_21(runtime, operation)
      schedule_space_retry_21(runtime, operation.generation)
    end
    return runtime
  end
  local function retry_space_focus_21(runtime, generation)
    do
      local operation = runtime.resources["space-focus"].active
      if (nil == operation) then
        return runtime
      else
      end
      local target = runtime.resources.windows[operation["target-window-id"]]
      local result = advance_space_operation(runtime.resources["space-focus"], generation, Timer.secondsSinceEpoch(), (Spaces.focusedSpace() == operation["target-space"]), ((nil == operation["target-window-id"]) or (Window.focusedWindow() == target)))
      if (result.outcome == "retry") then
        if (0 == result.operation["stable-count"]) then
          attempt_space_focus_21(runtime, result.operation)
        else
        end
        schedule_space_retry_21(runtime, generation)
      elseif (result.outcome == "complete") then
        local screen = Screen(Spaces.spaceDisplay(result.operation["target-space"]))
        if screen then
          hs.mouse.absolutePosition(hs.geometry.rectMidPoint(screen:frame()))
        else
        end
      else
      end
    end
    return runtime
  end
  local function stop_runtime_21(runtime)
    runtime["active?"] = false
    for _, watcher in pairs(runtime.resources["ui-watchers"]) do
      watcher:stop()
    end
    for _, timer in pairs(runtime.resources["watcher-restart-timers"]) do
      timer:stop()
    end
    for _, timer in pairs(runtime.resources["frame-observations"].timers) do
      timer:stop()
    end
    if runtime.resources["space-focus-timer"] then
      runtime.resources["space-focus-timer"]:stop()
    else
    end
    runtime.resources["windows"] = {}
    runtime.resources["ui-watchers"] = {}
    runtime.resources["watcher-restart-timers"] = {}
    runtime.resources["frame-observations"]["timers"] = {}
    runtime.resources["space-focus-timer"] = nil
    return nil
  end
  return {["default-config"] = default_config, ["make-runtime"] = make_runtime, ["stop-runtime!"] = stop_runtime_21, ["diagnostic-snapshot"] = diagnostic_snapshot, ["invariant-report"] = invariant_report, ["reconcile-layout!"] = reconcile_layout_21, ["reconcile-window-fact!"] = reconcile_window_fact_21, ["record-focus!"] = record_focus_21, ["retile-observed-frame!"] = retile_observed_frame_21, ["space-index-after-direction"] = space_index_after_direction, ["start-space-focus!"] = start_space_focus_21, ["retry-space-focus!"] = retry_space_focus_21, ["focus-window!"] = focus_window_21, ["swap-windows!"] = swap_windows_21, ["center-window!"] = center_window_21, ["set-window-full-width!"] = set_window_full_width_21, ["cycle-window-size!"] = cycle_window_size_21, ["slurp-window!"] = slurp_window_21, ["barf-window!"] = barf_window_21}
end
package.preload["paper-wm.layout"] = package.preload["paper-wm.layout"] or function(...)
  local function empty_state()
    return {spaces = {}, index = {}, ["focused-window-id"] = nil}
  end
  local function copy_spaces(spaces)
    local result = {}
    for space, columns in pairs(spaces) do
      local copied_columns = {}
      for _, column in ipairs(columns) do
        local copied_column = {}
        for _0, window_id in ipairs(column) do
          table.insert(copied_column, window_id)
        end
        table.insert(copied_columns, copied_column)
      end
      result[space] = copied_columns
    end
    return result
  end
  local function copy_state(state)
    return {spaces = copy_spaces(state.spaces), index = {}, ["focused-window-id"] = state["focused-window-id"]}
  end
  local function rebuild_index_21(state)
    local index = {}
    for space, columns in pairs(state.spaces) do
      for col, column in ipairs(columns) do
        for row, window_id in ipairs(column) do
          index[window_id] = {space = space, col = col, row = row}
        end
      end
    end
    state["index"] = index
    return state
  end
  local function valid_3f(state)
    local seen = {}
    for space, columns in pairs((state.spaces or {})) do
      for col, column in ipairs(columns) do
        if (0 == #column) then
          return false, 'empty-column'
        else
        end
        for row, window_id in ipairs(column) do
          if seen[window_id] then
            return false, 'duplicate-window-id'
          else
          end
          seen[window_id] = true
          local entry = (state.index or {})[window_id]
          if ((nil == entry) or (space ~= entry.space) or (col ~= entry.col) or (row ~= entry.row)) then
            return false, 'index-mismatch'
          else
          end
        end
      end
    end
    for window_id, _ in pairs((state.index or {})) do
      if not seen[window_id] then
        return false, 'extra-index-entry'
      else
      end
    end
    if (state["focused-window-id"] and not seen[state["focused-window-id"]]) then
      return false, 'missing-focused-window'
    else
    end
    return true
  end
  local function add_window(state, window_id, space, column)
    if state.index[window_id] then
      return state
    else
    end
    local next_state = copy_state(state)
    local columns = (next_state.spaces[space] or {})
    local insertion_column = math.max(1, math.min(column, (#columns + 1)))
    next_state.spaces[space] = columns
    table.insert(columns, insertion_column, {window_id})
    return rebuild_index_21(next_state)
  end
  local function remove_window(state, window_id)
    local entry = state.index[window_id]
    if (nil == entry) then
      return state
    else
    end
    local next_state = copy_state(state)
    local columns = next_state.spaces[entry.space]
    local column = columns[entry.col]
    table.remove(column, entry.row)
    if (0 == #column) then
      table.remove(columns, entry.col)
    else
    end
    if (0 == #columns) then
      next_state.spaces[entry.space] = nil
    else
    end
    if (window_id == next_state["focused-window-id"]) then
      next_state["focused-window-id"] = nil
    else
    end
    return rebuild_index_21(next_state)
  end
  local function move_window(state, window_id, space, column)
    if (nil == state.index[window_id]) then
      return state
    else
    end
    local focused = state["focused-window-id"]
    local moved = add_window(remove_window(state, window_id), window_id, space, column)
    moved["focused-window-id"] = focused
    return moved
  end
  local function slurp_window(state, window_id)
    local entry = state.index[window_id]
    if ((nil == entry) or (entry.col <= 1)) then
      return state
    else
    end
    local next_state = copy_state(state)
    local columns = next_state.spaces[entry.space]
    local source = columns[entry.col]
    local target = columns[(entry.col - 1)]
    table.remove(source, entry.row)
    if (0 == #source) then
      table.remove(columns, entry.col)
    else
    end
    table.insert(target, window_id)
    return rebuild_index_21(next_state)
  end
  local function barf_window(state, window_id)
    local entry = state.index[window_id]
    if (nil == entry) then
      return state
    else
    end
    if (#state.spaces[entry.space][entry.col] <= 1) then
      return state
    else
    end
    local next_state = copy_state(state)
    local columns = next_state.spaces[entry.space]
    local source = columns[entry.col]
    table.remove(source, entry.row)
    table.insert(columns, (entry.col + 1), {window_id})
    return rebuild_index_21(next_state)
  end
  local function swap_window(state, window_id, direction)
    local entry = state.index[window_id]
    if (nil == entry) then
      return state
    else
    end
    local next_state = copy_state(state)
    local columns = next_state.spaces[entry.space]
    if ((direction == "left") or (direction == "right")) then
      local offset
      if (direction == "left") then
        offset = -1
      else
        offset = 1
      end
      local target_col = (entry.col + offset)
      if ((target_col < 1) or (target_col > #columns)) then
        return state
      else
      end
      local source = columns[entry.col]
      columns[entry.col] = columns[target_col]
      columns[target_col] = source
    elseif ((direction == "up") or (direction == "down")) then
      local column = columns[entry.col]
      local offset
      if (direction == "up") then
        offset = -1
      else
        offset = 1
      end
      local target_row = (entry.row + offset)
      if ((target_row < 1) or (target_row > #column)) then
        return state
      else
      end
      local target_id = column[target_row]
      column[target_row] = window_id
      column[entry.row] = target_id
    else
      return state
    end
    return rebuild_index_21(next_state)
  end
  local function focus_target(state, window_id, direction)
    local entry = state.index[window_id]
    if (nil == entry) then
      return nil
    else
    end
    if ((direction == "left") or (direction == "right")) then
      local offset
      if (direction == "left") then
        offset = -1
      else
        offset = 1
      end
      local column = state.spaces[entry.space][(entry.col + offset)]
      if column then
        for row = entry.row, 1, -1 do
          local target = column[row]
          if target then
            return target
          else
          end
        end
        return nil
      else
        return nil
      end
    elseif ((direction == "up") or (direction == "down")) then
      local offset
      if (direction == "up") then
        offset = -1
      else
        offset = 1
      end
      return state.spaces[entry.space][entry.col][(entry.row + offset)]
    else
      return nil
    end
  end
  local function set_focused_window(state, window_id)
    if (window_id and (nil == state.index[window_id])) then
      return state
    else
    end
    local next_state = copy_state(state)
    next_state["focused-window-id"] = window_id
    return rebuild_index_21(next_state)
  end
  return {["empty-state"] = empty_state, ["valid?"] = valid_3f, ["add-window"] = add_window, ["remove-window"] = remove_window, ["move-window"] = move_window, ["slurp-window"] = slurp_window, ["barf-window"] = barf_window, ["swap-window"] = swap_window, ["focus-target"] = focus_target, ["set-focused-window"] = set_focused_window}
end
package.preload["paper-wm.membership"] = package.preload["paper-wm.membership"] or function(...)
  local _local_368_ = require("paper-wm.layout")
  local add_window = _local_368_["add-window"]
  local remove_window = _local_368_["remove-window"]
  local move_window = _local_368_["move-window"]
  local _local_369_ = require("paper-wm.eligibility")
  local eligible_3f = _local_369_["eligible?"]
  local function append_column(state, space)
    return (1 + #(state.spaces[space] or {}))
  end
  local function sorted_keys(members)
    local keys
    do
      local tbl_26_ = {}
      local i_27_ = 0
      for key, _ in pairs(members) do
        local val_28_ = key
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      keys = tbl_26_
    end
    table.sort(keys)
    return keys
  end
  local function membership_effects(before, after)
    local attach = {}
    local detach = {}
    local touched = {}
    for window_id, entry in pairs(after.index) do
      local prior = before.index[window_id]
      if ((nil == prior) or (prior.space ~= entry.space)) then
        attach[window_id] = true
        touched[entry.space] = true
        if prior then
          touched[prior.space] = true
        else
        end
      else
      end
    end
    for window_id, prior in pairs(before.index) do
      if (nil == after.index[window_id]) then
        detach[window_id] = true
        touched[prior.space] = true
      else
      end
    end
    return {attach = sorted_keys(attach), detach = sorted_keys(detach), ["touched-spaces"] = sorted_keys(touched)}
  end
  local function plan_membership(state, facts, opts)
    local next_state = state
    local report = {added = {}, moved = {}, removed = {}, rejected = {}}
    local seen = {}
    local remove_21
    local function _374_(window_id)
      next_state = remove_window(next_state, window_id)
      return table.insert(report.removed, window_id)
    end
    remove_21 = _374_
    for _, fact in ipairs(facts) do
      local window_id = fact["window-id"]
      local entry = next_state.index[window_id]
      seen[window_id] = true
      if (eligible_3f(fact) and (entry or opts["live?"](window_id))) then
        if (nil == entry) then
          next_state = add_window(next_state, window_id, fact["space-id"], append_column(next_state, fact["space-id"]))
          table.insert(report.added, window_id)
        elseif (entry.space ~= fact["space-id"]) then
          next_state = move_window(next_state, window_id, fact["space-id"], append_column(next_state, fact["space-id"]))
          table.insert(report.moved, window_id)
        else
        end
      elseif entry then
        remove_21(window_id)
      else
        table.insert(report.rejected, window_id)
      end
    end
    if opts["observed-spaces"] then
      local observed
      do
        local tbl_21_ = {}
        for _, space in ipairs(opts["observed-spaces"]) do
          local k_22_, v_23_ = space, true
          if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
            tbl_21_[k_22_] = v_23_
          else
          end
        end
        observed = tbl_21_
      end
      for _, window_id in ipairs(sorted_keys(next_state.index)) do
        if ((nil == seen[window_id]) and observed[next_state.index[window_id].space]) then
          remove_21(window_id)
        else
        end
      end
    else
    end
    local effects = membership_effects(state, next_state)
    return {state = next_state, report = report, attach = effects.attach, detach = effects.detach, ["touched-spaces"] = effects["touched-spaces"]}
  end
  return {["plan-membership"] = plan_membership}
end
package.preload["paper-wm.eligibility"] = package.preload["paper-wm.eligibility"] or function(...)
  local function eligible_3f(facts)
    return not not (facts and facts["window-id"] and (facts.subrole == "AXStandardWindow") and (facts["has-titlebar"] == true) and (facts.visible == true) and (facts.fullscreen == false) and (facts["tab-count"] == 0) and (nil ~= facts["space-id"]))
  end
  return {["eligible?"] = eligible_3f}
end
package.preload["paper-wm.frames"] = package.preload["paper-wm.frames"] or function(...)
  local function copy_frame(frame)
    return {x = frame.x, y = frame.y, w = frame.w, h = frame.h, x2 = frame.x2, y2 = frame.y2}
  end
  local function update_edges_21(frame)
    frame["x2"] = (frame.x + frame.w)
    frame["y2"] = (frame.y + frame.h)
    return frame
  end
  local function plan_column(entries, bounds, opts)
    local plan = {}
    local gap = (opts.gap or 0)
    local first_entry = entries[1]
    local column_width = (opts.width or (first_entry and first_entry.frame.w))
    local y_start = bounds.y
    for _, entry in ipairs(entries) do
      local frame = copy_frame(entry.frame)
      local height
      if (opts["anchor-window-id"] and opts["anchor-height"] and (entry["window-id"] == opts["anchor-window-id"])) then
        height = opts["anchor-height"]
      else
        height = (opts.height or frame.h)
      end
      if bounds.x then
        frame.x = bounds.x
      else
        frame.x = (bounds.x2 - column_width)
      end
      frame.y = y_start
      frame.w = column_width
      frame.h = math.min(height, (bounds.y2 - y_start))
      update_edges_21(frame)
      table.insert(plan, {["window-id"] = entry["window-id"], frame = frame})
      y_start = math.min((frame.y2 + gap), bounds.y2)
    end
    do
      local last_intent = plan[#plan]
      if (last_intent and (last_intent.frame.y2 ~= bounds.y2)) then
        last_intent.frame.h = (bounds.y2 - last_intent.frame.y)
        update_edges_21(last_intent.frame)
      else
      end
    end
    return plan, column_width
  end
  return {["plan-column"] = plan_column}
end
package.preload["paper-wm.observations"] = package.preload["paper-wm.observations"] or function(...)
  local function next_observation(state, window_id, event_kind, frame, generation)
    local sequence = (1 + (state.sequences[window_id] or 0))
    local observation = {["window-id"] = window_id, ["event-kind"] = event_kind, frame = frame, generation = generation, sequence = sequence}
    state.sequences[window_id] = sequence
    state.latest[window_id] = observation
    return observation
  end
  local function consume_latest(state, window_id, generation, sequence)
    local observation = state.latest[window_id]
    if (observation and (generation == observation.generation) and (sequence == observation.sequence)) then
      state.latest[window_id] = nil
      return observation
    else
      return nil
    end
  end
  return {["next-observation"] = next_observation, ["consume-latest"] = consume_latest}
end
package.preload["paper-wm.space-conversation"] = package.preload["paper-wm.space-conversation"] or function(...)
  local function start(state, target_space, target_window_id, now, timeout)
    local generation = (1 + state["next-generation"])
    local operation = {generation = generation, ["target-space"] = target_space, ["target-window-id"] = target_window_id, attempt = 0, ["stable-count"] = 0, deadline = (now + timeout)}
    state["next-generation"] = generation
    state["active"] = operation
    return operation
  end
  local function advance(state, generation, now, space_focused_3f, window_focused_3f)
    local operation = state.active
    if ((nil == operation) or (generation ~= operation.generation)) then
      return {outcome = 'stale'}
    else
    end
    if (now > operation.deadline) then
      state["active"] = nil
      return {outcome = 'timeout'}
    else
    end
    operation["attempt"] = (operation.attempt + 1)
    if (space_focused_3f and ((nil == operation["target-window-id"]) or window_focused_3f)) then
      operation["stable-count"] = (operation["stable-count"] + 1)
    else
      operation["stable-count"] = 0
    end
    if (operation["stable-count"] >= 3) then
      state["active"] = nil
      return {outcome = "complete", operation = operation}
    else
      return {outcome = "retry", operation = operation}
    end
  end
  return {start = start, advance = advance}
end
local _local_479_ = require("components")
local component_registry = _local_479_["component-registry"]
package.preload["commands"] = package.preload["commands"] or function(...)
  local _local_486_ = require("sheaf.command-registry")
  local make_command_registry = _local_486_["make-command-registry"]
  local add_command_21 = _local_486_["add-command!"]
  local _local_487_ = require("traits")
  local trait_registry = _local_487_["trait-registry"]
  local _local_490_ = require("commands.toggle-expose")
  local toggle_expose_command = _local_490_["toggle-expose-command"]
  local _local_497_ = require("commands.space-indicator")
  local update_menubar_command = _local_497_["update-menubar-command"]
  local _local_502_ = require("commands.desktop-layout")
  local reconcile_spaces_command = _local_502_["reconcile-spaces-command"]
  local _local_531_ = require("commands.mouse-window-management")
  local focus_hovered_window_command = _local_531_["focus-hovered-window-command"]
  local consume_hover_focus_command = _local_531_["consume-hover-focus-command"]
  local center_cursor_command = _local_531_["center-cursor-command"]
  local note_space_change_command = _local_531_["note-space-change-command"]
  local schedule_placement_command = _local_531_["schedule-placement-command"]
  local place_window_command = _local_531_["place-window-command"]
  local _local_534_ = require("commands.compile-fennel")
  local compile_command = _local_534_["compile-command"]
  local _local_538_ = require("commands.reload-hammerspoon")
  local reload_hammerspoon_command = _local_538_["reload-hammerspoon-command"]
  local _local_543_ = require("commands.open-in-app")
  local open_in_app_command = _local_543_["open-in-app-command"]
  local _local_551_ = require("commands.show-chooser")
  local show_chooser_command = _local_551_["show-chooser-command"]
  local _local_560_ = require("commands.open-emacs")
  local open_emacs_command = _local_560_["open-emacs-command"]
  local _local_571_ = require("commands.window-border")
  local show_active_border_command = _local_571_["show-active-border-command"]
  local show_inactive_border_command = _local_571_["show-inactive-border-command"]
  local hide_borders_command = _local_571_["hide-borders-command"]
  local _local_576_ = require("commands.record-url")
  local record_url_command = _local_576_["record-url-command"]
  local _local_582_ = require("commands.show-history")
  local show_history_command = _local_582_["show-history-command"]
  local _local_590_ = require("commands.window-state")
  local initialize_windows_command = _local_590_["initialize-windows-command"]
  local upsert_window_command = _local_590_["upsert-window-command"]
  local remove_window_command = _local_590_["remove-window-command"]
  local set_focused_window_command = _local_590_["set-focused-window-command"]
  local _local_617_ = require("commands.paper-wm")
  local initialize_layout_command = _local_617_["initialize-layout-command"]
  local reconcile_window_command = _local_617_["reconcile-window-command"]
  local record_focus_command = _local_617_["record-focus-command"]
  local retile_observed_frame_command = _local_617_["retile-observed-frame-command"]
  local retry_space_focus_command = _local_617_["retry-space-focus-command"]
  local focus_command = _local_617_["focus-command"]
  local swap_command = _local_617_["swap-command"]
  local center_window_command = _local_617_["center-window-command"]
  local set_full_width_command = _local_617_["set-full-width-command"]
  local cycle_window_size_command = _local_617_["cycle-window-size-command"]
  local slurp_window_command = _local_617_["slurp-window-command"]
  local barf_window_command = _local_617_["barf-window-command"]
  local switch_to_space_command = _local_617_["switch-to-space-command"]
  local increment_space_command = _local_617_["increment-space-command"]
  local refresh_windows_command = _local_617_["refresh-windows-command"]
  local command_registry = make_command_registry({["trait-registry"] = trait_registry})
  add_command_21(command_registry, toggle_expose_command)
  add_command_21(command_registry, update_menubar_command)
  add_command_21(command_registry, reconcile_spaces_command)
  add_command_21(command_registry, focus_hovered_window_command)
  add_command_21(command_registry, consume_hover_focus_command)
  add_command_21(command_registry, center_cursor_command)
  add_command_21(command_registry, note_space_change_command)
  add_command_21(command_registry, schedule_placement_command)
  add_command_21(command_registry, place_window_command)
  add_command_21(command_registry, compile_command)
  add_command_21(command_registry, reload_hammerspoon_command)
  add_command_21(command_registry, open_in_app_command)
  add_command_21(command_registry, show_chooser_command)
  add_command_21(command_registry, open_emacs_command)
  add_command_21(command_registry, show_active_border_command)
  add_command_21(command_registry, show_inactive_border_command)
  add_command_21(command_registry, hide_borders_command)
  add_command_21(command_registry, record_url_command)
  add_command_21(command_registry, show_history_command)
  add_command_21(command_registry, initialize_windows_command)
  add_command_21(command_registry, upsert_window_command)
  add_command_21(command_registry, remove_window_command)
  add_command_21(command_registry, set_focused_window_command)
  add_command_21(command_registry, initialize_layout_command)
  add_command_21(command_registry, reconcile_window_command)
  add_command_21(command_registry, record_focus_command)
  add_command_21(command_registry, retile_observed_frame_command)
  add_command_21(command_registry, retry_space_focus_command)
  add_command_21(command_registry, focus_command)
  add_command_21(command_registry, swap_command)
  add_command_21(command_registry, center_window_command)
  add_command_21(command_registry, set_full_width_command)
  add_command_21(command_registry, cycle_window_size_command)
  add_command_21(command_registry, slurp_window_command)
  add_command_21(command_registry, barf_window_command)
  add_command_21(command_registry, switch_to_space_command)
  add_command_21(command_registry, increment_space_command)
  add_command_21(command_registry, refresh_windows_command)
  return {["command-registry"] = command_registry}
end
package.preload["sheaf.command-registry"] = package.preload["sheaf.command-registry"] or function(...)
  local _local_480_ = require("sheaf.trait-registry")
  local trait_defined_3f = _local_480_["trait-defined?"]
  local function make_command_registry(opts)
    if (nil == opts["trait-registry"]) then
      error("make-command-registry: :trait-registry is required")
    else
    end
    return {commands = {}, ["trait-registry"] = opts["trait-registry"]}
  end
  local function make_command(name, description, opts)
    if (nil == opts.fn) then
      error(("make-command: :fn is required for " .. tostring(name)))
    else
    end
    return {name = name, description = description, schema = (opts.schema or {}), ["requires-traits"] = (opts["requires-traits"] or {}), fn = opts.fn}
  end
  local function add_command_21(registry, command)
    local name = command.name
    if (nil == name) then
      error("add-command!: command must have a :name")
    else
    end
    if (nil ~= registry.commands[name]) then
      error(("Command already registered: " .. tostring(name)))
    else
    end
    for _, trait_name in ipairs((command["requires-traits"] or {})) do
      if not trait_defined_3f(registry["trait-registry"], trait_name) then
        error(("add-command! " .. tostring(name) .. ": trait '" .. tostring(trait_name) .. "' not found in trait-registry"))
      else
      end
    end
    registry.commands[name] = command
    return nil
  end
  local function command_defined_3f(registry, name)
    return (nil ~= registry.commands[name])
  end
  local function get_command(registry, name)
    return registry.commands[name]
  end
  local function list_commands(registry)
    local names = {}
    for name, _ in pairs(registry.commands) do
      table.insert(names, name)
    end
    return names
  end
  return {["make-command-registry"] = make_command_registry, ["make-command"] = make_command, ["add-command!"] = add_command_21, ["command-defined?"] = command_defined_3f, ["get-command"] = get_command, ["list-commands"] = list_commands}
end
package.preload["commands.toggle-expose"] = package.preload["commands.toggle-expose"] or function(...)
  local _local_488_ = require("sheaf.command-registry")
  local make_command = _local_488_["make-command"]
  local toggle_expose_command
  local function _489_(component, params)
    component.state.expose:toggleShow()
    return nil
  end
  toggle_expose_command = make_command("expose.commands/toggle-show", "Toggle the Hammerspoon Expose window picker", {["requires-traits"] = {"trait/has-expose"}, fn = _489_})
  return {["toggle-expose-command"] = toggle_expose_command}
end
package.preload["commands.space-indicator"] = package.preload["commands.space-indicator"] or function(...)
  local _local_491_ = require("sheaf.command-registry")
  local make_command = _local_491_["make-command"]
  local table_3f
  local function _492_(_241)
    return (type(_241) == "table")
  end
  table_3f = _492_
  local update_menubar_command
  local function _493_(component, params)
    if component.state.menubar then
      local _494_
      do
        local tbl_26_ = {}
        local i_27_ = 0
        for _, n in ipairs(params["active-spaces"]) do
          local val_28_ = tostring(n)
          if (nil ~= val_28_) then
            i_27_ = (i_27_ + 1)
            tbl_26_[i_27_] = val_28_
          else
          end
        end
        _494_ = tbl_26_
      end
      component.state.menubar:setTitle(table.concat(_494_, "|"))
    else
    end
    return nil
  end
  update_menubar_command = make_command("space-indicator.commands/update-menubar", "Update the space indicator menubar with active space indices", {["requires-traits"] = {"trait/has-menubar"}, schema = {["active-spaces"] = table_3f}, fn = _493_})
  return {["update-menubar-command"] = update_menubar_command}
end
package.preload["commands.desktop-layout"] = package.preload["commands.desktop-layout"] or function(...)
  local _local_498_ = require("sheaf.command-registry")
  local make_command = _local_498_["make-command"]
  local _local_499_ = require("sheaf.event-registry")
  local dispatch_event_21 = _local_499_["dispatch-event!"]
  local _local_500_ = require("events")
  local event_registry = _local_500_["event-registry"]
  local function dispatch_spaces_21(event_name, component, entries, all_spaces, active_spaces)
    for _, entry in ipairs((entries or {})) do
      dispatch_event_21(event_registry, event_name, component.name, {["space-id"] = entry["space-id"], ["screen-uuid"] = entry["screen-uuid"], ["all-spaces"] = all_spaces, ["active-spaces"] = active_spaces})
    end
    return nil
  end
  local reconcile_spaces_command
  local function _501_(component, params)
    dispatch_spaces_21("desktop-layout.events/space-destroyed", component, params.destroyed, params["all-spaces"], params["active-spaces"])
    dispatch_spaces_21("desktop-layout.events/space-created", component, params.created, params["all-spaces"], params["active-spaces"])
    return {["all-spaces"] = params["all-spaces"]}
  end
  reconcile_spaces_command = make_command("desktop-layout.commands/reconcile-spaces", "Capture a desktop snapshot and emit derived space lifecycle events", {["requires-traits"] = {"trait/has-desktop-layout"}, fn = _501_})
  return {["reconcile-spaces-command"] = reconcile_spaces_command}
end
package.preload["commands.mouse-window-management"] = package.preload["commands.mouse-window-management"] or function(...)
  local _local_503_ = require("sheaf.command-registry")
  local make_command = _local_503_["make-command"]
  local _local_504_ = require("sheaf.event-registry")
  local dispatch_event_21 = _local_504_["dispatch-event!"]
  local _local_505_ = require("events")
  local event_registry = _local_505_["event-registry"]
  local _local_506_ = require("event_sources.mouse-window-watcher")
  local window_at_point = _local_506_["window-at-point"]
  local _local_507_ = require("lib.window-facts")
  local snapshot_observed_windows = _local_507_["snapshot-observed-windows"]
  local number_3f
  local function _508_(_241)
    return (type(_241) == "number")
  end
  number_3f = _508_
  local table_3f
  local function _509_(_241)
    return (type(_241) == "table")
  end
  table_3f = _509_
  local string_3f
  local function _510_(_241)
    return (type(_241) == "string")
  end
  string_3f = _510_
  local focus_hovered_window_command
  local function _511_(component, params)
    local point = hs.mouse.absolutePosition()
    local ok, window = pcall(window_at_point, point)
    local matching_3f = (ok and window and (window:id() == params["window-id"]))
    local focused_window = hs.window.focusedWindow()
    local already_focused_3f = (focused_window and (focused_window:id() == params["window-id"]))
    local hover_focus_window_ids = component.state["hover-focus-window-ids"]
    if (matching_3f and not already_focused_3f) then
      local focused_ok
      local function _512_()
        return window:focus()
      end
      focused_ok = pcall(_512_)
      if focused_ok then
        hover_focus_window_ids[params["window-id"]] = true
      else
      end
    else
    end
    return {["last-space-change-at"] = component.state["last-space-change-at"], ["pending-placement-timers"] = component.state["pending-placement-timers"], ["hover-focus-window-ids"] = hover_focus_window_ids}
  end
  focus_hovered_window_command = make_command("mouse-window-management.commands/focus-hovered-window", "Focus the window still under the cursor", {["requires-traits"] = {"trait/has-mouse-window-management-state"}, schema = {["window-id"] = number_3f}, fn = _511_})
  local consume_hover_focus_command
  local function _515_(component, params)
    local hover_focus_window_ids = component.state["hover-focus-window-ids"]
    hover_focus_window_ids[params["window-id"]] = nil
    return {["last-space-change-at"] = component.state["last-space-change-at"], ["pending-placement-timers"] = component.state["pending-placement-timers"], ["hover-focus-window-ids"] = hover_focus_window_ids}
  end
  consume_hover_focus_command = make_command("mouse-window-management.commands/consume-hover-focus", "Clear a consumed mouse-originated focus marker", {["requires-traits"] = {"trait/has-mouse-window-management-state"}, schema = {["window-id"] = number_3f}, fn = _515_})
  local center_cursor_command
  local function _516_(component, params)
    do
      local window_ok, window = pcall(hs.window.get, params["window-id"])
      local frame_ok, live_frame
      if (window_ok and window) then
        local function _517_()
          return window:frame()
        end
        frame_ok, live_frame = pcall(_517_)
      else
        frame_ok, live_frame = false, nil
      end
      local frame
      if frame_ok then
        frame = live_frame
      else
        frame = params.frame
      end
      local point = hs.mouse.absolutePosition()
      if (frame and not hs.geometry.isPointInRect(point, frame)) then
        hs.mouse.absolutePosition(hs.geometry.rectMidPoint(frame))
      else
      end
    end
    return nil
  end
  center_cursor_command = make_command("mouse-window-management.commands/center-cursor", "Center the cursor when it is outside the focused window", {schema = {["window-id"] = number_3f, frame = table_3f}, fn = _516_})
  local note_space_change_command
  local function _521_(component, params)
    return {["last-space-change-at"] = params.timestamp, ["pending-placement-timers"] = component.state["pending-placement-timers"], ["hover-focus-window-ids"] = component.state["hover-focus-window-ids"]}
  end
  note_space_change_command = make_command("mouse-window-management.commands/note-space-change", "Record the latest active Space change", {["requires-traits"] = {"trait/has-mouse-window-management-state"}, schema = {timestamp = number_3f}, fn = _521_})
  local schedule_placement_command
  local function _522_(component, params)
    local pending = component.state["pending-placement-timers"]
    local existing = pending[params["window-id"]]
    local cursor_screen = hs.mouse.getCurrentScreen()
    local cursor_screen_uuid = (cursor_screen and cursor_screen:getUUID())
    if existing then
      existing:stop()
    else
    end
    local function _524_()
      pending[params["window-id"]] = nil
      return dispatch_event_21(event_registry, "mouse-window-management.events/window-placement-ready", component.name, {["window-id"] = params["window-id"], ["created-at"] = params["created-at"], ["cursor-screen-uuid"] = cursor_screen_uuid})
    end
    pending[params["window-id"]] = hs.timer.doAfter(0.25, _524_)
    return {["last-space-change-at"] = component.state["last-space-change-at"], ["pending-placement-timers"] = pending, ["hover-focus-window-ids"] = component.state["hover-focus-window-ids"]}
  end
  schedule_placement_command = make_command("mouse-window-management.commands/schedule-window-placement", "Delay likely-new window placement until Space discovery settles", {["requires-traits"] = {"trait/has-mouse-window-management-state"}, schema = {["window-id"] = number_3f, ["created-at"] = number_3f}, fn = _522_})
  local place_window_command
  local function _525_(component, params)
    local window_ok, window = pcall(hs.window.get, params["window-id"])
    local cursor_screen = (params["cursor-screen-uuid"] and hs.screen.find(params["cursor-screen-uuid"]))
    local pending = component.state["pending-placement-timers"]
    if (window_ok and window and cursor_screen and window:isStandard() and not window:isFullScreen() and (window:screen() ~= cursor_screen)) then
      local moved_ok
      local function _526_()
        return window:moveToScreen(cursor_screen, true, true, 0)
      end
      moved_ok = pcall(_526_)
      if moved_ok then
        local function _527_()
          pending[params["window-id"]] = nil
          local function _528_()
            local tmp_9_ = snapshot_observed_windows()
            tmp_9_["window-id"] = params["window-id"]
            return tmp_9_
          end
          return dispatch_event_21(event_registry, "mouse-window-management.events/window-placed", component.name, _528_())
        end
        pending[params["window-id"]] = hs.timer.doAfter(0.25, _527_)
      else
      end
    else
    end
    return {["last-space-change-at"] = component.state["last-space-change-at"], ["pending-placement-timers"] = pending, ["hover-focus-window-ids"] = component.state["hover-focus-window-ids"]}
  end
  place_window_command = make_command("mouse-window-management.commands/place-window-on-cursor-screen", "Move a new standard window to the cursor's screen", {["requires-traits"] = {"trait/has-mouse-window-management-state"}, schema = {["window-id"] = number_3f, ["cursor-screen-uuid"] = string_3f}, fn = _525_})
  return {["focus-hovered-window-command"] = focus_hovered_window_command, ["consume-hover-focus-command"] = consume_hover_focus_command, ["center-cursor-command"] = center_cursor_command, ["note-space-change-command"] = note_space_change_command, ["schedule-placement-command"] = schedule_placement_command, ["place-window-command"] = place_window_command}
end
package.preload["commands.compile-fennel"] = package.preload["commands.compile-fennel"] or function(...)
  local _local_532_ = require("sheaf.command-registry")
  local make_command = _local_532_["make-command"]
  local compile_command
  local function _533_(component, params)
    print(hs.execute("./compile.sh", true))
    return nil
  end
  compile_command = make_command("compile-fennel.commands/compile", "Compile Fennel source files", {fn = _533_})
  return {["compile-command"] = compile_command}
end
package.preload["commands.reload-hammerspoon"] = package.preload["commands.reload-hammerspoon"] or function(...)
  local _local_535_ = require("sheaf.command-registry")
  local make_command = _local_535_["make-command"]
  local notify = require("notify")
  local reload_hammerspoon_command
  local function _536_(component, params)
    if not component.state["reloading?"] then
      notify.warn("Reloading...")
      component.state.timer:start()
      return {timer = component.state.timer, ["reloading?"] = true}
    else
      return nil
    end
  end
  reload_hammerspoon_command = make_command("reload-hammerspoon.commands/reload", "Reload Hammerspoon config with debounce", {["requires-traits"] = {"trait/has-delayed-timer"}, fn = _536_})
  return {["reload-hammerspoon-command"] = reload_hammerspoon_command}
end
package.preload["commands.open-in-app"] = package.preload["commands.open-in-app"] or function(...)
  local _local_539_ = require("sheaf.command-registry")
  local make_command = _local_539_["make-command"]
  local _local_540_ = require("lib.cljlib-shim")
  local string_3f = _local_540_["string?"]
  local open_in_app_command
  local function _541_(component, params)
    print(("[DEBUG] open-in-app: url=" .. tostring(params.url) .. " bundle-id=" .. tostring(params["bundle-id"])))
    local ok = hs.urlevent.openURLWithBundle(params.url, params["bundle-id"])
    if not ok then
      print(("[WARN] open-in-app: openURLWithBundle returned false for url=" .. tostring(params.url) .. " bundle-id=" .. tostring(params["bundle-id"])))
    else
    end
    return nil
  end
  open_in_app_command = make_command("url-dispatch.commands/open-in-app", "Open a URL in a specific app by bundle ID", {schema = {url = string_3f, ["bundle-id"] = string_3f}, fn = _541_})
  return {["open-in-app-command"] = open_in_app_command}
end
package.preload["commands.show-chooser"] = package.preload["commands.show-chooser"] or function(...)
  local _local_544_ = require("sheaf.command-registry")
  local make_command = _local_544_["make-command"]
  local _local_545_ = require("lib.cljlib-shim")
  local string_3f = _local_545_["string?"]
  local table_3f
  local function _546_(_241)
    return (type(_241) == "table")
  end
  table_3f = _546_
  local active_chooser = nil
  local show_chooser_command
  local function _547_(component, params)
    print(("[DEBUG] show-chooser: url=" .. tostring(params.url) .. " choices=" .. tostring(#(params.choices or {}))))
    if ((nil == params.choices) or (0 == #params.choices)) then
      print("[WARN] show-chooser: no choices provided, skipping")
      return nil
    else
    end
    do
      local url = params.url
      local chooser
      local function _549_(choice)
        if choice then
          print(("[DEBUG] show-chooser: user chose " .. tostring(choice.text) .. " (" .. tostring(choice["bundle-id"]) .. ")"))
          return hs.urlevent.openURLWithBundle(url, choice["bundle-id"])
        else
          return print("[DEBUG] show-chooser: user dismissed chooser")
        end
      end
      chooser = hs.chooser.new(_549_)
      chooser:choices(params.choices)
      chooser:show()
      active_chooser = chooser
    end
    return nil
  end
  show_chooser_command = make_command("url-dispatch.commands/show-chooser", "Show an async browser picker dialog for a URL", {schema = {url = string_3f, choices = table_3f}, fn = _547_})
  return {["show-chooser-command"] = show_chooser_command}
end
package.preload["commands.open-emacs"] = package.preload["commands.open-emacs"] or function(...)
  local _local_552_ = require("sheaf.command-registry")
  local make_command = _local_552_["make-command"]
  local emacsclient_path
  do
    local app = hs.application.find("Emacs")
    if app then
      emacsclient_path = app:path():gsub("Emacs.app", "bin/emacsclient")
    else
      emacsclient_path = "/opt/homebrew/bin/emacsclient"
    end
  end
  local function resolve_server_socket()
    local xdg_runtime = os.getenv("XDG_RUNTIME_DIR")
    local tmpdir = os.getenv("TMPDIR")
    if (xdg_runtime or tmpdir) then
      return (string.gsub((xdg_runtime or tmpdir), "/+$", "") .. "/emacs/server")
    else
      local handle = io.popen("getconf DARWIN_USER_TEMP_DIR 2>/dev/null")
      if handle then
        local dir = handle:read("*l")
        handle:close()
        if (dir and (dir ~= "")) then
          return (string.gsub(dir, "/+$", "") .. "/emacs/server")
        else
          return "/tmp/emacs/server"
        end
      else
        return "/tmp/emacs/server"
      end
    end
  end
  local server_socket = resolve_server_socket()
  local open_emacs_command
  local function _557_(component, params)
    io.popen(("'" .. emacsclient_path .. "' --socket-name '" .. server_socket .. "' -n -c &"))
    local function _558_()
      local app = hs.application.find("Emacs")
      if app then
        return app:activate()
      else
        return nil
      end
    end
    hs.timer.doAfter(0.3, _558_)
    return nil
  end
  open_emacs_command = make_command("emacs.commands/open-emacs", "Open a new emacsclient frame", {fn = _557_})
  return {["open-emacs-command"] = open_emacs_command}
end
package.preload["commands.window-border"] = package.preload["commands.window-border"] or function(...)
  local _local_561_ = require("sheaf.command-registry")
  local make_command = _local_561_["make-command"]
  local function resolve_corner_radius(window_id, default_radius)
    local has_api = (hs.window and hs.window.cornerRadiusForID)
    if has_api then
      local ok, detected = pcall(hs.window.cornerRadiusForID, window_id)
      if (ok and detected and (detected > 0)) then
        return detected
      else
        return default_radius
      end
    else
      return default_radius
    end
  end
  local function position_border_canvas(canvas, bw, cr, frame)
    local outer_radius = (cr + bw)
    canvas:frame({x = (frame.x - bw), y = (frame.y - bw), w = (frame.w + (2 * bw)), h = (frame.h + (2 * bw))})
    canvas:elementAttribute(1, "roundedRectRadii", {xRadius = outer_radius, yRadius = outer_radius})
    canvas:elementAttribute(2, "frame", {x = bw, y = bw, w = frame.w, h = frame.h})
    canvas:elementAttribute(2, "roundedRectRadii", {xRadius = cr, yRadius = cr})
    return canvas:show()
  end
  local show_active_border_command
  local function _564_(component, params)
    if (params["only-if-active"] and (params["window-id"] ~= component.state["active-window-id"])) then
      return nil
    else
    end
    do
      local bw = component.state["border-width"]
      local cr = resolve_corner_radius(params["window-id"], component.state["default-corner-radius"])
      position_border_canvas(component.state["active-canvas"], bw, cr, params.frame)
    end
    return {["active-canvas"] = component.state["active-canvas"], ["inactive-canvas"] = component.state["inactive-canvas"], ["active-window-id"] = params["window-id"], ["border-width"] = component.state["border-width"], ["default-corner-radius"] = component.state["default-corner-radius"]}
  end
  show_active_border_command = make_command("window-border.commands/show-active-border", "Position and show the active window border around a window frame", {["requires-traits"] = {"trait/has-canvas"}, fn = _564_})
  local show_inactive_border_command
  local function _566_(component, params)
    do
      local bw = component.state["border-width"]
      local cr = resolve_corner_radius(params["window-id"], component.state["default-corner-radius"])
      position_border_canvas(component.state["inactive-canvas"], bw, cr, params.frame)
    end
    return nil
  end
  show_inactive_border_command = make_command("window-border.commands/show-inactive-border", "Position and show the inactive window border around a window frame", {["requires-traits"] = {"trait/has-canvas"}, fn = _566_})
  local hide_borders_command
  local function _567_(component, params)
    if (params["only-if-active"] and (params["window-id"] ~= component.state["active-window-id"])) then
      return nil
    else
    end
    if component.state["active-canvas"] then
      component.state["active-canvas"]:hide()
    else
    end
    if component.state["inactive-canvas"] then
      component.state["inactive-canvas"]:hide()
    else
    end
    return {["active-canvas"] = component.state["active-canvas"], ["inactive-canvas"] = component.state["inactive-canvas"], ["active-window-id"] = nil, ["border-width"] = component.state["border-width"], ["default-corner-radius"] = component.state["default-corner-radius"]}
  end
  hide_borders_command = make_command("window-border.commands/hide-borders", "Hide both active and inactive window border overlays", {["requires-traits"] = {"trait/has-canvas"}, fn = _567_})
  return {["show-active-border-command"] = show_active_border_command, ["show-inactive-border-command"] = show_inactive_border_command, ["hide-borders-command"] = hide_borders_command}
end
package.preload["commands.record-url"] = package.preload["commands.record-url"] or function(...)
  local _local_572_ = require("sheaf.command-registry")
  local make_command = _local_572_["make-command"]
  local _local_573_ = require("lib.cljlib-shim")
  local string_3f = _local_573_["string?"]
  local number_3f
  local function _574_(_241)
    return (type(_241) == "number")
  end
  number_3f = _574_
  local record_url_command
  local function _575_(component, params)
    local entry = {url = params.url, ["sender-bundle-id"] = params["sender-bundle-id"], timestamp = params.timestamp}
    local old_history = (component.state.history or {})
    local history = {}
    for _, h in ipairs(old_history) do
      table.insert(history, h)
    end
    table.insert(history, entry)
    return {history = history}
  end
  record_url_command = make_command("url-history.commands/record-url", "Record a URL visit into the history log", {schema = {url = string_3f, ["sender-bundle-id"] = string_3f, timestamp = number_3f}, ["requires-traits"] = {"trait/has-url-history"}, fn = _575_})
  return {["record-url-command"] = record_url_command}
end
package.preload["commands.show-history"] = package.preload["commands.show-history"] or function(...)
  local _local_577_ = require("sheaf.command-registry")
  local make_command = _local_577_["make-command"]
  local active_history_chooser = nil
  local show_history_command
  local function _578_(component, params)
    do
      local history = (component.state.history or {})
      local choices = {}
      if (0 == #history) then
        hs.alert("No URL history yet")
        return nil
      else
      end
      for i = #history, 1, -1 do
        local entry = history[i]
        table.insert(choices, {text = entry.url, subText = ((entry["sender-bundle-id"] or "unknown") .. " \226\128\148 " .. os.date("%Y-%m-%d %H:%M", math.floor(entry.timestamp)))})
      end
      local chooser
      local function _580_(choice)
        if choice then
          hs.pasteboard.setContents(choice.text)
          return hs.alert("URL copied to clipboard")
        else
          return nil
        end
      end
      chooser = hs.chooser.new(_580_)
      chooser:choices(choices)
      chooser:show()
      active_history_chooser = chooser
    end
    return nil
  end
  show_history_command = make_command("url-history.commands/show-history", "Show URL history as a searchable chooser list", {["requires-traits"] = {"trait/has-url-history"}, fn = _578_})
  return {["show-history-command"] = show_history_command}
end
package.preload["commands.window-state"] = package.preload["commands.window-state"] or function(...)
  local _local_583_ = require("sheaf.command-registry")
  local make_command = _local_583_["make-command"]
  local initialize_windows_command
  local function _584_(component, params)
    local windows = {}
    for _, entry in ipairs(params.windows) do
      windows[entry["window-id"]] = {["window-id"] = entry["window-id"], ["app-name"] = entry["app-name"], ["bundle-id"] = entry["bundle-id"], ["window-title"] = entry["window-title"], frame = entry.frame, fullscreen = (entry.fullscreen or false)}
    end
    return {windows = windows, ["focused-window-id"] = nil}
  end
  initialize_windows_command = make_command("window-state.commands/initialize-windows", "Populate window state from initial snapshot", {["requires-traits"] = {"trait/has-window-state"}, fn = _584_})
  local upsert_window_command
  local function _585_(component, params)
    local windows = component.state.windows
    local wid = params["window-id"]
    local existing = (windows[wid] or {})
    local _586_
    if (nil ~= params.fullscreen) then
      _586_ = params.fullscreen
    else
      _586_ = existing.fullscreen
    end
    windows[wid] = {["window-id"] = wid, ["app-name"] = (params["app-name"] or existing["app-name"]), ["bundle-id"] = (params["bundle-id"] or existing["bundle-id"]), ["window-title"] = (params["window-title"] or existing["window-title"]), frame = (params.frame or existing.frame), fullscreen = _586_}
    return {windows = windows, ["focused-window-id"] = component.state["focused-window-id"]}
  end
  upsert_window_command = make_command("window-state.commands/upsert-window", "Add or update a tracked window", {["requires-traits"] = {"trait/has-window-state"}, fn = _585_})
  local remove_window_command
  local function _588_(component, params)
    local windows = component.state.windows
    windows[params["window-id"]] = nil
    return {windows = windows, ["focused-window-id"] = component.state["focused-window-id"]}
  end
  remove_window_command = make_command("window-state.commands/remove-window", "Remove a window from tracking", {["requires-traits"] = {"trait/has-window-state"}, fn = _588_})
  local set_focused_window_command
  local function _589_(component, params)
    return {windows = component.state.windows, ["focused-window-id"] = params["window-id"]}
  end
  set_focused_window_command = make_command("window-state.commands/set-focused-window", "Set the currently focused window ID", {["requires-traits"] = {"trait/has-window-state"}, fn = _589_})
  return {["initialize-windows-command"] = initialize_windows_command, ["upsert-window-command"] = upsert_window_command, ["remove-window-command"] = remove_window_command, ["set-focused-window-command"] = set_focused_window_command}
end
package.preload["commands.paper-wm"] = package.preload["commands.paper-wm"] or function(...)
  local _local_591_ = require("sheaf.command-registry")
  local make_command = _local_591_["make-command"]
  local _local_592_ = require("paper-wm")
  local initialize_layout_21 = _local_592_["initialize-layout!"]
  local reconcile_layout_21 = _local_592_["reconcile-layout!"]
  local reconcile_window_fact_21 = _local_592_["reconcile-window-fact!"]
  local record_focus_21 = _local_592_["record-focus!"]
  local retile_observed_frame_21 = _local_592_["retile-observed-frame!"]
  local start_space_focus_21 = _local_592_["start-space-focus!"]
  local retry_space_focus_21 = _local_592_["retry-space-focus!"]
  local space_index_after_direction = _local_592_["space-index-after-direction"]
  local focus_window_21 = _local_592_["focus-window!"]
  local swap_windows_21 = _local_592_["swap-windows!"]
  local center_window_21 = _local_592_["center-window!"]
  local set_window_full_width_21 = _local_592_["set-window-full-width!"]
  local cycle_window_size_21 = _local_592_["cycle-window-size!"]
  local slurp_window_21 = _local_592_["slurp-window!"]
  local barf_window_21 = _local_592_["barf-window!"]
  local number_3f
  local function _593_(_241)
    return (type(_241) == "number")
  end
  number_3f = _593_
  local table_3f
  local function _594_(_241)
    return (type(_241) == "table")
  end
  table_3f = _594_
  local initialize_layout_command
  local function _595_(component, params)
    reconcile_layout_21(component.state, params.windows, params["observed-spaces"])
    return component.state
  end
  initialize_layout_command = make_command("paper-wm.commands/initialize-layout", "Initialize PaperWM membership from a shared window snapshot", {["requires-traits"] = {"trait/has-paper-wm-runtime", "trait/has-tiling-state"}, schema = {windows = table_3f, ["observed-spaces"] = table_3f}, fn = _595_})
  local reconcile_window_command
  local function _596_(component, params)
    return reconcile_window_fact_21(component.state, params.window, {["runtime-epoch"] = params["runtime-epoch"]})
  end
  reconcile_window_command = make_command("paper-wm.commands/reconcile-window", "Reconcile one shared window fact into PaperWM membership", {["requires-traits"] = {"trait/has-paper-wm-runtime", "trait/has-tiling-state"}, schema = {window = table_3f}, fn = _596_})
  local record_focus_command
  local function _597_(component, params)
    return record_focus_21(component.state, params.window)
  end
  record_focus_command = make_command("paper-wm.commands/record-focus", "Reconcile the focused window's fact, then record focus and retile", {["requires-traits"] = {"trait/has-paper-wm-runtime", "trait/has-tiling-state"}, schema = {window = table_3f}, fn = _597_})
  local retile_observed_frame_command
  local function _598_(component, params)
    return retile_observed_frame_21(component.state, params)
  end
  retile_observed_frame_command = make_command("paper-wm.commands/retile-observed-frame", "Retile from the latest coalesced manual frame", {["requires-traits"] = {"trait/has-paper-wm-runtime", "trait/has-tiling-state"}, schema = {["window-id"] = number_3f, frame = table_3f, generation = number_3f, sequence = number_3f}, fn = _598_})
  local focus_command
  local function _599_(_241)
    return ((_241 == "left") or (_241 == "right") or (_241 == "up") or (_241 == "down"))
  end
  local function _600_(component, params)
    return focus_window_21(component.state, params.direction)
  end
  focus_command = make_command("paper-wm.commands/focus", "Focus the window in a direction", {schema = {direction = _599_}, ["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _600_})
  local swap_command
  local function _601_(_241)
    return ((_241 == "left") or (_241 == "right") or (_241 == "up") or (_241 == "down"))
  end
  local function _602_(component, params)
    return swap_windows_21(component.state, params.direction)
  end
  swap_command = make_command("paper-wm.commands/swap", "Swap the focused window in a direction", {schema = {direction = _601_}, ["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _602_})
  local center_window_command
  local function _603_(component, params)
    return center_window_21(component.state)
  end
  center_window_command = make_command("paper-wm.commands/center-window", "Center the focused window on screen", {["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _603_})
  local set_full_width_command
  local function _604_(component, params)
    return set_window_full_width_21(component.state)
  end
  set_full_width_command = make_command("paper-wm.commands/set-full-width", "Set the focused window to full screen width", {["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _604_})
  local cycle_window_size_command
  local function _605_(_241)
    return ((_241 == "width") or (_241 == "height"))
  end
  local function _606_(_241)
    return ((_241 == "ascending") or (_241 == "descending"))
  end
  local function _607_(component, params)
    return cycle_window_size_21(component.state, params.direction, params["cycle-direction"])
  end
  cycle_window_size_command = make_command("paper-wm.commands/cycle-window-size", "Cycle the focused window size", {schema = {direction = _605_, ["cycle-direction"] = _606_}, ["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _607_})
  local slurp_window_command
  local function _608_(component, params)
    return slurp_window_21(component.state)
  end
  slurp_window_command = make_command("paper-wm.commands/slurp-window", "Slurp a window into the current column", {["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _608_})
  local barf_window_command
  local function _609_(component, params)
    return barf_window_21(component.state)
  end
  barf_window_command = make_command("paper-wm.commands/barf-window", "Barf a window out of the current column", {["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _609_})
  local switch_to_space_command
  local function _610_(_241)
    return (("number" == type(_241)) and ((1 <= _241) and (_241 <= 9)))
  end
  local function _611_(component, params)
    return start_space_focus_21(component.state, params.index)
  end
  switch_to_space_command = make_command("paper-wm.commands/switch-to-space", "Start a Space focus conversation for an absolute index", {schema = {index = _610_}, ["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _611_})
  local increment_space_command
  local function _612_(_241)
    return ((_241 == "left") or (_241 == "right"))
  end
  local function _613_(component, params)
    local index = space_index_after_direction(params.direction)
    if index then
      return start_space_focus_21(component.state, index)
    else
      return component.state
    end
  end
  increment_space_command = make_command("paper-wm.commands/increment-space", "Start a Space focus conversation for a relative direction", {schema = {direction = _612_}, ["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _613_})
  local retry_space_focus_command
  local function _615_(component, params)
    return retry_space_focus_21(component.state, params.generation)
  end
  retry_space_focus_command = make_command("paper-wm.commands/retry-space-focus", "Advance a generation-scoped Space focus conversation", {schema = {generation = number_3f}, ["requires-traits"] = {"trait/has-paper-wm-runtime"}, fn = _615_})
  local refresh_windows_command
  local function _616_(component, params)
    reconcile_layout_21(component.state, params.windows, params["observed-spaces"])
    return component.state
  end
  refresh_windows_command = make_command("paper-wm.commands/refresh-windows", "Reconcile PaperWM from an explicit window snapshot", {["requires-traits"] = {"trait/has-paper-wm-runtime", "trait/has-tiling-state"}, schema = {windows = table_3f, ["observed-spaces"] = table_3f}, fn = _616_})
  return {["initialize-layout-command"] = initialize_layout_command, ["reconcile-window-command"] = reconcile_window_command, ["record-focus-command"] = record_focus_command, ["retile-observed-frame-command"] = retile_observed_frame_command, ["retry-space-focus-command"] = retry_space_focus_command, ["focus-command"] = focus_command, ["swap-command"] = swap_command, ["center-window-command"] = center_window_command, ["set-full-width-command"] = set_full_width_command, ["cycle-window-size-command"] = cycle_window_size_command, ["slurp-window-command"] = slurp_window_command, ["barf-window-command"] = barf_window_command, ["switch-to-space-command"] = switch_to_space_command, ["increment-space-command"] = increment_space_command, ["refresh-windows-command"] = refresh_windows_command}
end
require("commands")
package.preload["behaviors"] = package.preload["behaviors"] or function(...)
  local _local_638_ = require("sheaf.behavior-registry")
  local make_behavior_registry = _local_638_["make-behavior-registry"]
  local add_behavior_21 = _local_638_["add-behavior!"]
  local _local_639_ = require("events")
  local event_registry = _local_639_["event-registry"]
  local _local_640_ = require("commands")
  local command_registry = _local_640_["command-registry"]
  local _local_641_ = require("shapes")
  local shape_registry = _local_641_["shape-registry"]
  local _local_648_ = require("behaviors.compile-fennel")
  local compile_fennel_behavior = _local_648_["compile-fennel-behavior"]
  local _local_655_ = require("behaviors.reload-hammerspoon")
  local reload_hammerspoon_behavior = _local_655_["reload-hammerspoon-behavior"]
  local _local_659_ = require("behaviors.toggle-expose")
  local toggle_expose_behavior = _local_659_["toggle-expose-behavior"]
  local _local_664_ = require("behaviors.update-space-indicator")
  local update_space_indicator_behavior = _local_664_["update-space-indicator-behavior"]
  local _local_678_ = require("behaviors.desktop-layout")
  local reconcile_spaces_behavior = _local_678_["reconcile-spaces-behavior"]
  local _local_731_ = require("behaviors.mouse-window-management")
  local focus_hovered_window_behavior = _local_731_["focus-hovered-window-behavior"]
  local center_cursor_on_focus_behavior = _local_731_["center-cursor-on-focus-behavior"]
  local schedule_created_window_behavior = _local_731_["schedule-created-window-behavior"]
  local note_space_change_behavior = _local_731_["note-space-change-behavior"]
  local place_created_window_behavior = _local_731_["place-created-window-behavior"]
  local _local_735_ = require("behaviors.open-emacs")
  local open_emacs_behavior = _local_735_["open-emacs-behavior"]
  local _local_743_ = require("behaviors.window-border")
  local update_on_focus_behavior = _local_743_["update-on-focus-behavior"]
  local update_on_move_behavior = _local_743_["update-on-move-behavior"]
  local hide_on_disappear_behavior = _local_743_["hide-on-disappear-behavior"]
  local _local_823_ = require("behaviors.url-routing")
  local route_url_behavior = _local_823_["route-url-behavior"]
  local _local_834_ = require("behaviors.record-url")
  local record_url_behavior = _local_834_["record-url-behavior"]
  local _local_838_ = require("behaviors.show-history")
  local show_history_behavior = _local_838_["show-history-behavior"]
  local _local_863_ = require("behaviors.window-state")
  local initialize_behavior = _local_863_["initialize-behavior"]
  local track_on_change_behavior = _local_863_["track-on-change-behavior"]
  local track_on_move_behavior = _local_863_["track-on-move-behavior"]
  local untrack_on_disappear_behavior = _local_863_["untrack-on-disappear-behavior"]
  local track_focus_behavior = _local_863_["track-focus-behavior"]
  local _local_895_ = require("behaviors.paper-wm")
  local initialize_layout_behavior = _local_895_["initialize-layout-behavior"]
  local reconcile_membership_behavior = _local_895_["reconcile-membership-behavior"]
  local record_focus_behavior = _local_895_["record-focus-behavior"]
  local retile_observed_frame_behavior = _local_895_["retile-observed-frame-behavior"]
  local retry_space_focus_behavior = _local_895_["retry-space-focus-behavior"]
  local focus_behavior = _local_895_["focus-behavior"]
  local swap_behavior = _local_895_["swap-behavior"]
  local center_window_behavior = _local_895_["center-window-behavior"]
  local set_full_width_behavior = _local_895_["set-full-width-behavior"]
  local cycle_window_size_behavior = _local_895_["cycle-window-size-behavior"]
  local slurp_window_behavior = _local_895_["slurp-window-behavior"]
  local barf_window_behavior = _local_895_["barf-window-behavior"]
  local increment_space_behavior = _local_895_["increment-space-behavior"]
  local switch_to_space_behavior = _local_895_["switch-to-space-behavior"]
  local refresh_on_screen_change_behavior = _local_895_["refresh-on-screen-change-behavior"]
  local refresh_on_window_placed_behavior = _local_895_["refresh-on-window-placed-behavior"]
  local behavior_registry = make_behavior_registry({["event-registry"] = event_registry, ["command-registry"] = command_registry, ["shape-registry"] = shape_registry})
  add_behavior_21(behavior_registry, compile_fennel_behavior)
  add_behavior_21(behavior_registry, reload_hammerspoon_behavior)
  add_behavior_21(behavior_registry, toggle_expose_behavior)
  add_behavior_21(behavior_registry, update_space_indicator_behavior)
  add_behavior_21(behavior_registry, reconcile_spaces_behavior)
  add_behavior_21(behavior_registry, focus_hovered_window_behavior)
  add_behavior_21(behavior_registry, center_cursor_on_focus_behavior)
  add_behavior_21(behavior_registry, schedule_created_window_behavior)
  add_behavior_21(behavior_registry, note_space_change_behavior)
  add_behavior_21(behavior_registry, place_created_window_behavior)
  add_behavior_21(behavior_registry, open_emacs_behavior)
  add_behavior_21(behavior_registry, update_on_focus_behavior)
  add_behavior_21(behavior_registry, update_on_move_behavior)
  add_behavior_21(behavior_registry, hide_on_disappear_behavior)
  add_behavior_21(behavior_registry, route_url_behavior)
  add_behavior_21(behavior_registry, record_url_behavior)
  add_behavior_21(behavior_registry, show_history_behavior)
  add_behavior_21(behavior_registry, initialize_behavior)
  add_behavior_21(behavior_registry, track_on_change_behavior)
  add_behavior_21(behavior_registry, track_on_move_behavior)
  add_behavior_21(behavior_registry, untrack_on_disappear_behavior)
  add_behavior_21(behavior_registry, track_focus_behavior)
  add_behavior_21(behavior_registry, initialize_layout_behavior)
  add_behavior_21(behavior_registry, reconcile_membership_behavior)
  add_behavior_21(behavior_registry, record_focus_behavior)
  add_behavior_21(behavior_registry, retile_observed_frame_behavior)
  add_behavior_21(behavior_registry, retry_space_focus_behavior)
  add_behavior_21(behavior_registry, focus_behavior)
  add_behavior_21(behavior_registry, swap_behavior)
  add_behavior_21(behavior_registry, center_window_behavior)
  add_behavior_21(behavior_registry, set_full_width_behavior)
  add_behavior_21(behavior_registry, cycle_window_size_behavior)
  add_behavior_21(behavior_registry, slurp_window_behavior)
  add_behavior_21(behavior_registry, barf_window_behavior)
  add_behavior_21(behavior_registry, increment_space_behavior)
  add_behavior_21(behavior_registry, switch_to_space_behavior)
  add_behavior_21(behavior_registry, refresh_on_screen_change_behavior)
  add_behavior_21(behavior_registry, refresh_on_window_placed_behavior)
  return {["behavior-registry"] = behavior_registry}
end
package.preload["sheaf.behavior-registry"] = package.preload["sheaf.behavior-registry"] or function(...)
  local _local_618_ = require("lib.cljlib-shim")
  local some = _local_618_.some
  local _local_619_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_619_["valid-event-selector?"]
  local _local_620_ = require("sheaf.command-registry")
  local command_defined_3f = _local_620_["command-defined?"]
  local _local_621_ = require("sheaf.shape-registry")
  local shape_defined_3f = _local_621_["shape-defined?"]
  local _local_622_ = require("lib.hierarchy")
  local isa_3f = _local_622_["isa?"]
  local function make_behavior_registry(opts)
    if (nil == opts["event-registry"]) then
      error("make-behavior-registry: :event-registry is required")
    else
    end
    if (nil == opts["command-registry"]) then
      error("make-behavior-registry: :command-registry is required")
    else
    end
    return {behaviors = {}, ["event-registry"] = opts["event-registry"], ["command-registry"] = opts["command-registry"], ["shape-registry"] = opts["shape-registry"]}
  end
  local function make_behavior(opts)
    if (nil == opts.name) then
      error("make-behavior: :name is required")
    else
    end
    if (nil == opts.description) then
      error("make-behavior: :description is required")
    else
    end
    if (nil == opts["respond-to"]) then
      error(("make-behavior: :respond-to is required for " .. tostring(opts.name)))
    else
    end
    if (nil == opts.fn) then
      error(("make-behavior: :fn is required for " .. tostring(opts.name)))
    else
    end
    return {name = opts.name, description = opts.description, ["respond-to"] = opts["respond-to"], commands = (opts.commands or {}), inputs = (opts.inputs or {}), fn = opts.fn}
  end
  local function add_behavior_21(registry, behavior)
    local name = behavior.name
    local inputs = (behavior.inputs or {})
    if (nil == name) then
      error("add-behavior!: behavior must have a :name")
    else
    end
    if (nil ~= registry.behaviors[name]) then
      error(("Behavior already registered: " .. tostring(name)))
    else
    end
    for _, selector in ipairs(behavior["respond-to"]) do
      if not valid_event_selector_3f(registry["event-registry"], selector) then
        print(("[WARN] add-behavior!: event-selector '" .. tostring(selector) .. "' in behavior '" .. tostring(name) .. "' has no matching defined events"))
      else
      end
    end
    for alias, cmd_name in pairs(behavior.commands) do
      if not command_defined_3f(registry["command-registry"], cmd_name) then
        error(("add-behavior! " .. tostring(name) .. ": command '" .. tostring(cmd_name) .. "' (alias '" .. tostring(alias) .. "') not found in command-registry"))
      else
      end
    end
    if next(inputs) then
      if (nil == registry["shape-registry"]) then
        error(("add-behavior! " .. tostring(name) .. ": behavior declares :inputs but registry has no :shape-registry"))
      else
      end
      for alias, shape_name in pairs(inputs) do
        if not shape_defined_3f(registry["shape-registry"], shape_name) then
          error(("add-behavior! " .. tostring(name) .. ": input shape '" .. tostring(shape_name) .. "' (alias '" .. tostring(alias) .. "') not found in shape-registry"))
        else
        end
      end
    else
    end
    registry.behaviors[name] = behavior
    return nil
  end
  local function behavior_defined_3f(registry, name)
    return (nil ~= registry.behaviors[name])
  end
  local function get_behavior(registry, name)
    return registry.behaviors[name]
  end
  local function list_behaviors(registry)
    local names = {}
    for name, _ in pairs(registry.behaviors) do
      table.insert(names, name)
    end
    return names
  end
  local function behavior_responds_to_3f(registry, behavior_name, event_name)
    local behavior = get_behavior(registry, behavior_name)
    if (nil == behavior) then
      return false
    else
      local function _636_(_241)
        return isa_3f(registry["event-registry"].hierarchy, event_name, _241)
      end
      return some(_636_, behavior["respond-to"])
    end
  end
  return {["make-behavior-registry"] = make_behavior_registry, ["make-behavior"] = make_behavior, ["add-behavior!"] = add_behavior_21, ["behavior-defined?"] = behavior_defined_3f, ["get-behavior"] = get_behavior, ["list-behaviors"] = list_behaviors, ["behavior-responds-to?"] = behavior_responds_to_3f}
end
package.preload["behaviors.compile-fennel"] = package.preload["behaviors.compile-fennel"] or function(...)
  local _local_642_ = require("sheaf.behavior-registry")
  local make_behavior = _local_642_["make-behavior"]
  local compile_fennel_behavior
  local function _643_(file_change_event, candidates, send_cmd)
    local path
    do
      local t_644_ = file_change_event
      if (nil ~= t_644_) then
        t_644_ = t_644_["event-data"]
      else
      end
      if (nil ~= t_644_) then
        t_644_ = t_644_["file-path"]
      else
      end
      path = t_644_
    end
    local target = candidates.compile[1]
    if (target and (nil ~= path) and (".fnl" == path:sub(-4))) then
      return send_cmd(target, "compile", {})
    else
      return nil
    end
  end
  compile_fennel_behavior = make_behavior({name = "compile-fennel.behaviors/compile-fennel", description = "Watch fennel files in hammerspoon folder and recompile them.", ["respond-to"] = {"event.kind.fs/file-change"}, commands = {compile = "compile-fennel.commands/compile"}, fn = _643_})
  return {["compile-fennel-behavior"] = compile_fennel_behavior}
end
package.preload["behaviors.reload-hammerspoon"] = package.preload["behaviors.reload-hammerspoon"] or function(...)
  local _local_649_ = require("sheaf.behavior-registry")
  local make_behavior = _local_649_["make-behavior"]
  local reload_hammerspoon_behavior
  local function _650_(file_change_event, candidates, send_cmd)
    local path
    do
      local t_651_ = file_change_event
      if (nil ~= t_651_) then
        t_651_ = t_651_["event-data"]
      else
      end
      if (nil ~= t_651_) then
        t_651_ = t_651_["file-path"]
      else
      end
      path = t_651_
    end
    local target = candidates.reload[1]
    if (target and (nil ~= path) and ("/init.lua" == path:sub(-9))) then
      return send_cmd(target, "reload", {})
    else
      return nil
    end
  end
  reload_hammerspoon_behavior = make_behavior({name = "reload-hammerspoon.behaviors/reload-hammerspoon", description = "When init.lua changes, reload hammerspoon.", ["respond-to"] = {"event.kind.fs/file-change"}, commands = {reload = "reload-hammerspoon.commands/reload"}, fn = _650_})
  return {["reload-hammerspoon-behavior"] = reload_hammerspoon_behavior}
end
package.preload["behaviors.toggle-expose"] = package.preload["behaviors.toggle-expose"] or function(...)
  local _local_656_ = require("sheaf.behavior-registry")
  local make_behavior = _local_656_["make-behavior"]
  local toggle_expose_behavior
  local function _657_(event, candidates, send_cmd)
    local target = candidates["toggle-show"][1]
    if target then
      return send_cmd(target, "toggle-show", {})
    else
      return nil
    end
  end
  toggle_expose_behavior = make_behavior({name = "expose.behaviors/toggle-expose", description = "Toggle the Hammerspoon Expose window picker", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["toggle-show"] = "expose.commands/toggle-show"}, fn = _657_})
  return {["toggle-expose-behavior"] = toggle_expose_behavior}
end
package.preload["behaviors.update-space-indicator"] = package.preload["behaviors.update-space-indicator"] or function(...)
  local _local_660_ = require("sheaf.behavior-registry")
  local make_behavior = _local_660_["make-behavior"]
  local function compute_active_space_indices(all_spaces, active_spaces)
    local result = {}
    local offset = 0
    for _, entry in ipairs(all_spaces) do
      local uuid = entry[1]
      local space_ids = entry[2]
      local active_sid = active_spaces[uuid]
      for i, sid in ipairs(space_ids) do
        if (sid == active_sid) then
          table.insert(result, (i + offset))
        else
        end
      end
      offset = (offset + #space_ids)
    end
    return result
  end
  local update_space_indicator_behavior
  local function _662_(event, candidates, send_cmd)
    local target = candidates["update-menubar"][1]
    if target then
      local indices = compute_active_space_indices(event["event-data"]["all-spaces"], event["event-data"]["active-spaces"])
      return send_cmd(target, "update-menubar", {["active-spaces"] = indices})
    else
      return nil
    end
  end
  update_space_indicator_behavior = make_behavior({name = "space-indicator.behaviors/update-on-change", description = "Update space indicator menubar when spaces or screens change", ["respond-to"] = {"event.kind.space/changed", "event.kind.screen/any"}, commands = {["update-menubar"] = "space-indicator.commands/update-menubar"}, fn = _662_})
  return {["update-space-indicator-behavior"] = update_space_indicator_behavior}
end
package.preload["behaviors.desktop-layout"] = package.preload["behaviors.desktop-layout"] or function(...)
  local _local_665_ = require("sheaf.behavior-registry")
  local make_behavior = _local_665_["make-behavior"]
  local function space_id_set(all_spaces)
    local ids = {}
    for _, entry in ipairs((all_spaces or {})) do
      for _0, space_id in ipairs(entry[2]) do
        ids[space_id] = true
      end
    end
    return ids
  end
  local function missing_spaces(ordered_layout, other_ids)
    local missing = {}
    for _, entry in ipairs((ordered_layout or {})) do
      local screen_uuid = entry[1]
      for _0, space_id in ipairs(entry[2]) do
        if (nil == other_ids[space_id]) then
          table.insert(missing, {["space-id"] = space_id, ["screen-uuid"] = screen_uuid})
        else
        end
      end
    end
    return missing
  end
  local function reconcile_spaces(previous, current)
    local previous_ids = space_id_set(previous)
    local current_ids = space_id_set(current)
    return {destroyed = missing_spaces(previous, current_ids), created = missing_spaces(current, previous_ids)}
  end
  local reconcile_spaces_behavior
  local function _667_(event, candidates, send_cmd, inputs)
    local target = candidates.reconcile[1]
    local previous
    do
      local t_668_ = inputs
      if (nil ~= t_668_) then
        t_668_ = t_668_.layout
      else
      end
      if (nil ~= t_668_) then
        t_668_ = t_668_["all-spaces"]
      else
      end
      previous = t_668_
    end
    local current
    do
      local t_671_ = event
      if (nil ~= t_671_) then
        t_671_ = t_671_["event-data"]
      else
      end
      if (nil ~= t_671_) then
        t_671_ = t_671_["all-spaces"]
      else
      end
      current = t_671_
    end
    local active
    do
      local t_674_ = event
      if (nil ~= t_674_) then
        t_674_ = t_674_["event-data"]
      else
      end
      if (nil ~= t_674_) then
        t_674_ = t_674_["active-spaces"]
      else
      end
      active = t_674_
    end
    if (target and previous and current and active) then
      local diff = reconcile_spaces(previous, current)
      return send_cmd(target, "reconcile", {["all-spaces"] = current, ["active-spaces"] = active, destroyed = diff.destroyed, created = diff.created})
    else
      return nil
    end
  end
  reconcile_spaces_behavior = make_behavior({name = "desktop-layout.behaviors/reconcile-spaces", description = "Derive space creation and destruction from consecutive snapshots", ["respond-to"] = {"space-watcher.events/space-changed", "screen-watcher.events/screen-changed"}, commands = {reconcile = "desktop-layout.commands/reconcile-spaces"}, inputs = {layout = "shape/desktop-layout"}, fn = _667_})
  return {["reconcile-spaces-behavior"] = reconcile_spaces_behavior}
end
package.preload["behaviors.mouse-window-management"] = package.preload["behaviors.mouse-window-management"] or function(...)
  local _local_679_ = require("sheaf.behavior-registry")
  local make_behavior = _local_679_["make-behavior"]
  local function should_focus_hovered_3f(window_id, window_state)
    local window
    do
      local t_680_ = window_state
      if (nil ~= t_680_) then
        t_680_ = t_680_.windows
      else
      end
      if (nil ~= t_680_) then
        t_680_ = t_680_[window_id]
      else
      end
      window = t_680_
    end
    return (window and not window.fullscreen and (window_id ~= window_state["focused-window-id"]))
  end
  local function likely_new_window_3f(window_id, window_state)
    local windows
    local _684_
    do
      local t_683_ = window_state
      if (nil ~= t_683_) then
        t_683_ = t_683_.windows
      else
      end
      _684_ = t_683_
    end
    windows = (_684_ or {})
    if windows[window_id] then
      return false
    else
    end
    local max_window_id = nil
    for tracked_id, _ in pairs(windows) do
      if ((max_window_id == nil) or (tracked_id > max_window_id)) then
        max_window_id = tracked_id
      else
      end
    end
    return ((max_window_id == nil) or (window_id > max_window_id))
  end
  local function placement_allowed_after_space_change_3f(created_at, mouse_state, cooldown)
    local last_change
    do
      local t_688_ = mouse_state
      if (nil ~= t_688_) then
        t_688_ = t_688_["last-space-change-at"]
      else
      end
      last_change = t_688_
    end
    return ((last_change == nil) or (created_at > (last_change + cooldown)))
  end
  local focus_hovered_window_behavior
  local function _690_(event, candidates, send_cmd, inputs)
    local target = candidates.focus[1]
    local window_id
    do
      local t_691_ = event
      if (nil ~= t_691_) then
        t_691_ = t_691_["event-data"]
      else
      end
      if (nil ~= t_691_) then
        t_691_ = t_691_["window-id"]
      else
      end
      window_id = t_691_
    end
    local window_state
    do
      local t_694_ = inputs
      if (nil ~= t_694_) then
        t_694_ = t_694_["window-state"]
      else
      end
      window_state = t_694_
    end
    if (target and window_id and window_state and should_focus_hovered_3f(window_id, window_state)) then
      return send_cmd(target, "focus", {["window-id"] = window_id})
    else
      return nil
    end
  end
  focus_hovered_window_behavior = make_behavior({name = "mouse-window-management.behaviors/focus-hovered-window", description = "Focus a non-focused, non-fullscreen window after mouse dwell", ["respond-to"] = {"event.kind.mouse/window-hovered"}, commands = {focus = "mouse-window-management.commands/focus-hovered-window"}, inputs = {["window-state"] = "shape/window-state"}, fn = _690_})
  local center_cursor_on_focus_behavior
  local function _697_(event, candidates, send_cmd, inputs)
    local center_target = candidates.center[1]
    local consume_target = candidates["consume-hover-focus"][1]
    local window_id
    do
      local t_698_ = event
      if (nil ~= t_698_) then
        t_698_ = t_698_["event-data"]
      else
      end
      if (nil ~= t_698_) then
        t_698_ = t_698_["window-id"]
      else
      end
      window_id = t_698_
    end
    local frame
    do
      local t_701_ = event
      if (nil ~= t_701_) then
        t_701_ = t_701_["event-data"]
      else
      end
      if (nil ~= t_701_) then
        t_701_ = t_701_.frame
      else
      end
      frame = t_701_
    end
    local hover_focus_window_ids
    do
      local t_704_ = inputs
      if (nil ~= t_704_) then
        t_704_ = t_704_["mouse-state"]
      else
      end
      if (nil ~= t_704_) then
        t_704_ = t_704_["hover-focus-window-ids"]
      else
      end
      hover_focus_window_ids = t_704_
    end
    if (consume_target and (hover_focus_window_ids or {})[window_id]) then
      return send_cmd(consume_target, "consume-hover-focus", {["window-id"] = window_id})
    else
      if (center_target and window_id and frame) then
        return send_cmd(center_target, "center", {["window-id"] = window_id, frame = frame})
      else
        return nil
      end
    end
  end
  center_cursor_on_focus_behavior = make_behavior({name = "mouse-window-management.behaviors/center-cursor-on-focus", description = "Center the cursor for focus changes not initiated by hover", ["respond-to"] = {"event.kind.window/focused"}, commands = {center = "mouse-window-management.commands/center-cursor", ["consume-hover-focus"] = "mouse-window-management.commands/consume-hover-focus"}, inputs = {["mouse-state"] = "shape/mouse-window-management-state"}, fn = _697_})
  local schedule_created_window_behavior
  local function _709_(event, candidates, send_cmd, inputs)
    local target = candidates.schedule[1]
    local window_id
    do
      local t_710_ = event
      if (nil ~= t_710_) then
        t_710_ = t_710_["event-data"]
      else
      end
      if (nil ~= t_710_) then
        t_710_ = t_710_["window-id"]
      else
      end
      window_id = t_710_
    end
    local window_state
    do
      local t_713_ = inputs
      if (nil ~= t_713_) then
        t_713_ = t_713_["window-state"]
      else
      end
      window_state = t_713_
    end
    if (target and window_id and window_state and likely_new_window_3f(window_id, window_state)) then
      return send_cmd(target, "schedule", {["window-id"] = window_id, ["created-at"] = event.timestamp})
    else
      return nil
    end
  end
  schedule_created_window_behavior = make_behavior({name = "mouse-window-management.behaviors/schedule-created-window", description = "Delay placement of a likely-new window until discovery settles", ["respond-to"] = {"event.kind.window/created"}, commands = {schedule = "mouse-window-management.commands/schedule-window-placement"}, inputs = {["window-state"] = "shape/window-state"}, fn = _709_})
  local note_space_change_behavior
  local function _716_(event, candidates, send_cmd)
    local target = candidates.note[1]
    if target then
      return send_cmd(target, "note", {timestamp = event.timestamp})
    else
      return nil
    end
  end
  note_space_change_behavior = make_behavior({name = "mouse-window-management.behaviors/note-space-change", description = "Record active Space changes for placement suppression", ["respond-to"] = {"event.kind.space/changed"}, commands = {note = "mouse-window-management.commands/note-space-change"}, fn = _716_})
  local place_created_window_behavior
  local function _718_(event, candidates, send_cmd, inputs)
    local target = candidates.place[1]
    local window_id
    do
      local t_719_ = event
      if (nil ~= t_719_) then
        t_719_ = t_719_["event-data"]
      else
      end
      if (nil ~= t_719_) then
        t_719_ = t_719_["window-id"]
      else
      end
      window_id = t_719_
    end
    local created_at
    do
      local t_722_ = event
      if (nil ~= t_722_) then
        t_722_ = t_722_["event-data"]
      else
      end
      if (nil ~= t_722_) then
        t_722_ = t_722_["created-at"]
      else
      end
      created_at = t_722_
    end
    local cursor_screen_uuid
    do
      local t_725_ = event
      if (nil ~= t_725_) then
        t_725_ = t_725_["event-data"]
      else
      end
      if (nil ~= t_725_) then
        t_725_ = t_725_["cursor-screen-uuid"]
      else
      end
      cursor_screen_uuid = t_725_
    end
    local mouse_state
    do
      local t_728_ = inputs
      if (nil ~= t_728_) then
        t_728_ = t_728_["mouse-state"]
      else
      end
      mouse_state = t_728_
    end
    if (target and window_id and created_at and cursor_screen_uuid and mouse_state and placement_allowed_after_space_change_3f(created_at, mouse_state, 1.0)) then
      return send_cmd(target, "place", {["window-id"] = window_id, ["cursor-screen-uuid"] = cursor_screen_uuid})
    else
      return nil
    end
  end
  place_created_window_behavior = make_behavior({name = "mouse-window-management.behaviors/place-created-window", description = "Place a settled likely-new window on the cursor's screen", ["respond-to"] = {"event.kind.window/placement-ready"}, commands = {place = "mouse-window-management.commands/place-window-on-cursor-screen"}, inputs = {["mouse-state"] = "shape/mouse-window-management-state"}, fn = _718_})
  return {["focus-hovered-window-behavior"] = focus_hovered_window_behavior, ["center-cursor-on-focus-behavior"] = center_cursor_on_focus_behavior, ["schedule-created-window-behavior"] = schedule_created_window_behavior, ["note-space-change-behavior"] = note_space_change_behavior, ["place-created-window-behavior"] = place_created_window_behavior, ["should-focus-hovered?"] = should_focus_hovered_3f, ["likely-new-window?"] = likely_new_window_3f, ["placement-allowed-after-space-change?"] = placement_allowed_after_space_change_3f}
end
package.preload["behaviors.open-emacs"] = package.preload["behaviors.open-emacs"] or function(...)
  local _local_732_ = require("sheaf.behavior-registry")
  local make_behavior = _local_732_["make-behavior"]
  local open_emacs_behavior
  local function _733_(event, candidates, send_cmd)
    local target = candidates["open-emacs"][1]
    if target then
      return send_cmd(target, "open-emacs", {})
    else
      return nil
    end
  end
  open_emacs_behavior = make_behavior({name = "emacs.behaviors/open-emacs", description = "Open a new emacsclient frame on hotkey press", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["open-emacs"] = "emacs.commands/open-emacs"}, fn = _733_})
  return {["open-emacs-behavior"] = open_emacs_behavior}
end
package.preload["behaviors.window-border"] = package.preload["behaviors.window-border"] or function(...)
  local _local_736_ = require("sheaf.behavior-registry")
  local make_behavior = _local_736_["make-behavior"]
  local update_on_focus_behavior
  local function _737_(event, candidates, send_cmd)
    local target = candidates["show-active"][1]
    if target then
      return send_cmd(target, "show-active", {["window-id"] = event["event-data"]["window-id"], frame = event["event-data"].frame})
    else
      return nil
    end
  end
  update_on_focus_behavior = make_behavior({name = "window-border.behaviors/update-on-focus", description = "Show active border around the newly focused window", ["respond-to"] = {"event.kind.window/focused", "event.kind.window/visible"}, commands = {["show-active"] = "window-border.commands/show-active-border", ["show-inactive"] = "window-border.commands/show-inactive-border"}, fn = _737_})
  local update_on_move_behavior
  local function _739_(event, candidates, send_cmd)
    local target = candidates["show-active"][1]
    if target then
      return send_cmd(target, "show-active", {["window-id"] = event["event-data"]["window-id"], frame = event["event-data"].frame, ["only-if-active"] = true})
    else
      return nil
    end
  end
  update_on_move_behavior = make_behavior({name = "window-border.behaviors/update-on-move", description = "Reposition active border when a window moves or resizes", ["respond-to"] = {"event.kind.window/moved"}, commands = {["show-active"] = "window-border.commands/show-active-border"}, fn = _739_})
  local hide_on_disappear_behavior
  local function _741_(event, candidates, send_cmd)
    local target = candidates.hide[1]
    if target then
      return send_cmd(target, "hide", {["window-id"] = event["event-data"]["window-id"], ["only-if-active"] = true})
    else
      return nil
    end
  end
  hide_on_disappear_behavior = make_behavior({name = "window-border.behaviors/hide-on-disappear", description = "Hide active border when the focused window disappears", ["respond-to"] = {"event.kind.window/not-visible"}, commands = {hide = "window-border.commands/hide-borders"}, fn = _741_})
  return {["update-on-focus-behavior"] = update_on_focus_behavior, ["update-on-move-behavior"] = update_on_move_behavior, ["hide-on-disappear-behavior"] = hide_on_disappear_behavior}
end
package.preload["behaviors.url-routing"] = package.preload["behaviors.url-routing"] or function(...)
  local _local_744_ = require("sheaf.behavior-registry")
  local make_behavior = _local_744_["make-behavior"]
  local _local_783_ = require("lib.url-routing")
  local build_browser_lookup = _local_783_["build-browser-lookup"]
  local resolve_browser = _local_783_["resolve-browser"]
  local resolve_browsers = _local_783_["resolve-browsers"]
  local make_chooser_choices = _local_783_["make-chooser-choices"]
  local parse_url = _local_783_["parse-url"]
  local match_rule_3f = _local_783_["match-rule?"]
  local find_matching_rule = _local_783_["find-matching-rule"]
  local function dispatch_open_in_app(action, url, lookup, target, send_cmd)
    print(("[DEBUG] url-routing: dispatch-open-in-app browser-id=" .. tostring(action["browser-id"])))
    local browser = resolve_browser(action["browser-id"], lookup)
    if browser then
      print(("[DEBUG] url-routing: opening in " .. tostring(browser.name) .. " (" .. tostring(browser["bundle-id"]) .. ")"))
      send_cmd(target, "open-in-app", {url = url, ["bundle-id"] = browser["bundle-id"]})
      return true
    else
      print(("[WARN] url-routing: browser '" .. tostring(action["browser-id"]) .. "' not resolved, falling back"))
      return false
    end
  end
  local function collect_browser_ids_for_choose(action, browsers)
    if ("all" == action["browser-ids"]) then
      local ids = {}
      for _, b in ipairs(browsers) do
        table.insert(ids, b.id)
      end
      return ids
    else
      return (action["browser-ids"] or {})
    end
  end
  local function dispatch_choose(action, url, browsers, lookup, target, send_cmd)
    print(("[DEBUG] url-routing: dispatch-choose browser-ids=" .. tostring(action["browser-ids"])))
    local browser_ids = collect_browser_ids_for_choose(action, browsers)
    local resolved = resolve_browsers(browser_ids, lookup)
    local choices = make_chooser_choices(resolved)
    print(("[DEBUG] url-routing: resolved " .. tostring(#resolved) .. " browsers, " .. tostring(#choices) .. " choices"))
    if (0 == #choices) then
      return print("[WARN] url-routing: no browsers resolved for chooser, skipping")
    else
      print(("[DEBUG] url-routing: sending show-chooser to " .. tostring(target)))
      return send_cmd(target, "show-chooser", {url = url, choices = choices})
    end
  end
  local function dispatch_action(action, url, browsers, lookup, candidates, send_cmd)
    if (nil == action) then
      print("[WARN] url-routing: nil action, cannot dispatch")
      return nil
    else
    end
    if (nil == action.type) then
      print("[WARN] url-routing: action missing :type field")
      return nil
    else
    end
    if ("open-in-app" == action.type) then
      local target = candidates["open-in-app"][1]
      if target then
        if not dispatch_open_in_app(action, url, lookup, target, send_cmd) then
          print("[INFO] url-routing: open-in-app failed, falling back to chooser")
          local chooser_target = candidates["show-chooser"][1]
          if chooser_target then
            return dispatch_choose({["browser-ids"] = "all"}, url, browsers, lookup, chooser_target, send_cmd)
          else
            return nil
          end
        else
          return nil
        end
      else
        return print("[WARN] url-routing: no candidate for :open-in-app")
      end
    elseif ("choose" == action.type) then
      local target = candidates["show-chooser"][1]
      if target then
        return dispatch_choose(action, url, browsers, lookup, target, send_cmd)
      else
        return print("[WARN] url-routing: no candidate for :show-chooser")
      end
    else
      return print(("[WARN] url-routing: unknown action type '" .. tostring(action.type) .. "'"))
    end
  end
  local route_url_behavior
  local function _794_(event, candidates, send_cmd, inputs)
    print("[DEBUG] url-routing: behavior invoked")
    local url
    do
      local t_795_ = event
      if (nil ~= t_795_) then
        t_795_ = t_795_["event-data"]
      else
      end
      if (nil ~= t_795_) then
        t_795_ = t_795_.url
      else
      end
      url = t_795_
    end
    local sender_bundle_id
    do
      local t_798_ = event
      if (nil ~= t_798_) then
        t_798_ = t_798_["event-data"]
      else
      end
      if (nil ~= t_798_) then
        t_798_ = t_798_["sender-bundle-id"]
      else
      end
      sender_bundle_id = t_798_
    end
    print(("[DEBUG] url-routing: url=" .. tostring(url) .. " sender=" .. tostring(sender_bundle_id)))
    if (nil == url) then
      print("[WARN] url-routing: event missing :url in event-data")
      return nil
    else
    end
    local function _804_()
      if inputs then
        local t_802_ = inputs
        if (nil ~= t_802_) then
          t_802_ = t_802_.rules
        else
        end
        return t_802_
      else
        return nil
      end
    end
    print(("[DEBUG] url-routing: inputs=" .. tostring(inputs) .. " inputs.rules=" .. tostring(_804_())))
    local rules_state
    if inputs then
      local t_805_ = inputs
      if (nil ~= t_805_) then
        t_805_ = t_805_.rules
      else
      end
      rules_state = t_805_
    else
      rules_state = nil
    end
    local browsers
    local _809_
    do
      local t_808_ = rules_state
      if (nil ~= t_808_) then
        t_808_ = t_808_.browsers
      else
      end
      _809_ = t_808_
    end
    browsers = (_809_ or {})
    local rules
    local _812_
    do
      local t_811_ = rules_state
      if (nil ~= t_811_) then
        t_811_ = t_811_.rules
      else
      end
      _812_ = t_811_
    end
    rules = (_812_ or {})
    local fallback
    do
      local t_814_ = rules_state
      if (nil ~= t_814_) then
        t_814_ = t_814_.fallback
      else
      end
      fallback = t_814_
    end
    local lookup = build_browser_lookup(browsers)
    local parsed = parse_url(url)
    local matched_rule = find_matching_rule(parsed, sender_bundle_id, rules)
    local action
    local _816_
    if matched_rule then
      _816_ = matched_rule.action
    else
      _816_ = nil
    end
    action = (_816_ or fallback or {type = "choose", ["browser-ids"] = "all"})
    if not (matched_rule or fallback) then
      print(("[WARN] url-routing: no matching rule and no fallback configured" .. " \226\128\148 using safety-net chooser for URL '" .. tostring(url) .. "'"))
    else
    end
    local function _819_()
      if matched_rule then
        return matched_rule.id
      else
        return nil
      end
    end
    local function _821_()
      local t_820_ = action
      if (nil ~= t_820_) then
        t_820_ = t_820_.type
      else
      end
      return t_820_
    end
    print(("[DEBUG] url-routing: browsers=" .. tostring(#browsers) .. " matched-rule=" .. tostring(_819_()) .. " action.type=" .. tostring(_821_())))
    return dispatch_action(action, url, browsers, lookup, candidates, send_cmd)
  end
  route_url_behavior = make_behavior({name = "url-dispatch.behaviors/route-url", description = "Route opened URLs to browsers based on structured routing rules", ["respond-to"] = {"event.kind.url/opened"}, commands = {["open-in-app"] = "url-dispatch.commands/open-in-app", ["show-chooser"] = "url-dispatch.commands/show-chooser"}, inputs = {rules = "shape/url-routing-rules"}, fn = _794_})
  return {["route-url-behavior"] = route_url_behavior}
end
package.preload["lib.url-routing"] = package.preload["lib.url-routing"] or function(...)
  local _local_745_ = require("lib.cljlib-shim")
  local some = _local_745_.some
  local seq = _local_745_.seq
  local empty_3f = _local_745_["empty?"]
  local function build_browser_lookup(browsers)
    local lookup = {}
    for _, browser in ipairs((browsers or {})) do
      if browser.id then
        lookup[browser.id] = browser
      else
      end
    end
    return lookup
  end
  local function resolve_browser(browser_id, lookup)
    local entry = lookup[browser_id]
    if (nil == entry) then
      print(("[WARN] resolve-browser: unknown browser-id '" .. tostring(browser_id) .. "'"))
      return nil
    else
    end
    local bundle_id = entry["bundle-id"]
    local name = hs.application.nameForBundleID(bundle_id)
    local path = hs.application.pathForBundleID(bundle_id)
    if ((nil == name) and (nil == path)) then
      print(("[WARN] resolve-browser: bundle-id '" .. tostring(bundle_id) .. "' not found on this system"))
      return nil
    else
    end
    local image
    if hs.image then
      image = hs.image.imageFromAppBundle(bundle_id)
    else
      image = nil
    end
    return {id = entry.id, ["bundle-id"] = bundle_id, name = (name or tostring(bundle_id)), path = path, image = image}
  end
  local function resolve_browsers(browser_ids, lookup)
    local resolved = {}
    for _, bid in ipairs(browser_ids) do
      local browser = resolve_browser(bid, lookup)
      if browser then
        table.insert(resolved, browser)
      else
      end
    end
    return resolved
  end
  local function make_chooser_choices(resolved_browsers)
    local choices = {}
    for _, browser in ipairs(resolved_browsers) do
      table.insert(choices, {text = browser.name, subText = browser["bundle-id"], image = browser.image, ["bundle-id"] = browser["bundle-id"]})
    end
    return choices
  end
  local function parse_url(url)
    if (nil == url) then
      return {}
    else
    end
    local scheme_end = url:find("://")
    local result = {}
    if scheme_end then
      local scheme = url:sub(1, (scheme_end - 1))
      local rest = url:sub((scheme_end + 3))
      local slash_pos = rest:find("/")
      local qmark_pos = rest:find("%?")
      local hash_pos = rest:find("#")
      local authority_end
      do
        local candidates = {}
        if slash_pos then
          table.insert(candidates, slash_pos)
        else
        end
        if qmark_pos then
          table.insert(candidates, qmark_pos)
        else
        end
        if hash_pos then
          table.insert(candidates, hash_pos)
        else
        end
        if (0 == #candidates) then
          authority_end = nil
        else
          authority_end = math.min(table.unpack(candidates))
        end
      end
      local host_part
      if authority_end then
        host_part = rest:sub(1, (authority_end - 1))
      else
        host_part = rest
      end
      local rest_after_authority
      if authority_end then
        rest_after_authority = rest:sub(authority_end)
      else
        rest_after_authority = "/"
      end
      local raw_path
      if (authority_end and ("/" ~= rest_after_authority:sub(1, 1))) then
        raw_path = ("/" .. rest_after_authority)
      else
        raw_path = rest_after_authority
      end
      local port_sep = host_part:find(":")
      local host
      if port_sep then
        host = host_part:sub(1, (port_sep - 1))
      else
        host = host_part
      end
      local query_pos = raw_path:find("%?")
      local frag_pos = raw_path:find("#")
      local path_end
      if (query_pos and frag_pos) then
        path_end = math.min(query_pos, frag_pos)
      elseif query_pos then
        path_end = query_pos
      elseif frag_pos then
        path_end = frag_pos
      else
        path_end = nil
      end
      local path
      if path_end then
        path = raw_path:sub(1, (path_end - 1))
      else
        path = raw_path
      end
      result["scheme"] = scheme:lower()
      result["host"] = host:lower()
      result["path"] = path
    else
      local colon_pos = url:find(":")
      if colon_pos then
        do
          local raw_scheme = url:sub(1, (colon_pos - 1))
          result["scheme"] = raw_scheme:lower()
        end
        local rest = url:sub((colon_pos + 1))
        result["path"] = rest
      else
      end
    end
    return result
  end
  local function escape_lua_pattern(str)
    return str:gsub("([%(%)%.%%%+%-%[%]%^%$%?])", "%%%1")
  end
  local function match_scheme_3f(url_scheme, pattern_scheme)
    if (nil == pattern_scheme) then
      return true
    else
    end
    if (nil == url_scheme) then
      return false
    else
    end
    if ("string" == type(pattern_scheme)) then
      return (url_scheme == pattern_scheme:lower())
    else
      local found = false
      for _, s in ipairs(pattern_scheme) do
        if (url_scheme == s:lower()) then
          found = true
        else
        end
      end
      return found
    end
  end
  local function match_host_3f(url_host, pattern_host)
    if (nil == pattern_host) then
      return true
    else
    end
    if (nil == url_host) then
      return false
    else
    end
    local lower_pattern = pattern_host:lower()
    if ("*." == lower_pattern:sub(1, 2)) then
      local suffix = lower_pattern:sub(2)
      local escaped = escape_lua_pattern(suffix)
      local bare_domain = lower_pattern:sub(3)
      return ((nil ~= url_host:match((escaped .. "$"))) or (url_host == bare_domain))
    else
      return (url_host == lower_pattern)
    end
  end
  local function match_path_3f(url_path, pattern_path)
    if (nil == pattern_path) then
      return true
    else
    end
    if (nil == url_path) then
      return false
    else
    end
    local parts = {}
    local pos = 1
    local i = 1
    while (i <= #pattern_path) do
      if ("*" == pattern_path:sub(i, i)) then
        table.insert(parts, escape_lua_pattern(pattern_path:sub(pos, (i - 1))))
        table.insert(parts, ".*")
        i = (i + 1)
        pos = i
      else
        i = (i + 1)
      end
    end
    table.insert(parts, escape_lua_pattern(pattern_path:sub(pos)))
    local full_pattern = ("^" .. table.concat(parts) .. "$")
    return (nil ~= url_path:match(full_pattern))
  end
  local function match_url_pattern_3f(parsed_url, url_pattern)
    return (match_scheme_3f(parsed_url.scheme, url_pattern.scheme) and match_host_3f(parsed_url.host, url_pattern.host) and match_path_3f(parsed_url.path, url_pattern.path))
  end
  local function match_urls_3f(parsed_url, url_patterns)
    if ((nil == url_patterns) or (0 == #url_patterns)) then
      return false
    else
    end
    local matched = false
    for _, pattern in ipairs(url_patterns) do
      if match_url_pattern_3f(parsed_url, pattern) then
        matched = true
      else
      end
    end
    return matched
  end
  local function match_sender_3f(sender_bundle_id, sender_bundle_ids)
    if (nil == sender_bundle_ids) then
      return true
    else
    end
    if (nil == sender_bundle_id) then
      return false
    else
    end
    local found = false
    for _, bid in ipairs(sender_bundle_ids) do
      if (sender_bundle_id == bid) then
        found = true
      else
      end
    end
    return found
  end
  local function match_rule_3f(parsed_url, sender_bundle_id, rule)
    local match_spec = rule.match
    if (nil == match_spec) then
      return true
    else
    end
    local _780_
    if match_spec.urls then
      _780_ = match_urls_3f(parsed_url, match_spec.urls)
    else
      _780_ = true
    end
    return (_780_ and match_sender_3f(sender_bundle_id, match_spec["sender-bundle-ids"]))
  end
  local function find_matching_rule(parsed_url, sender_bundle_id, rules)
    local result = nil
    for _, rule in ipairs((rules or {})) do
      if ((nil == result) and match_rule_3f(parsed_url, sender_bundle_id, rule)) then
        result = rule
      else
      end
    end
    return result
  end
  return {["build-browser-lookup"] = build_browser_lookup, ["resolve-browser"] = resolve_browser, ["resolve-browsers"] = resolve_browsers, ["make-chooser-choices"] = make_chooser_choices, ["parse-url"] = parse_url, ["escape-lua-pattern"] = escape_lua_pattern, ["match-scheme?"] = match_scheme_3f, ["match-host?"] = match_host_3f, ["match-path?"] = match_path_3f, ["match-url-pattern?"] = match_url_pattern_3f, ["match-urls?"] = match_urls_3f, ["match-sender?"] = match_sender_3f, ["match-rule?"] = match_rule_3f, ["find-matching-rule"] = find_matching_rule}
end
package.preload["behaviors.record-url"] = package.preload["behaviors.record-url"] or function(...)
  local _local_824_ = require("sheaf.behavior-registry")
  local make_behavior = _local_824_["make-behavior"]
  local record_url_behavior
  local function _825_(event, candidates, send_cmd)
    local url
    do
      local t_826_ = event
      if (nil ~= t_826_) then
        t_826_ = t_826_["event-data"]
      else
      end
      if (nil ~= t_826_) then
        t_826_ = t_826_.url
      else
      end
      url = t_826_
    end
    local target = candidates.record[1]
    if (target and url) then
      local _830_
      do
        local t_829_ = event
        if (nil ~= t_829_) then
          t_829_ = t_829_["event-data"]
        else
        end
        if (nil ~= t_829_) then
          t_829_ = t_829_["sender-bundle-id"]
        else
        end
        _830_ = t_829_
      end
      return send_cmd(target, "record", {url = url, ["sender-bundle-id"] = _830_, timestamp = event.timestamp})
    else
      return nil
    end
  end
  record_url_behavior = make_behavior({name = "url-history.behaviors/record-on-dispatch", description = "Record dispatched URLs into history for later browsing", ["respond-to"] = {"event.kind.url/opened"}, commands = {record = "url-history.commands/record-url"}, fn = _825_})
  return {["record-url-behavior"] = record_url_behavior}
end
package.preload["behaviors.show-history"] = package.preload["behaviors.show-history"] or function(...)
  local _local_835_ = require("sheaf.behavior-registry")
  local make_behavior = _local_835_["make-behavior"]
  local show_history_behavior
  local function _836_(event, candidates, send_cmd)
    local target = candidates["show-history"][1]
    if target then
      return send_cmd(target, "show-history", {})
    else
      return nil
    end
  end
  show_history_behavior = make_behavior({name = "url-history.behaviors/show-history", description = "Show URL history browser when hotkey is pressed", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["show-history"] = "url-history.commands/show-history"}, fn = _836_})
  return {["show-history-behavior"] = show_history_behavior}
end
package.preload["behaviors.window-state"] = package.preload["behaviors.window-state"] or function(...)
  local _local_839_ = require("sheaf.behavior-registry")
  local make_behavior = _local_839_["make-behavior"]
  local initialize_behavior
  local function _840_(event, candidates, send_cmd)
    local target = candidates.initialize[1]
    local and_841_ = target
    if and_841_ then
      local t_842_ = event
      if (nil ~= t_842_) then
        t_842_ = t_842_["event-data"]
      else
      end
      if (nil ~= t_842_) then
        t_842_ = t_842_.windows
      else
      end
      and_841_ = t_842_
    end
    if and_841_ then
      return send_cmd(target, "initialize", {windows = event["event-data"].windows})
    else
      return nil
    end
  end
  initialize_behavior = make_behavior({name = "window-state.behaviors/initialize", description = "Populate window state from initial snapshot", ["respond-to"] = {"event.kind.window/initial"}, commands = {initialize = "window-state.commands/initialize-windows"}, fn = _840_})
  local track_on_change_behavior
  local function _846_(event, candidates, send_cmd)
    local d = event["event-data"]
    local target = candidates.upsert[1]
    local fullscreen
    do
      local case_847_ = event["event-name"]
      if (case_847_ == "window-watcher.events/fullscreened") then
        fullscreen = true
      elseif (case_847_ == "window-watcher.events/unfullscreened") then
        fullscreen = false
      else
        local _ = case_847_
        fullscreen = nil
      end
    end
    if (target and d["window-id"]) then
      return send_cmd(target, "upsert", {["window-id"] = d["window-id"], ["app-name"] = d["app-name"], ["bundle-id"] = d["bundle-id"], ["window-title"] = d["window-title"], frame = d.frame, fullscreen = fullscreen})
    else
      return nil
    end
  end
  track_on_change_behavior = make_behavior({name = "window-state.behaviors/track-on-change", description = "Track window on focus, visible, or fullscreen change", ["respond-to"] = {"event.kind.window/focused", "event.kind.window/visible", "event.kind.window/fullscreened", "event.kind.window/unfullscreened"}, commands = {upsert = "window-state.commands/upsert-window"}, fn = _846_})
  local track_on_move_behavior
  local function _850_(event, candidates, send_cmd)
    local d = event["event-data"]
    local target = candidates.upsert[1]
    if (target and d["window-id"]) then
      return send_cmd(target, "upsert", {["window-id"] = d["window-id"], frame = d.frame})
    else
      return nil
    end
  end
  track_on_move_behavior = make_behavior({name = "window-state.behaviors/track-on-move", description = "Track window frame on move or resize", ["respond-to"] = {"event.kind.window/moved"}, commands = {upsert = "window-state.commands/upsert-window"}, fn = _850_})
  local untrack_on_disappear_behavior
  local function _852_(event, candidates, send_cmd)
    local target = candidates.remove[1]
    local and_853_ = target
    if and_853_ then
      local t_854_ = event
      if (nil ~= t_854_) then
        t_854_ = t_854_["event-data"]
      else
      end
      if (nil ~= t_854_) then
        t_854_ = t_854_["window-id"]
      else
      end
      and_853_ = t_854_
    end
    if and_853_ then
      return send_cmd(target, "remove", {["window-id"] = event["event-data"]["window-id"]})
    else
      return nil
    end
  end
  untrack_on_disappear_behavior = make_behavior({name = "window-state.behaviors/untrack-on-disappear", description = "Remove window from tracking on disappear", ["respond-to"] = {"event.kind.window/not-visible"}, commands = {remove = "window-state.commands/remove-window"}, fn = _852_})
  local track_focus_behavior
  local function _858_(event, candidates, send_cmd)
    local target = candidates["set-focused"][1]
    local window_id
    do
      local t_859_ = event
      if (nil ~= t_859_) then
        t_859_ = t_859_["event-data"]
      else
      end
      if (nil ~= t_859_) then
        t_859_ = t_859_["window-id"]
      else
      end
      window_id = t_859_
    end
    if (target and window_id) then
      return send_cmd(target, "set-focused", {["window-id"] = window_id})
    else
      return nil
    end
  end
  track_focus_behavior = make_behavior({name = "window-state.behaviors/track-focus", description = "Track which window is currently focused", ["respond-to"] = {"event.kind.window/focused"}, commands = {["set-focused"] = "window-state.commands/set-focused-window"}, fn = _858_})
  return {["initialize-behavior"] = initialize_behavior, ["track-on-change-behavior"] = track_on_change_behavior, ["track-on-move-behavior"] = track_on_move_behavior, ["untrack-on-disappear-behavior"] = untrack_on_disappear_behavior, ["track-focus-behavior"] = track_focus_behavior}
end
package.preload["behaviors.paper-wm"] = package.preload["behaviors.paper-wm"] or function(...)
  local _local_864_ = require("sheaf.behavior-registry")
  local make_behavior = _local_864_["make-behavior"]
  local function make_hotkey_behavior(name, description, cmd_alias, cmd_name)
    local function _865_(event, candidates, send_cmd, inputs, params)
      local target = candidates[cmd_alias][1]
      if target then
        return send_cmd(target, cmd_alias, (params or {}))
      else
        return nil
      end
    end
    return make_behavior({name = name, description = description, ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {[cmd_alias] = cmd_name}, fn = _865_})
  end
  local focus_behavior = make_hotkey_behavior("paper-wm.behaviors/focus", "Focus window in a direction", "focus", "paper-wm.commands/focus")
  local swap_behavior = make_hotkey_behavior("paper-wm.behaviors/swap", "Swap focused window in a direction", "swap", "paper-wm.commands/swap")
  local center_window_behavior = make_hotkey_behavior("paper-wm.behaviors/center-window", "Center focused window on screen", "center-window", "paper-wm.commands/center-window")
  local set_full_width_behavior = make_hotkey_behavior("paper-wm.behaviors/set-full-width", "Set focused window to full width", "set-full-width", "paper-wm.commands/set-full-width")
  local cycle_window_size_behavior = make_hotkey_behavior("paper-wm.behaviors/cycle-window-size", "Cycle focused window size", "cycle-window-size", "paper-wm.commands/cycle-window-size")
  local slurp_window_behavior = make_hotkey_behavior("paper-wm.behaviors/slurp-window", "Slurp window into left column", "slurp-window", "paper-wm.commands/slurp-window")
  local barf_window_behavior = make_hotkey_behavior("paper-wm.behaviors/barf-window", "Barf window out of column", "barf-window", "paper-wm.commands/barf-window")
  local increment_space_behavior = make_hotkey_behavior("paper-wm.behaviors/increment-space", "Switch to an adjacent space", "increment-space", "paper-wm.commands/increment-space")
  local switch_to_space_behavior
  local function _867_(event, candidates, send_cmd, inputs, params)
    local target = candidates["switch-to-space"][1]
    if target then
      return send_cmd(target, "switch-to-space", {index = params.index})
    else
      return nil
    end
  end
  switch_to_space_behavior = make_behavior({name = "paper-wm.behaviors/switch-to-space", description = "Switch to a specific space", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["switch-to-space"] = "paper-wm.commands/switch-to-space"}, fn = _867_})
  local initialize_layout_behavior
  local function _869_(event, candidates, send_cmd)
    local target = candidates["initialize-layout"][1]
    local windows
    do
      local t_870_ = event
      if (nil ~= t_870_) then
        t_870_ = t_870_["event-data"]
      else
      end
      if (nil ~= t_870_) then
        t_870_ = t_870_.windows
      else
      end
      windows = t_870_
    end
    if (target and windows) then
      return send_cmd(target, "initialize-layout", {windows = windows, ["observed-spaces"] = (event["event-data"]["observed-spaces"] or {})})
    else
      return nil
    end
  end
  initialize_layout_behavior = make_behavior({name = "paper-wm.behaviors/initialize-layout", description = "Initialize PaperWM from the shared window snapshot", ["respond-to"] = {"event.kind.window/initial"}, commands = {["initialize-layout"] = "paper-wm.commands/initialize-layout"}, fn = _869_})
  local reconcile_membership_behavior
  local function _874_(event, candidates, send_cmd)
    local target = candidates["reconcile-window"][1]
    local fact = event["event-data"]
    if (target and fact) then
      return send_cmd(target, "reconcile-window", {window = fact})
    else
      return nil
    end
  end
  reconcile_membership_behavior = make_behavior({name = "paper-wm.behaviors/reconcile-membership", description = "Reconcile PaperWM membership from shared window facts", ["respond-to"] = {"event.kind.window/visible", "event.kind.window/not-visible", "event.kind.window/fullscreened", "event.kind.window/unfullscreened", "event.kind.window/destroyed", "event.kind.window/minimized", "event.kind.window/deminimized"}, commands = {["reconcile-window"] = "paper-wm.commands/reconcile-window"}, fn = _874_})
  local record_focus_behavior
  local function _876_(event, candidates, send_cmd)
    local target = candidates["record-focus"][1]
    local fact = event["event-data"]
    if (target and fact and fact["window-id"]) then
      return send_cmd(target, "record-focus", {window = fact})
    else
      return nil
    end
  end
  record_focus_behavior = make_behavior({name = "paper-wm.behaviors/record-focus", description = "Reconcile the focused window's fact and record PaperWM focus", ["respond-to"] = {"event.kind.window/focused"}, commands = {["record-focus"] = "paper-wm.commands/record-focus"}, fn = _876_})
  local retile_observed_frame_behavior
  local function _878_(event, candidates, send_cmd)
    local target = candidates.retile[1]
    if target then
      return send_cmd(target, "retile", event["event-data"])
    else
      return nil
    end
  end
  retile_observed_frame_behavior = make_behavior({name = "paper-wm.behaviors/retile-observed-frame", description = "Retile from the latest coalesced PaperWM frame", ["respond-to"] = {"paper-wm.events/frame-observed"}, commands = {retile = "paper-wm.commands/retile-observed-frame"}, fn = _878_})
  local retry_space_focus_behavior
  local function _880_(event, candidates, send_cmd)
    local target = candidates.retry[1]
    local generation
    do
      local t_881_ = event
      if (nil ~= t_881_) then
        t_881_ = t_881_["event-data"]
      else
      end
      if (nil ~= t_881_) then
        t_881_ = t_881_.generation
      else
      end
      generation = t_881_
    end
    if (target and generation) then
      return send_cmd(target, "retry", {generation = generation})
    else
      return nil
    end
  end
  retry_space_focus_behavior = make_behavior({name = "paper-wm.behaviors/retry-space-focus", description = "Advance a PaperWM Space focus conversation", ["respond-to"] = {"paper-wm.events/space-focus-retry"}, commands = {retry = "paper-wm.commands/retry-space-focus"}, fn = _880_})
  local refresh_on_screen_change_behavior
  local function _885_(event, candidates, send_cmd)
    local target = candidates["refresh-windows"][1]
    local windows
    do
      local t_886_ = event
      if (nil ~= t_886_) then
        t_886_ = t_886_["event-data"]
      else
      end
      if (nil ~= t_886_) then
        t_886_ = t_886_.windows
      else
      end
      windows = t_886_
    end
    if (target and windows) then
      return send_cmd(target, "refresh-windows", {windows = windows, ["observed-spaces"] = (event["event-data"]["observed-spaces"] or {})})
    else
      return nil
    end
  end
  refresh_on_screen_change_behavior = make_behavior({name = "paper-wm.behaviors/refresh-on-screen-change", description = "Reconcile PaperWM when screen layout changes", ["respond-to"] = {"event.kind.screen/layout-changed"}, commands = {["refresh-windows"] = "paper-wm.commands/refresh-windows"}, fn = _885_})
  local refresh_on_window_placed_behavior
  local function _890_(event, candidates, send_cmd)
    local target = candidates["refresh-windows"][1]
    local windows
    do
      local t_891_ = event
      if (nil ~= t_891_) then
        t_891_ = t_891_["event-data"]
      else
      end
      if (nil ~= t_891_) then
        t_891_ = t_891_.windows
      else
      end
      windows = t_891_
    end
    if (target and windows) then
      return send_cmd(target, "refresh-windows", {windows = windows, ["observed-spaces"] = (event["event-data"]["observed-spaces"] or {})})
    else
      return nil
    end
  end
  refresh_on_window_placed_behavior = make_behavior({name = "paper-wm.behaviors/refresh-on-window-placed", description = "Reconcile PaperWM after cross-screen window placement", ["respond-to"] = {"event.kind.window/placed"}, commands = {["refresh-windows"] = "paper-wm.commands/refresh-windows"}, fn = _890_})
  return {["initialize-layout-behavior"] = initialize_layout_behavior, ["reconcile-membership-behavior"] = reconcile_membership_behavior, ["record-focus-behavior"] = record_focus_behavior, ["retile-observed-frame-behavior"] = retile_observed_frame_behavior, ["retry-space-focus-behavior"] = retry_space_focus_behavior, ["focus-behavior"] = focus_behavior, ["swap-behavior"] = swap_behavior, ["center-window-behavior"] = center_window_behavior, ["set-full-width-behavior"] = set_full_width_behavior, ["cycle-window-size-behavior"] = cycle_window_size_behavior, ["slurp-window-behavior"] = slurp_window_behavior, ["barf-window-behavior"] = barf_window_behavior, ["increment-space-behavior"] = increment_space_behavior, ["switch-to-space-behavior"] = switch_to_space_behavior, ["refresh-on-screen-change-behavior"] = refresh_on_screen_change_behavior, ["refresh-on-window-placed-behavior"] = refresh_on_window_placed_behavior}
end
require("behaviors")
package.preload["subscriptions"] = package.preload["subscriptions"] or function(...)
  local _local_922_ = require("sheaf.subscription-registry")
  local make_subscription_registry = _local_922_["make-subscription-registry"]
  local define_subscription_21 = _local_922_["define-subscription!"]
  local _local_923_ = require("events")
  local event_registry = _local_923_["event-registry"]
  local _local_924_ = require("behaviors")
  local behavior_registry = _local_924_["behavior-registry"]
  local _local_925_ = require("components")
  local tag_registry = _local_925_["tag-registry"]
  local subscription_registry = make_subscription_registry({["event-registry"] = event_registry, ["behavior-registry"] = behavior_registry, ["tag-registry"] = tag_registry})
  define_subscription_21(subscription_registry, "sub/reload-on-config-change", {description = "Reload Hammerspoon when init.lua changes", behavior = "reload-hammerspoon.behaviors/reload-hammerspoon", ["source-tag"] = "tag/config-watcher", ["target-tag"] = "tag/reload-hammerspoon", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/compile-on-fnl-change", {description = "Recompile Fennel when .fnl files change", behavior = "compile-fennel.behaviors/compile-fennel", ["source-tag"] = "tag/config-watcher", ["target-tag"] = "tag/compile-fennel", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/toggle-expose-on-hotkey", {description = "Toggle Expose when ctrl+cmd+e is pressed", behavior = "expose.behaviors/toggle-expose", ["source-tag"] = "tag/expose-hotkey", ["target-tag"] = "tag/expose", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-space-change", {description = "Update space indicator when space changes", behavior = "space-indicator.behaviors/update-on-change", ["source-tag"] = "tag/space-watcher", ["target-tag"] = "tag/space-indicator", ["event-selector"] = "event.kind.space/changed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-screen-change", {description = "Update space indicator when screen layout changes", behavior = "space-indicator.behaviors/update-on-change", ["source-tag"] = "tag/screen-watcher", ["target-tag"] = "tag/space-indicator", ["event-selector"] = "event.kind.screen/layout-changed"})
  define_subscription_21(subscription_registry, "sub/reconcile-spaces-on-space-change", {description = "Derive space topology changes when the active space changes", behavior = "desktop-layout.behaviors/reconcile-spaces", ["source-tag"] = "tag/space-watcher", ["target-tag"] = "tag/desktop-layout", ["input-tag"] = "tag/desktop-layout", ["event-selector"] = "space-watcher.events/space-changed"})
  define_subscription_21(subscription_registry, "sub/reconcile-spaces-on-screen-change", {description = "Derive space topology changes when the screen layout changes", behavior = "desktop-layout.behaviors/reconcile-spaces", ["source-tag"] = "tag/screen-watcher", ["target-tag"] = "tag/desktop-layout", ["input-tag"] = "tag/desktop-layout", ["event-selector"] = "screen-watcher.events/screen-changed"})
  define_subscription_21(subscription_registry, "sub/open-emacs-on-hotkey", {description = "Open emacsclient frame when cmd+alt+return is pressed", behavior = "emacs.behaviors/open-emacs", ["source-tag"] = "tag/emacs-hotkey", ["target-tag"] = "tag/emacs", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/border-on-focus", {description = "Show active border when a window gains focus", behavior = "window-border.behaviors/update-on-focus", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/focused"})
  define_subscription_21(subscription_registry, "sub/border-on-visible", {description = "Show active border when a window becomes visible", behavior = "window-border.behaviors/update-on-focus", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/visible"})
  define_subscription_21(subscription_registry, "sub/border-on-move", {description = "Reposition active border when a window moves or resizes", behavior = "window-border.behaviors/update-on-move", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/moved"})
  define_subscription_21(subscription_registry, "sub/border-on-disappear", {description = "Hide active border when the focused window disappears", behavior = "window-border.behaviors/hide-on-disappear", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/not-visible"})
  define_subscription_21(subscription_registry, "sub/route-url-on-open", {description = "Route opened URLs to browsers based on rules", behavior = "url-dispatch.behaviors/route-url", ["source-tag"] = "tag/url-handler", ["target-tag"] = "tag/url-dispatch", ["input-tag"] = "tag/url-routing-rules", ["event-selector"] = "event.kind.url/opened"})
  define_subscription_21(subscription_registry, "sub/record-url-on-dispatch", {description = "Record dispatched URLs into history", behavior = "url-history.behaviors/record-on-dispatch", ["source-tag"] = "tag/url-handler", ["target-tag"] = "tag/url-history", ["event-selector"] = "event.kind.url/opened"})
  define_subscription_21(subscription_registry, "sub/show-history-on-hotkey", {description = "Show URL history browser on Cmd+Ctrl+L", behavior = "url-history.behaviors/show-history", ["source-tag"] = "tag/url-history-hotkey", ["target-tag"] = "tag/url-history", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/window-state-initialize", {description = "Populate window state from initial snapshot", behavior = "window-state.behaviors/initialize", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/initial"})
  define_subscription_21(subscription_registry, "sub/window-state-on-focus", {description = "Track window on focus", behavior = "window-state.behaviors/track-on-change", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/focused"})
  define_subscription_21(subscription_registry, "sub/window-state-on-visible", {description = "Track window on visible", behavior = "window-state.behaviors/track-on-change", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/visible"})
  define_subscription_21(subscription_registry, "sub/window-state-on-fullscreen", {description = "Track window fullscreen state", behavior = "window-state.behaviors/track-on-change", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/fullscreened"})
  define_subscription_21(subscription_registry, "sub/window-state-on-unfullscreen", {description = "Track window unfullscreen state", behavior = "window-state.behaviors/track-on-change", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/unfullscreened"})
  define_subscription_21(subscription_registry, "sub/window-state-on-move", {description = "Track window frame on move/resize", behavior = "window-state.behaviors/track-on-move", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/moved"})
  define_subscription_21(subscription_registry, "sub/window-state-on-disappear", {description = "Remove window from tracking on disappear", behavior = "window-state.behaviors/untrack-on-disappear", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/not-visible"})
  define_subscription_21(subscription_registry, "sub/window-state-track-focus", {description = "Track focused window ID in window state", behavior = "window-state.behaviors/track-focus", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/focused"})
  define_subscription_21(subscription_registry, "sub/paper-wm-initialize-layout", {description = "Initialize PaperWM from shared window facts", behavior = "paper-wm.behaviors/initialize-layout", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.window/initial"})
  for _, event_kind in ipairs({"event.kind.window/visible", "event.kind.window/not-visible", "event.kind.window/fullscreened", "event.kind.window/unfullscreened", "event.kind.window/destroyed", "event.kind.window/minimized", "event.kind.window/deminimized"}) do
    define_subscription_21(subscription_registry, ("sub/paper-wm-reconcile-" .. tostring(event_kind)), {description = ("Reconcile PaperWM membership for " .. tostring(event_kind)), behavior = "paper-wm.behaviors/reconcile-membership", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/paper-wm", ["event-selector"] = event_kind})
  end
  define_subscription_21(subscription_registry, "sub/paper-wm-record-focus", {description = "Record PaperWM focus from shared window facts", behavior = "paper-wm.behaviors/record-focus", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.window/focused"})
  define_subscription_21(subscription_registry, "sub/paper-wm-retile-observed-frame", {description = "Retile PaperWM from coalesced component-owned frame observations", behavior = "paper-wm.behaviors/retile-observed-frame", ["source-tag"] = "tag/paper-wm-outbox", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "paper-wm.events/frame-observed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-retry-space-focus", {description = "Advance PaperWM Space focus on a retry occurrence", behavior = "paper-wm.behaviors/retry-space-focus", ["source-tag"] = "tag/paper-wm-outbox", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "paper-wm.events/space-focus-retry"})
  define_subscription_21(subscription_registry, "sub/focus-window-on-hover", {description = "Focus a standard window after the cursor dwells over it", behavior = "mouse-window-management.behaviors/focus-hovered-window", ["source-tag"] = "tag/mouse-window-watcher", ["target-tag"] = "tag/mouse-window-management", ["input-tag"] = "tag/window-state", ["event-selector"] = "event.kind.mouse/window-hovered"})
  define_subscription_21(subscription_registry, "sub/center-cursor-on-window-focus", {description = "Center cursor for focus changes not initiated by hover", behavior = "mouse-window-management.behaviors/center-cursor-on-focus", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/mouse-window-management", ["input-tag"] = "tag/mouse-window-management", ["event-selector"] = "event.kind.window/focused"})
  define_subscription_21(subscription_registry, "sub/schedule-created-window-placement", {description = "Delay placement of a likely-new window", behavior = "mouse-window-management.behaviors/schedule-created-window", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/mouse-window-management", ["input-tag"] = "tag/window-state", ["event-selector"] = "event.kind.window/created"})
  define_subscription_21(subscription_registry, "sub/note-space-change-for-window-placement", {description = "Suppress placement of windows discovered during a Space switch", behavior = "mouse-window-management.behaviors/note-space-change", ["source-tag"] = "tag/space-watcher", ["target-tag"] = "tag/mouse-window-management", ["event-selector"] = "event.kind.space/changed"})
  define_subscription_21(subscription_registry, "sub/place-settled-window-at-cursor", {description = "Place a settled likely-new window on the cursor's screen", behavior = "mouse-window-management.behaviors/place-created-window", ["source-tag"] = "tag/mouse-window-management", ["target-tag"] = "tag/mouse-window-management", ["input-tag"] = "tag/mouse-window-management", ["event-selector"] = "event.kind.window/placement-ready"})
  define_subscription_21(subscription_registry, "sub/refresh-paper-wm-after-window-placement", {description = "Re-index PaperWM after cross-screen window placement", behavior = "paper-wm.behaviors/refresh-on-window-placed", ["source-tag"] = "tag/mouse-window-management", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.window/placed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-focus-left", {description = "Focus window left on Alt+Cmd+Left", behavior = "paper-wm.behaviors/focus", params = {direction = "left"}, ["source-tag"] = "tag/paper-wm-focus-left", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-focus-right", {description = "Focus window right on Alt+Cmd+Right", behavior = "paper-wm.behaviors/focus", params = {direction = "right"}, ["source-tag"] = "tag/paper-wm-focus-right", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-focus-up", {description = "Focus window above on Alt+Cmd+Up", behavior = "paper-wm.behaviors/focus", params = {direction = "up"}, ["source-tag"] = "tag/paper-wm-focus-up", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-focus-down", {description = "Focus window below on Alt+Cmd+Down", behavior = "paper-wm.behaviors/focus", params = {direction = "down"}, ["source-tag"] = "tag/paper-wm-focus-down", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-swap-left", {description = "Swap window left on Alt+Cmd+Shift+Left", behavior = "paper-wm.behaviors/swap", params = {direction = "left"}, ["source-tag"] = "tag/paper-wm-swap-left", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-swap-right", {description = "Swap window right on Alt+Cmd+Shift+Right", behavior = "paper-wm.behaviors/swap", params = {direction = "right"}, ["source-tag"] = "tag/paper-wm-swap-right", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-swap-up", {description = "Swap window up on Alt+Cmd+Shift+Up", behavior = "paper-wm.behaviors/swap", params = {direction = "up"}, ["source-tag"] = "tag/paper-wm-swap-up", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-swap-down", {description = "Swap window down on Alt+Cmd+Shift+Down", behavior = "paper-wm.behaviors/swap", params = {direction = "down"}, ["source-tag"] = "tag/paper-wm-swap-down", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-center-window", {description = "Center window on Alt+Cmd+C", behavior = "paper-wm.behaviors/center-window", ["source-tag"] = "tag/paper-wm-center-window", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-set-full-width", {description = "Set full width on Alt+Cmd+F", behavior = "paper-wm.behaviors/set-full-width", ["source-tag"] = "tag/paper-wm-set-full-width", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-cycle-width-up", {description = "Cycle width up on Alt+Cmd+R", behavior = "paper-wm.behaviors/cycle-window-size", params = {direction = "width", ["cycle-direction"] = "ascending"}, ["source-tag"] = "tag/paper-wm-cycle-width-up", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-cycle-width-down", {description = "Cycle width down on Ctrl+Alt+Cmd+R", behavior = "paper-wm.behaviors/cycle-window-size", params = {direction = "width", ["cycle-direction"] = "descending"}, ["source-tag"] = "tag/paper-wm-cycle-width-down", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-cycle-height-up", {description = "Cycle height up on Alt+Cmd+Shift+R", behavior = "paper-wm.behaviors/cycle-window-size", params = {direction = "height", ["cycle-direction"] = "ascending"}, ["source-tag"] = "tag/paper-wm-cycle-height-up", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-cycle-height-down", {description = "Cycle height down on Ctrl+Alt+Cmd+Shift+R", behavior = "paper-wm.behaviors/cycle-window-size", params = {direction = "height", ["cycle-direction"] = "descending"}, ["source-tag"] = "tag/paper-wm-cycle-height-down", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-slurp", {description = "Slurp window on Alt+Cmd+I", behavior = "paper-wm.behaviors/slurp-window", ["source-tag"] = "tag/paper-wm-slurp", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-barf", {description = "Barf window on Alt+Cmd+O", behavior = "paper-wm.behaviors/barf-window", ["source-tag"] = "tag/paper-wm-barf", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-prev-space", {description = "Previous space on Alt+Cmd+,", behavior = "paper-wm.behaviors/increment-space", params = {direction = "left"}, ["source-tag"] = "tag/paper-wm-prev-space", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/paper-wm-next-space", {description = "Next space on Alt+Cmd+.", behavior = "paper-wm.behaviors/increment-space", params = {direction = "right"}, ["source-tag"] = "tag/paper-wm-next-space", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  for i = 1, 9 do
    define_subscription_21(subscription_registry, ("sub/paper-wm-switch-to-space-" .. tostring(i)), {description = ("Switch to space " .. tostring(i) .. " on Alt+Cmd+" .. tostring(i)), behavior = "paper-wm.behaviors/switch-to-space", params = {index = i}, ["source-tag"] = ("tag/paper-wm-switch-to-space-" .. tostring(i)), ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.hotkey/pressed"})
  end
  define_subscription_21(subscription_registry, "sub/paper-wm-refresh-on-screen-change", {description = "Refresh PaperWM tiling when screen layout changes", behavior = "paper-wm.behaviors/refresh-on-screen-change", ["source-tag"] = "tag/screen-watcher", ["target-tag"] = "tag/paper-wm", ["event-selector"] = "event.kind.screen/layout-changed"})
  return {["subscription-registry"] = subscription_registry}
end
package.preload["sheaf.subscription-registry"] = package.preload["sheaf.subscription-registry"] or function(...)
  local _local_896_ = require("lib.cljlib-shim")
  local hash_set = _local_896_["hash-set"]
  local conj = _local_896_.conj
  local disj = _local_896_.disj
  local into = _local_896_.into
  local seq = _local_896_.seq
  local _local_897_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_897_["valid-event-selector?"]
  local _local_898_ = require("sheaf.behavior-registry")
  local behavior_defined_3f = _local_898_["behavior-defined?"]
  local _local_899_ = require("sheaf.tag-registry")
  local get_tags = _local_899_["get-tags"]
  local _local_900_ = require("lib.hierarchy")
  local ancestors = _local_900_.ancestors
  local function make_subscription_registry(opts)
    if (nil == opts["event-registry"]) then
      error("make-subscription-registry: :event-registry is required")
    else
    end
    if (nil == opts["behavior-registry"]) then
      error("make-subscription-registry: :behavior-registry is required")
    else
    end
    if (nil == opts["tag-registry"]) then
      error("make-subscription-registry: :tag-registry is required")
    else
    end
    return {subscriptions = {}, index = {}, ["event-registry"] = opts["event-registry"], ["behavior-registry"] = opts["behavior-registry"], ["tag-registry"] = opts["tag-registry"]}
  end
  local function index_add_21(registry, subscription)
    local tag = subscription["source-tag"]
    local event = subscription["event-selector"]
    local sub_name = subscription.name
    if (nil == registry.index[tag]) then
      registry.index[tag] = {}
    else
    end
    if (nil == registry.index[tag][event]) then
      registry.index[tag][event] = hash_set()
    else
    end
    registry.index[tag][event] = conj(registry.index[tag][event], sub_name)
    return nil
  end
  local function index_remove_21(registry, subscription)
    local tag = subscription["source-tag"]
    local event = subscription["event-selector"]
    local sub_name = subscription.name
    local sub_set
    do
      local t_906_ = registry.index
      if (nil ~= t_906_) then
        t_906_ = t_906_[tag]
      else
      end
      if (nil ~= t_906_) then
        t_906_ = t_906_[event]
      else
      end
      sub_set = t_906_
    end
    if sub_set then
      do
        local new_set = disj(sub_set, sub_name)
        local _909_
        if seq(new_set) then
          _909_ = new_set
        else
          _909_ = nil
        end
        registry.index[tag][event] = _909_
      end
      if (nil == registry.index[tag][event]) then
        if (nil == next(registry.index[tag])) then
          registry.index[tag] = nil
          return nil
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  end
  local function validate_required_field_21(name, opts, field)
    if (nil == opts[field]) then
      return error(("define-subscription! " .. tostring(name) .. ": missing required field " .. tostring(field)))
    else
      return nil
    end
  end
  local function validate_subscription_21(registry, name, opts)
    validate_required_field_21(name, opts, "description")
    validate_required_field_21(name, opts, "behavior")
    validate_required_field_21(name, opts, "event-selector")
    validate_required_field_21(name, opts, "source-tag")
    validate_required_field_21(name, opts, "target-tag")
    if (nil ~= registry.subscriptions[name]) then
      error(("Subscription already defined: " .. tostring(name)))
    else
    end
    if not behavior_defined_3f(registry["behavior-registry"], opts.behavior) then
      error(("define-subscription! " .. tostring(name) .. ": behavior not found: " .. tostring(opts.behavior)))
    else
    end
    if not valid_event_selector_3f(registry["event-registry"], opts["event-selector"]) then
      return error(("define-subscription! " .. tostring(name) .. ": invalid event-selector: " .. tostring(opts["event-selector"])))
    else
      return nil
    end
  end
  local function define_subscription_21(registry, name, opts)
    validate_subscription_21(registry, name, opts)
    local subscription = {name = name, description = opts.description, behavior = opts.behavior, ["event-selector"] = opts["event-selector"], ["source-tag"] = opts["source-tag"], ["target-tag"] = opts["target-tag"], ["input-tag"] = opts["input-tag"], params = opts.params}
    registry.subscriptions[name] = subscription
    index_add_21(registry, subscription)
    return print(("[INFO] Defined subscription: " .. tostring(name)))
  end
  local function remove_subscription_21(registry, name)
    local subscription = registry.subscriptions[name]
    if (nil == subscription) then
      error(("Subscription not found: " .. tostring(name)))
    else
    end
    index_remove_21(registry, subscription)
    registry.subscriptions[name] = nil
    return print(("[INFO] Removed subscription: " .. tostring(name)))
  end
  local function get_subscription(registry, name)
    return registry.subscriptions[name]
  end
  local function list_subscriptions(registry)
    local names = {}
    for name, _ in pairs(registry.subscriptions) do
      table.insert(names, name)
    end
    return names
  end
  local function subscription_defined_3f(registry, name)
    return (nil ~= registry.subscriptions[name])
  end
  local function get_matching_subscriptions(registry, source_instance_name, event_name)
    local tags = get_tags(registry["tag-registry"], source_instance_name)
    local event_selectors = conj(ancestors(registry["event-registry"].hierarchy, event_name), event_name)
    local all_sub_names
    do
      local result = hash_set()
      for tag, _ in pairs(tags) do
        local tag_subs = (registry.index[tag] or {})
        local inner = result
        for _0, e in pairs(event_selectors) do
          inner = into(inner, (tag_subs[e] or hash_set()))
        end
        result = inner
      end
      all_sub_names = result
    end
    local names = seq(all_sub_names)
    if names then
      local tbl_26_ = {}
      local i_27_ = 0
      for _, sub_name in ipairs(names) do
        local val_28_
        do
          local sub = registry.subscriptions[sub_name]
          if sub then
            val_28_ = {behavior = sub.behavior, ["target-tag"] = sub["target-tag"], ["input-tag"] = sub["input-tag"], params = sub.params}
          else
            val_28_ = nil
          end
        end
        if (nil ~= val_28_) then
          i_27_ = (i_27_ + 1)
          tbl_26_[i_27_] = val_28_
        else
        end
      end
      return tbl_26_
    else
      return nil
    end
  end
  return {["make-subscription-registry"] = make_subscription_registry, ["define-subscription!"] = define_subscription_21, ["remove-subscription!"] = remove_subscription_21, ["get-subscription"] = get_subscription, ["list-subscriptions"] = list_subscriptions, ["subscription-defined?"] = subscription_defined_3f, ["get-matching-subscriptions"] = get_matching_subscriptions}
end
local _local_926_ = require("subscriptions")
local subscription_registry = _local_926_["subscription-registry"]
package.preload["sheaf.dispatcher"] = package.preload["sheaf.dispatcher"] or function(...)
  local _local_927_ = require("sheaf.event-registry")
  local add_event_handler_21 = _local_927_["add-event-handler!"]
  local _local_928_ = require("sheaf.behavior-registry")
  local behavior_responds_to_3f = _local_928_["behavior-responds-to?"]
  local get_behavior = _local_928_["get-behavior"]
  local _local_929_ = require("sheaf.subscription-registry")
  local get_matching_subscriptions = _local_929_["get-matching-subscriptions"]
  local _local_930_ = require("sheaf.command-registry")
  local get_command = _local_930_["get-command"]
  local _local_931_ = require("sheaf.tag-registry")
  local components_with_tag = _local_931_["components-with-tag"]
  local _local_932_ = require("sheaf.component-registry")
  local get_component_instance = _local_932_["get-component-instance"]
  local _local_933_ = require("sheaf.trait-registry")
  local satisfies_all_3f = _local_933_["satisfies-all?"]
  local _local_934_ = require("sheaf.shape-registry")
  local conforms_3f = _local_934_["conforms?"]
  local function build_candidates(behavior, command_registry, component_registry, trait_registry, tag_registry, target_tag)
    local candidates = {}
    local target_instances = components_with_tag(tag_registry, target_tag)
    for alias, cmd_name in pairs((behavior.commands or {})) do
      local command = get_command(command_registry, cmd_name)
      local required_traits
      local _936_
      do
        local t_935_ = command
        if (nil ~= t_935_) then
          t_935_ = t_935_["requires-traits"]
        else
        end
        _936_ = t_935_
      end
      required_traits = (_936_ or {})
      local matching = {}
      for instance_name, _ in pairs(target_instances) do
        local instance = get_component_instance(component_registry, instance_name)
        if (instance and satisfies_all_3f(trait_registry, required_traits, (instance.state or {}))) then
          table.insert(matching, instance_name)
        else
        end
      end
      candidates[alias] = matching
    end
    return candidates
  end
  local function make_send_cmd(behavior, command_registry, component_registry, trait_registry)
    local function _939_(instance_name, cmd_alias, params)
      local cmd_name = behavior.commands[cmd_alias]
      if (nil == cmd_name) then
        print(("[WARN] send-cmd: unknown alias '" .. tostring(cmd_alias) .. "' in behavior '" .. tostring(behavior.name) .. "'"))
        return nil
      else
      end
      local command = get_command(command_registry, cmd_name)
      if (nil == command) then
        print(("[WARN] send-cmd: command not found: " .. tostring(cmd_name)))
        return nil
      else
      end
      local instance = get_component_instance(component_registry, instance_name)
      if (nil == instance) then
        print(("[WARN] send-cmd: instance not found: " .. tostring(instance_name)))
        return nil
      else
      end
      if satisfies_all_3f(trait_registry, (command["requires-traits"] or {}), (instance.state or {})) then
        local new_state = command.fn(instance, (params or {}))
        if (nil ~= new_state) then
          instance["state"] = new_state
          return nil
        else
          return nil
        end
      else
        return print(("[WARN] send-cmd: instance '" .. tostring(instance_name) .. "' does not satisfy traits for command '" .. tostring(cmd_name) .. "'"))
      end
    end
    return _939_
  end
  local function build_inputs(behavior, shape_registry, component_registry, tag_registry, input_tag)
    local inputs = (behavior.inputs or {})
    if ((nil == input_tag) or not next(inputs)) then
      return nil
    else
    end
    local input_instances = components_with_tag(tag_registry, input_tag)
    local result = {}
    for alias, shape_name in pairs(inputs) do
      local found = nil
      for instance_name, _ in pairs(input_instances) do
        if found then break end
        local instance = get_component_instance(component_registry, instance_name)
        if (instance and conforms_3f(shape_registry, shape_name, (instance.state or {}))) then
          found = (instance.state or {})
        else
        end
      end
      if found then
        result[alias] = found
      else
      end
    end
    if next(result) then
      return result
    else
      return nil
    end
  end
  local function dispatch_to_behavior(subscription_registry, component_registry, _3fshape_registry, event, behavior_name, target_tag, input_tag, subscription_params)
    local behavior_registry = subscription_registry["behavior-registry"]
    local command_registry = behavior_registry["command-registry"]
    local trait_registry = component_registry["trait-registry"]
    local tag_registry = subscription_registry["tag-registry"]
    if not behavior_responds_to_3f(behavior_registry, behavior_name, event["event-name"]) then
      print(("[ERROR] dispatch-to-behavior: behavior '" .. tostring(behavior_name) .. "' does not respond to event '" .. tostring(event["event-name"]) .. "'"))
      return nil
    else
    end
    local behavior = get_behavior(behavior_registry, behavior_name)
    if (nil == behavior) then
      print(("[ERROR] dispatch-to-behavior: behavior '" .. tostring(behavior_name) .. "' not found in registry"))
      return nil
    else
    end
    local candidates = build_candidates(behavior, command_registry, component_registry, trait_registry, tag_registry, target_tag)
    local send_cmd = make_send_cmd(behavior, command_registry, component_registry, trait_registry)
    local inputs
    do
      local has_inputs = next((behavior.inputs or {}))
      if (has_inputs and (nil == _3fshape_registry)) then
        print(("[ERROR] dispatch-to-behavior: behavior '" .. tostring(behavior_name) .. "' declares :inputs but no shape-registry available"))
        inputs = nil
      elseif (has_inputs and (nil == input_tag)) then
        print(("[WARN] dispatch-to-behavior: behavior '" .. tostring(behavior_name) .. "' declares :inputs but subscription has no :input-tag"))
        inputs = nil
      elseif has_inputs then
        inputs = build_inputs(behavior, _3fshape_registry, component_registry, tag_registry, input_tag)
      else
        inputs = nil
      end
    end
    return behavior.fn(event, candidates, send_cmd, inputs, subscription_params)
  end
  local function start_dispatcher_21(subscription_registry, component_registry, _3fshape_registry)
    local event_registry = subscription_registry["event-registry"]
    local function _952_(event)
      local sub_matches = get_matching_subscriptions(subscription_registry, event["event-source"], event["event-name"])
      for _, sub_match in ipairs((sub_matches or {})) do
        dispatch_to_behavior(subscription_registry, component_registry, _3fshape_registry, event, sub_match.behavior, sub_match["target-tag"], sub_match["input-tag"], sub_match.params)
      end
      return nil
    end
    add_event_handler_21(event_registry, "dispatcher/behavior-router", _952_)
    local function _953_(event)
      if _G["event-bus.debug-mode?"] then
        return print("got event", hs.inspect(event))
      else
        return nil
      end
    end
    return add_event_handler_21(event_registry, "dispatcher/debug-handler", _953_)
  end
  return {["start-dispatcher!"] = start_dispatcher_21}
end
local _local_955_ = require("sheaf.dispatcher")
local start_dispatcher_21 = _local_955_["start-dispatcher!"]
package.preload["sheaf.event-loop"] = package.preload["sheaf.event-loop"] or function(...)
  local function make_event_loop(event_registry)
    if (nil == event_registry) then
      error("make-event-loop: event-registry is required")
    else
    end
    return {["event-registry"] = event_registry, timer = nil}
  end
  local function process_event_21(event_loop)
    local registry = event_loop["event-registry"]
    if (0 < #registry.queue) then
      local event = table.remove(registry.queue, 1)
      for handler_key, handler in pairs(registry.handlers) do
        local ok, err = pcall(handler, event)
        if not ok then
          print(("[ERROR] event-loop: handler '" .. tostring(handler_key) .. "' failed on event '" .. tostring(event["event-name"]) .. "': " .. tostring(err)))
        else
        end
      end
      return true
    else
      return false
    end
  end
  local function start_event_loop_21(event_loop)
    if event_loop.timer then
      event_loop.timer:stop()
    else
    end
    local timer
    local function _960_()
      while process_event_21(event_loop) do
      end
      return nil
    end
    timer = hs.timer.new(0.01, _960_)
    event_loop["timer"] = timer
    timer:start()
    return print("[INFO] Event loop started")
  end
  local function stop_event_loop_21(event_loop)
    if event_loop.timer then
      event_loop.timer:stop()
      event_loop["timer"] = nil
      return print("[INFO] Event loop stopped")
    else
      return nil
    end
  end
  return {["make-event-loop"] = make_event_loop, ["process-event!"] = process_event_21, ["start-event-loop!"] = start_event_loop_21, ["stop-event-loop!"] = stop_event_loop_21}
end
local _local_962_ = require("sheaf.event-loop")
local make_event_loop = _local_962_["make-event-loop"]
local start_event_loop_21 = _local_962_["start-event-loop!"]
start_dispatcher_21(subscription_registry, component_registry, shape_registry)
local event_loop = make_event_loop(event_registry)
start_event_loop_21(event_loop)
notify.warn("Reload Succeeded")
return {}
