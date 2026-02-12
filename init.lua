hs.console.clearConsole()
_G["event-bus.debug-mode?"] = false
hs.ipc.cliInstall()
hs.window.animationDuration = 0.0
local spoons
package.preload["spoons"] = package.preload["spoons"] or function(...)
  local _local_1_ = require("lib.cljlib-shim")
  local contains_3f = _local_1_["contains?"]
  local loaded_spoons
  do
    local tbl_26_ = {}
    local i_27_ = 0
    for i, spoon in ipairs(hs.spoons.list()) do
      local val_28_ = spoon.name
      if (nil ~= val_28_) then
        i_27_ = (i_27_ + 1)
        tbl_26_[i_27_] = val_28_
      else
      end
    end
    loaded_spoons = tbl_26_
  end
  local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
  end
  local function exec(...)
    local rst = {...}
    return hs.execute(table.concat(rst, " "), true)
  end
  if not contains_3f(loaded_spoons, "SpoonInstall") then
    local tmpdir1 = exec("mktemp -d")
    local tmpdir = trim(tmpdir1)
    local outfile = (tmpdir .. "/SpoonInstall.spoon.zip")
    exec("curl -fsSL https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip -o", outfile)
    exec("cd", tmpdir, ";", "unzip SpoonInstall.spoon.zip -d ~/.hammerspoon/Spoons/")
    exec("rm -rf ", tmpdir)
  else
  end
  hs.loadSpoon("SpoonInstall")
  local function use_spoon(spoon_name, opts)
    return spoon.SpoonInstall:andUse(spoon_name, opts)
  end
  use_spoon("Calendar", {})
  use_spoon("CircleClock", {})
  use_spoon("ClipboardTool", {start = true})
  use_spoon("Emojis", {})
  local function toggle_emojis()
    if spoon.Emojis.chooser:isVisible() then
      return spoon.Emojis.chooser:hide()
    else
      return spoon.Emojis.chooser:show()
    end
  end
  use_spoon("HSKeybindings", {})
  local hammerspoonKeybindingsIsShown = false
  local function toggleShowKeybindings()
    hammerspoonKeybindingsIsShown = not hammerspoonKeybindingsIsShown
    if hammerspoonKeybindingsIsShown then
      return spoon.HSKeybindings:show()
    else
      return spoon.HSKeybindings:hide()
    end
  end
  use_spoon("KSheet", {})
  spoon.SpoonInstall.repos.PaperWM = {url = "https://github.com/mogenson/PaperWM.spoon", desc = "PaperWM.spoon repository", branch = "release"}
  local paper_wm
  local function _6_(_241)
    return _241:bindHotkeys(_241.default_hotkeys)
  end
  paper_wm = use_spoon("PaperWM", {repo = "PaperWM", config = {window_gap = 35, screen_margin = 16, window_ratios = {0.3125, 0.421875, 0.625, 0.84375}}, fn = _6_, start = true})
  return {}
end
spoons = require("spoons")
local active_space_indicator
package.preload["active-space-indicator"] = package.preload["active-space-indicator"] or function(...)
  local menubar = nil
  local function get_active_spaces_str()
    local parts = {}
    local spaces_layout = hs.spaces.allSpaces()
    local active_spaces = hs.spaces.activeSpaces()
    local num_spaces = 0
    for _, screen in ipairs(hs.screen.allScreens()) do
      local screen_uuid = screen:getUUID()
      local active_space = active_spaces[screen_uuid]
      local screen_spaces = spaces_layout[screen_uuid]
      for i, space in ipairs(screen_spaces) do
        if (active_space and (active_space == space)) then
          table.insert(parts, tostring((i + num_spaces)))
        else
        end
      end
      num_spaces = (num_spaces + #screen_spaces)
    end
    return table.concat(parts, "|")
  end
  local function update_menubar()
    if menubar then
      return menubar:setTitle(get_active_spaces_str())
    else
      return nil
    end
  end
  local function handle_space_switch(...)
    local rest = {...}
    return update_menubar()
  end
  menubar = hs.menubar.new(true, "cosmicHammerSpaceIndicator")
  if menubar then
    menubar:setTitle(get_active_spaces_str())
  else
  end
  local space_watcher = hs.spaces.watcher.new(handle_space_switch)
  space_watcher:start()
  local screen_watcher = hs.screen.watcher.new(handle_space_switch)
  screen_watcher:start()
  return {}
end
active_space_indicator = require("active-space-indicator")
local notify
package.preload["notify"] = package.preload["notify"] or function(...)
  local notification_duration = 30
  local margin = 64
  local stack_gap = 8
  local icons_dir = (os.getenv("HOME") .. "/.hammerspoon/icons")
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
    local function _17_()
      return remove_notification(notif)
    end
    close_btn:setClickCallback(_17_)
    local function _18_()
      return remove_notification(notif)
    end
    notif["timer"] = hs.timer.doAfter(notification_duration, _18_)
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
  local _local_20_ = require("lib.cljlib-shim")
  local string_3f = _local_20_["string?"]
  local _local_52_ = require("lib.event-registry")
  local make_event_registry = _local_52_["make-event-registry"]
  local define_event_21 = _local_52_["define-event!"]
  local _local_53_ = require("lib.hierarchy")
  local make_hierarchy = _local_53_["make-hierarchy"]
  local derive_21 = _local_53_["derive!"]
  local event_hierarchy = make_hierarchy()
  derive_21(event_hierarchy, "event.kind.fs/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.fs/file-change", "event.kind.fs/any")
  derive_21(event_hierarchy, "event.kind.fs/file-move", "event.kind.fs/any")
  derive_21(event_hierarchy, "event.kind.window/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.window/created", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/destroyed", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/focused", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/unfocused", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/moved", "event.kind.window/any")
  derive_21(event_hierarchy, "event.kind.window/resized", "event.kind.window/any")
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
  local event_registry = make_event_registry({hierarchy = event_hierarchy})
  define_event_21(event_registry, "file-watcher.events/file-change", "File change detected in watched directory", {["file-path"] = string_3f})
  derive_21(event_hierarchy, "file-watcher.events/file-change", "event.kind.fs/file-change")
  define_event_21(event_registry, "hotkey.events/pressed", "Hotkey was pressed", {mods = __fnl_global__table_3f, key = string_3f})
  derive_21(event_hierarchy, "hotkey.events/pressed", "event.kind.hotkey/pressed")
  return {["event-registry"] = event_registry}
end
package.preload["lib.event-registry"] = package.preload["lib.event-registry"] or function(...)
  local _local_21_ = require("lib.cljlib-shim")
  local some = _local_21_.some
  local seq = _local_21_.seq
  local _local_45_ = require("lib.hierarchy")
  local descendants = _local_45_.descendants
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
    local or_48_ = event_defined_3f(registry, selector)
    if not or_48_ then
      local function _49_(_241)
        return event_defined_3f(registry, _241)
      end
      or_48_ = some(_49_, seq(descendants(registry.hierarchy, selector)))
    end
    return or_48_
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
  local _local_22_ = require("lib.cljlib-shim")
  local hash_set = _local_22_["hash-set"]
  local conj = _local_22_.conj
  local disj = _local_22_.disj
  local contains_3f = _local_22_["contains?"]
  local into = _local_22_.into
  local mapcat = _local_22_.mapcat
  local empty_3f = _local_22_["empty?"]
  local seq = _local_22_.seq
  local function ensure_entry(h, tag)
    if (nil == h[tag]) then
      h[tag] = {parents = hash_set(), children = hash_set()}
      return nil
    else
      return nil
    end
  end
  local function parents(h, tag)
    local _25_
    do
      local t_24_ = h
      if (nil ~= t_24_) then
        t_24_ = t_24_[tag]
      else
      end
      if (nil ~= t_24_) then
        t_24_ = t_24_.parents
      else
      end
      _25_ = t_24_
    end
    return (_25_ or hash_set())
  end
  local function children(h, tag)
    local _29_
    do
      local t_28_ = h
      if (nil ~= t_28_) then
        t_28_ = t_28_[tag]
      else
      end
      if (nil ~= t_28_) then
        t_28_ = t_28_.children
      else
      end
      _29_ = t_28_
    end
    return (_29_ or hash_set())
  end
  local function ancestors(h, tag)
    local ps = parents(h, tag)
    if empty_3f(ps) then
      return ps
    else
      local function _32_(_241)
        return ancestors(h, _241)
      end
      return into(ps, mapcat(_32_, seq(ps)))
    end
  end
  local function descendants(h, tag)
    local cs = children(h, tag)
    if empty_3f(cs) then
      return cs
    else
      local function _34_(_241)
        return descendants(h, _241)
      end
      return into(cs, mapcat(_34_, seq(cs)))
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
local _local_54_ = require("events")
local event_registry = _local_54_["event-registry"]
package.preload["event_sources"] = package.preload["event_sources"] or function(...)
  local _local_65_ = require("lib.source-registry")
  local make_source_registry = _local_65_["make-source-registry"]
  local add_source_type_21 = _local_65_["add-source-type!"]
  local start_event_source_21 = _local_65_["start-event-source!"]
  local _local_66_ = require("events")
  local event_registry = _local_66_["event-registry"]
  local _local_72_ = require("event_sources.file-watcher")
  local file_watcher_source_type = _local_72_["file-watcher-source-type"]
  local _local_77_ = require("event_sources.hotkey")
  local hotkey_source_type = _local_77_["hotkey-source-type"]
  local source_registry = make_source_registry({["event-registry"] = event_registry})
  add_source_type_21(source_registry, file_watcher_source_type)
  add_source_type_21(source_registry, hotkey_source_type)
  start_event_source_21(source_registry, "event-source.file-watcher/config-dir", "event-source.type/file-watcher", {path = hs.configdir})
  start_event_source_21(source_registry, "event-source.hotkey/ctrl+cmd+e", "event-source.type/hotkey", {mods = {"ctrl", "cmd"}, key = "e"})
  return {["source-registry"] = source_registry}
end
package.preload["lib.source-registry"] = package.preload["lib.source-registry"] or function(...)
  local _local_55_ = require("lib.event-registry")
  local dispatch_event_21 = _local_55_["dispatch-event!"]
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
    local function _62_(event_name, event_data)
      return dispatch_event_21(registry["event-registry"], event_name, instance_name, event_data)
    end
    emit = _62_
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
    for instance_name, _ in pairs(registry.instances) do
      stop_event_source_21(registry, instance_name)
    end
    return nil
  end
  return {["make-source-registry"] = make_source_registry, ["make-source-type"] = make_source_type, ["add-source-type!"] = add_source_type_21, ["source-type-defined?"] = source_type_defined_3f, ["get-source-type"] = get_source_type, ["list-source-types"] = list_source_types, ["source-instance-exists?"] = source_instance_exists_3f, ["get-source-instance"] = get_source_instance, ["list-source-instances"] = list_source_instances, ["start-event-source!"] = start_event_source_21, ["stop-event-source!"] = stop_event_source_21, ["stop-all-event-sources!"] = stop_all_event_sources_21}
end
package.preload["event_sources.file-watcher"] = package.preload["event_sources.file-watcher"] or function(...)
  local _local_67_ = require("lib.cljlib-shim")
  local mapv = _local_67_.mapv
  local assoc = _local_67_.assoc
  local string_3f = _local_67_["string?"]
  local _local_68_ = require("lib.source-registry")
  local make_source_type = _local_68_["make-source-type"]
  local function start_file_watcher(self, emit)
    local path = self.config.path
    local handler
    local function _69_(files, attrs)
      local evs
      local function _70_(_241, _242)
        return assoc(_241, "file-path", _242)
      end
      evs = mapv(_70_, attrs, files)
      for _, ev in ipairs(evs) do
        emit("file-watcher.events/file-change", ev)
      end
      return nil
    end
    handler = _69_
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
  local _local_73_ = require("lib.cljlib-shim")
  local string_3f = _local_73_["string?"]
  local _local_74_ = require("lib.source-registry")
  local make_source_type = _local_74_["make-source-type"]
  local function start_hotkey(self, emit)
    local mods = self.config.mods
    local key = self.config.key
    local handler
    local function _75_()
      return emit("hotkey.events/pressed", {mods = mods, key = key})
    end
    handler = _75_
    return hs.hotkey.bind(mods, key, handler)
  end
  local function stop_hotkey(state)
    if state then
      return state:delete()
    else
      return nil
    end
  end
  local hotkey_source_type = make_source_type("event-source.type/hotkey", "Emits an event when a hotkey is pressed", {["config-schema"] = {mods = __fnl_global__table_3f, key = string_3f}, emits = {"hotkey.events/pressed"}, ["start-fn"] = start_hotkey, ["stop-fn"] = stop_hotkey})
  return {["hotkey-source-type"] = hotkey_source_type}
end
require("event_sources")
package.preload["commands"] = package.preload["commands"] or function(...)
  local _local_82_ = require("lib.command-registry")
  local make_command_registry = _local_82_["make-command-registry"]
  local add_command_21 = _local_82_["add-command!"]
  local _local_85_ = require("commands.toggle-expose")
  local toggle_expose_command = _local_85_["toggle-expose-command"]
  local command_registry = make_command_registry()
  add_command_21(command_registry, toggle_expose_command)
  return {["command-registry"] = command_registry}
end
package.preload["lib.command-registry"] = package.preload["lib.command-registry"] or function(...)
  local function make_command_registry()
    return {commands = {}}
  end
  local function make_command(name, description, opts)
    if (nil == opts.fn) then
      error(("make-command: :fn is required for " .. tostring(name)))
    else
    end
    return {name = name, description = description, schema = (opts.schema or {}), fn = opts.fn}
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
  local function invoke_command_21(registry, name, params)
    local command = get_command(registry, name)
    if (nil == command) then
      error(("invoke-command!: command not found: " .. tostring(name)))
    else
    end
    return command.fn((params or {}))
  end
  return {["make-command-registry"] = make_command_registry, ["make-command"] = make_command, ["add-command!"] = add_command_21, ["command-defined?"] = command_defined_3f, ["get-command"] = get_command, ["list-commands"] = list_commands, ["invoke-command!"] = invoke_command_21}
end
package.preload["commands.toggle-expose"] = package.preload["commands.toggle-expose"] or function(...)
  local _local_83_ = require("lib.command-registry")
  local make_command = _local_83_["make-command"]
  local expose = hs.expose.new()
  local toggle_expose_command
  local function _84_(params)
    return expose:toggleShow()
  end
  toggle_expose_command = make_command("expose.commands/toggle-show", "Toggle the Hammerspoon Expose window picker", {fn = _84_})
  return {["toggle-expose-command"] = toggle_expose_command}
end
require("commands")
package.preload["behaviors"] = package.preload["behaviors"] or function(...)
  local _local_95_ = require("lib.behavior-registry")
  local make_behavior_registry = _local_95_["make-behavior-registry"]
  local add_behavior_21 = _local_95_["add-behavior!"]
  local _local_96_ = require("events")
  local event_registry = _local_96_["event-registry"]
  local _local_103_ = require("behaviors.compile-fennel")
  local compile_fennel_behavior = _local_103_["compile-fennel-behavior"]
  local _local_110_ = require("behaviors.reload-hammerspoon")
  local reload_hammerspoon_behavior = _local_110_["reload-hammerspoon-behavior"]
  local _local_113_ = require("behaviors.toggle-expose")
  local toggle_expose_behavior = _local_113_["toggle-expose-behavior"]
  local behavior_registry = make_behavior_registry({["event-registry"] = event_registry})
  add_behavior_21(behavior_registry, compile_fennel_behavior)
  add_behavior_21(behavior_registry, reload_hammerspoon_behavior)
  add_behavior_21(behavior_registry, toggle_expose_behavior)
  return {["behavior-registry"] = behavior_registry}
end
package.preload["lib.behavior-registry"] = package.preload["lib.behavior-registry"] or function(...)
  local _local_86_ = require("lib.cljlib-shim")
  local some = _local_86_.some
  local _local_87_ = require("lib.event-registry")
  local valid_event_selector_3f = _local_87_["valid-event-selector?"]
  local _local_88_ = require("lib.hierarchy")
  local isa_3f = _local_88_["isa?"]
  local function make_behavior_registry(opts)
    if (nil == opts["event-registry"]) then
      error("make-behavior-registry: :event-registry is required")
    else
    end
    return {behaviors = {}, ["event-registry"] = opts["event-registry"]}
  end
  local function make_behavior(name, description, event_selectors, handler_fn)
    return {name = name, description = description, ["respond-to"] = event_selectors, fn = handler_fn}
  end
  local function add_behavior_21(registry, behavior)
    local name = behavior.name
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
      local function _93_(_241)
        return isa_3f(registry["event-registry"].hierarchy, event_name, _241)
      end
      return some(_93_, behavior["respond-to"])
    end
  end
  return {["make-behavior-registry"] = make_behavior_registry, ["make-behavior"] = make_behavior, ["add-behavior!"] = add_behavior_21, ["behavior-defined?"] = behavior_defined_3f, ["get-behavior"] = get_behavior, ["list-behaviors"] = list_behaviors, ["behavior-responds-to?"] = behavior_responds_to_3f}
end
package.preload["behaviors.compile-fennel"] = package.preload["behaviors.compile-fennel"] or function(...)
  local _local_97_ = require("lib.behavior-registry")
  local make_behavior = _local_97_["make-behavior"]
  local compile_fennel_behavior
  local function _98_(file_change_event)
    local path
    do
      local t_99_ = file_change_event
      if (nil ~= t_99_) then
        t_99_ = t_99_["event-data"]
      else
      end
      if (nil ~= t_99_) then
        t_99_ = t_99_["file-path"]
      else
      end
      path = t_99_
    end
    if ((nil ~= path) and (".fnl" == path:sub(-4))) then
      return print(hs.execute("./compile.sh", true))
    else
      return nil
    end
  end
  compile_fennel_behavior = make_behavior("compile-fennel.behaviors/compile-fennel", "Watch fennel files in hammerspoon folder and recompile them.", {"event.kind.fs/file-change"}, _98_)
  return {["compile-fennel-behavior"] = compile_fennel_behavior}
end
package.preload["behaviors.reload-hammerspoon"] = package.preload["behaviors.reload-hammerspoon"] or function(...)
  local _local_104_ = require("lib.behavior-registry")
  local make_behavior = _local_104_["make-behavior"]
  local notify = require("notify")
  local reloading_3f = false
  local reload = hs.timer.delayed.new(0.5, hs.reload)
  local reload_hammerspoon_behavior
  local function _105_(file_change_event)
    local path
    do
      local t_106_ = file_change_event
      if (nil ~= t_106_) then
        t_106_ = t_106_["event-data"]
      else
      end
      if (nil ~= t_106_) then
        t_106_ = t_106_["file-path"]
      else
      end
      path = t_106_
    end
    if (not reloading_3f and (nil ~= path) and (".hammerspoon/init.lua" == path:sub(-21))) then
      reloading_3f = true
      notify.warn("Reloading...")
      return reload:start()
    else
      return nil
    end
  end
  reload_hammerspoon_behavior = make_behavior("reload-hammerspoon.behaviors/reload-hammerspoon", "When init.lua changes, reload hammerspoon.", {"event.kind.fs/file-change"}, _105_)
  return {["reload-hammerspoon-behavior"] = reload_hammerspoon_behavior}
end
package.preload["behaviors.toggle-expose"] = package.preload["behaviors.toggle-expose"] or function(...)
  local _local_111_ = require("lib.behavior-registry")
  local make_behavior = _local_111_["make-behavior"]
  local toggle_expose_behavior
  local function _112_(event, send_cmd_21)
    return send_cmd_21("expose.commands/toggle-show", {})
  end
  toggle_expose_behavior = make_behavior("expose.behaviors/toggle-expose", "Toggle the Hammerspoon Expose window picker", {"event.kind.hotkey/pressed"}, _112_)
  return {["toggle-expose-behavior"] = toggle_expose_behavior}
end
require("behaviors")
package.preload["subscriptions"] = package.preload["subscriptions"] or function(...)
  local _local_134_ = require("lib.subscription-registry")
  local make_subscription_registry = _local_134_["make-subscription-registry"]
  local define_subscription_21 = _local_134_["define-subscription!"]
  local _local_135_ = require("events")
  local event_registry = _local_135_["event-registry"]
  local _local_136_ = require("behaviors")
  local behavior_registry = _local_136_["behavior-registry"]
  local _local_137_ = require("event_sources")
  local source_registry = _local_137_["source-registry"]
  local subscription_registry = make_subscription_registry({["event-registry"] = event_registry, ["behavior-registry"] = behavior_registry, ["source-registry"] = source_registry})
  define_subscription_21(subscription_registry, "sub/reload-on-config-change", {description = "Reload Hammerspoon when init.lua changes", behavior = "reload-hammerspoon.behaviors/reload-hammerspoon", ["source-selector"] = "event-source.file-watcher/config-dir", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/compile-on-fnl-change", {description = "Recompile Fennel when .fnl files change", behavior = "compile-fennel.behaviors/compile-fennel", ["source-selector"] = "event-source.file-watcher/config-dir", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/toggle-expose-on-hotkey", {description = "Toggle Expose when ctrl+cmd+e is pressed", behavior = "expose.behaviors/toggle-expose", ["source-selector"] = "event-source.hotkey/ctrl+cmd+e", ["event-selector"] = "event.kind.hotkey/pressed"})
  return {["subscription-registry"] = subscription_registry}
end
package.preload["lib.subscription-registry"] = package.preload["lib.subscription-registry"] or function(...)
  local _local_114_ = require("lib.cljlib-shim")
  local hash_set = _local_114_["hash-set"]
  local conj = _local_114_.conj
  local disj = _local_114_.disj
  local into = _local_114_.into
  local seq = _local_114_.seq
  local filter = _local_114_.filter
  local _local_115_ = require("lib.event-registry")
  local valid_event_selector_3f = _local_115_["valid-event-selector?"]
  local _local_116_ = require("lib.behavior-registry")
  local behavior_defined_3f = _local_116_["behavior-defined?"]
  local _local_117_ = require("lib.source-registry")
  local source_instance_exists_3f = _local_117_["source-instance-exists?"]
  local _local_118_ = require("lib.hierarchy")
  local ancestors = _local_118_.ancestors
  local function make_subscription_registry(opts)
    if (nil == opts["event-registry"]) then
      error("make-subscription-registry: :event-registry is required")
    else
    end
    if (nil == opts["behavior-registry"]) then
      error("make-subscription-registry: :behavior-registry is required")
    else
    end
    if (nil == opts["source-registry"]) then
      error("make-subscription-registry: :source-registry is required")
    else
    end
    return {subscriptions = {}, index = {}, ["event-registry"] = opts["event-registry"], ["behavior-registry"] = opts["behavior-registry"], ["source-registry"] = opts["source-registry"]}
  end
  local function index_add_21(registry, subscription)
    local source = subscription["source-selector"]
    local event = subscription["event-selector"]
    local behavior = subscription.behavior
    if (nil == registry.index[source]) then
      registry.index[source] = {}
    else
    end
    if (nil == registry.index[source][event]) then
      registry.index[source][event] = hash_set()
    else
    end
    registry.index[source][event] = conj(registry.index[source][event], behavior)
    return nil
  end
  local function index_remove_21(registry, subscription)
    local source = subscription["source-selector"]
    local event = subscription["event-selector"]
    local behavior = subscription.behavior
    local behavior_set
    do
      local t_124_ = registry.index
      if (nil ~= t_124_) then
        t_124_ = t_124_[source]
      else
      end
      if (nil ~= t_124_) then
        t_124_ = t_124_[event]
      else
      end
      behavior_set = t_124_
    end
    if behavior_set then
      registry.index[source][event] = disj(behavior_set, behavior)
      return nil
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
    validate_required_field_21(name, opts, "source-selector")
    if (nil ~= registry.subscriptions[name]) then
      error(("Subscription already defined: " .. tostring(name)))
    else
    end
    if not behavior_defined_3f(registry["behavior-registry"], opts.behavior) then
      error(("define-subscription! " .. tostring(name) .. ": behavior not found: " .. tostring(opts.behavior)))
    else
    end
    if not source_instance_exists_3f(registry["source-registry"], opts["source-selector"]) then
      error(("define-subscription! " .. tostring(name) .. ": source instance not found: " .. tostring(opts["source-selector"])))
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
    local subscription = {name = name, description = opts.description, behavior = opts.behavior, ["event-selector"] = opts["event-selector"], ["source-selector"] = opts["source-selector"], ["require-tags"] = (opts["require-tags"] or {}), ["exclude-tags"] = (opts["exclude-tags"] or {})}
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
  local function get_subscribed_behaviors(registry, source, event_name)
    local event_selectors = conj(ancestors(registry["event-registry"].hierarchy, event_name), event_name)
    local source_subs = (registry.index[source] or {})
    local all_behavior_names
    do
      local result = hash_set()
      for _, e in pairs(event_selectors) do
        result = into(result, (source_subs[e] or {}))
      end
      all_behavior_names = result
    end
    return seq(all_behavior_names)
  end
  return {["make-subscription-registry"] = make_subscription_registry, ["define-subscription!"] = define_subscription_21, ["remove-subscription!"] = remove_subscription_21, ["get-subscription"] = get_subscription, ["list-subscriptions"] = list_subscriptions, ["subscription-defined?"] = subscription_defined_3f, ["get-subscribed-behaviors"] = get_subscribed_behaviors}
end
local _local_138_ = require("subscriptions")
local subscription_registry = _local_138_["subscription-registry"]
package.preload["lib.dispatcher"] = package.preload["lib.dispatcher"] or function(...)
  local _local_139_ = require("lib.cljlib-shim")
  local mapv = _local_139_.mapv
  local filter = _local_139_.filter
  local seq = _local_139_.seq
  local _local_140_ = require("lib.event-registry")
  local add_event_handler_21 = _local_140_["add-event-handler!"]
  local _local_141_ = require("lib.behavior-registry")
  local behavior_responds_to_3f = _local_141_["behavior-responds-to?"]
  local get_behavior = _local_141_["get-behavior"]
  local _local_142_ = require("lib.subscription-registry")
  local get_subscribed_behaviors = _local_142_["get-subscribed-behaviors"]
  local _local_143_ = require("lib.source-registry")
  local source_instance_exists_3f = _local_143_["source-instance-exists?"]
  local _local_144_ = require("lib.command-registry")
  local invoke_command_21 = _local_144_["invoke-command!"]
  local function get_behaviors_for_event(subscription_registry, event)
    local behavior_registry = subscription_registry["behavior-registry"]
    local source_registry = subscription_registry["source-registry"]
    if not source_instance_exists_3f(source_registry, event["event-source"]) then
      print(("[WARN] get-behaviors-for-event: unknown source instance '" .. tostring(event["event-source"]) .. "'"))
    else
    end
    local behavior_names = (get_subscribed_behaviors(subscription_registry, event["event-source"], event["event-name"]) or {})
    local valid_names
    local function _146_(name)
      local responds_3f = behavior_responds_to_3f(behavior_registry, name, event["event-name"])
      if not responds_3f then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' does not respond to event '" .. tostring(event["event-name"]) .. "'"))
      else
      end
      return responds_3f
    end
    valid_names = filter(_146_, behavior_names)
    local function _148_(name)
      local behavior = get_behavior(behavior_registry, name)
      if (nil == behavior) then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' not found in registry"))
      else
      end
      return behavior
    end
    return mapv(_148_, (seq(valid_names) or {}))
  end
  local function start_dispatcher_21(subscription_registry, command_registry)
    local event_registry = subscription_registry["event-registry"]
    local send_cmd_21
    local function _150_(cmd_name, params)
      return invoke_command_21(command_registry, cmd_name, params)
    end
    send_cmd_21 = _150_
    local function _151_(event)
      local bs = get_behaviors_for_event(subscription_registry, event)
      for _, behavior in pairs(bs) do
        if behavior then
          behavior.fn(event, send_cmd_21)
        else
        end
      end
      return nil
    end
    add_event_handler_21(event_registry, "dispatcher/behavior-router", _151_)
    local function _153_(event)
      if _G["event-bus.debug-mode?"] then
        return print("got event", hs.inspect(event))
      else
        return nil
      end
    end
    return add_event_handler_21(event_registry, "dispatcher/debug-handler", _153_)
  end
  return {["start-dispatcher!"] = start_dispatcher_21}
end
local _local_155_ = require("lib.dispatcher")
local start_dispatcher_21 = _local_155_["start-dispatcher!"]
package.preload["lib.event-loop"] = package.preload["lib.event-loop"] or function(...)
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
      for _, handler in pairs(registry.handlers) do
        handler(event)
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
    local function _159_()
      while process_event_21(event_loop) do
      end
      return nil
    end
    timer = hs.timer.new(0.01, _159_)
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
local _local_161_ = require("lib.event-loop")
local make_event_loop = _local_161_["make-event-loop"]
local start_event_loop_21 = _local_161_["start-event-loop!"]
local _local_162_ = require("commands")
local command_registry = _local_162_["command-registry"]
start_dispatcher_21(subscription_registry, command_registry)
local event_loop = make_event_loop(event_registry)
start_event_loop_21(event_loop)
notify.warn("Reload Succeeded")
return {}
