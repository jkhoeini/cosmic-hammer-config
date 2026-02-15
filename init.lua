hs.console.clearConsole()
_G["event-bus.debug-mode?"] = false
hs.ipc.cliInstall()
hs.window.animationDuration = 0.0
local spoons
package.preload["spoons"] = package.preload["spoons"] or function(...)
  local _local_32_ = require("lib.spoon-install")
  local and_use_21 = _local_32_["and-use!"]
  local add_repo_21 = _local_32_["add-repo!"]
  add_repo_21("PaperWM", {url = "https://github.com/mogenson/PaperWM.spoon", desc = "PaperWM.spoon repository", branch = "release"})
  local function _33_(_241)
    return _241:bindHotkeys(_241.default_hotkeys)
  end
  and_use_21("PaperWM", {repo = "PaperWM", config = {window_gap = 35, screen_margin = 16, window_ratios = {0.3125, 0.421875, 0.625, 0.84375}}, fn = _33_, start = true})
  return {}
end
package.preload["lib.spoon-install"] = package.preload["lib.spoon-install"] or function(...)
  local logger = hs.logger.new("spoon-install")
  local repos = {default = {branch = "master", desc = "Main Hammerspoon Spoon repository", url = "https://github.com/Hammerspoon/Spoons"}}
  local use_syncinstall = false
  local function exec_21(cmd, errfmt, ...)
    local output, status = hs.execute(cmd)
    if status then
      local trimstr = string.gsub(output, "\n*$", "")
      return trimstr
    else
      logger.ef(errfmt, ...)
      return nil
    end
  end
  local function store_repo_json_21(repo, callback, status, body, hdrs)
    local success = nil
    if ((status < 100) or (status >= 400)) then
      logger.ef("Error fetching JSON data for repository '%s'. Error code %d: %s", repo, status, (body or "<no error message>"))
    else
      local json = hs.json.decode(body)
      if json then
        repos[repo]["data"] = {}
        for i, v in ipairs(json) do
          v.download_url = (repos[repo].download_base_url .. v.name .. ".spoon.zip")
          repos[repo].data[v.name] = v
        end
        logger.df("Updated JSON data for repository '%s'", repo)
        success = true
      else
        logger.ef("Invalid JSON received for repository '%s': %s", repo, body)
      end
    end
    if callback then
      callback(repo, success)
    else
    end
    return success
  end
  local function build_repo_json_url_21(repo)
    if (repos[repo] and repos[repo].url) then
      local branch = (repos[repo].branch or "master")
      repos[repo]["json_url"] = (string.gsub(repos[repo].url, "/$", "") .. "/raw/" .. branch .. "/docs/docs.json")
      repos[repo]["download_base_url"] = (string.gsub(repos[repo].url, "/$", "") .. "/raw/" .. branch .. "/Spoons/")
      return true
    else
      logger.ef("Invalid or unknown repository '%s'", repo)
      return nil
    end
  end
  local function async_update_repo_21(repo, callback)
    local repo0 = (repo or "default")
    if build_repo_json_url_21(repo0) then
      local function _6_(status, body, hdrs)
        return store_repo_json_21(repo0, callback, status, body, hdrs)
      end
      hs.http.asyncGet(repos[repo0].json_url, nil, _6_)
      return true
    else
      return nil
    end
  end
  local function update_repo_21(repo)
    local repo0 = (repo or "default")
    if build_repo_json_url_21(repo0) then
      local a, b, c = hs.http.get(repos[repo0].json_url)
      return store_repo_json_21(repo0, nil, a, b, c)
    else
      return nil
    end
  end
  local function async_update_all_repos_21()
    for k, v in pairs(repos) do
      async_update_repo_21(k)
    end
    return nil
  end
  local function update_all_repos_21()
    for k, v in pairs(repos) do
      update_repo_21(k)
    end
    return nil
  end
  local function add_repo_21(name, config)
    repos[name] = config
    return nil
  end
  local function repo_list()
    local keys = {}
    for k, v in pairs(repos) do
      table.insert(keys, k)
    end
    table.sort(keys)
    return keys
  end
  local function search(pat)
    local res = {}
    for repo, v in pairs(repos) do
      if v.data then
        for spoon, rec in pairs(v.data) do
          if string.find(string.lower((rec.name .. "\n" .. rec.desc)), pat) then
            table.insert(res, {desc = rec.desc, name = rec.name, repo = repo})
          else
          end
        end
      else
        logger.ef("Repository data for '%s' not available - call (update-repo! \"%s\"), then try again.", repo, repo)
      end
    end
    return res
  end
  local function install_spoon_from_zip_url_callback_21(urlparts, callback, status, body, headers)
    local success = nil
    if ((status < 100) or (status >= 400)) then
      logger.ef("Error downloading %s. Error code %d: %s", urlparts.absoluteString, status, (body or "<none>"))
    else
      local tmpdir = exec_21("/usr/bin/mktemp -d", "Error creating temporary directory to download new spoon.")
      if tmpdir then
        local outfile = string.format("%s/%s", tmpdir, urlparts.lastPathComponent)
        local f = assert(io.open(outfile, "w"))
        f:write(body)
        f:close()
        local output = exec_21(string.format("/usr/bin/unzip -l %s '*.spoon/' | /usr/bin/awk '$NF ~ /\\.spoon\\/$/ { print $NF }' | /usr/bin/wc -l", outfile), "Error examining downloaded zip file %s, leaving it in place for your examination.", outfile)
        if output then
          if ((tonumber(output) or 0) == 1) then
            local outdir = string.format("%s/Spoons", hs.configdir)
            if exec_21(string.format("/usr/bin/unzip -o %s -d %s 2>&1", outfile, outdir), "Error uncompressing file %s, leaving it in place for your examination.", outfile) then
              logger.f("Downloaded and installed %s", urlparts.absoluteString)
              exec_21(string.format("/bin/rm -rf '%s'", tmpdir), "Error removing directory %s", tmpdir)
              success = true
            else
            end
          else
            logger.ef("The downloaded zip file %s is invalid - it should contain exactly one spoon. Leaving it in place for your examination.", outfile)
          end
        else
        end
      else
      end
    end
    if callback then
      callback(urlparts, success)
    else
    end
    return success
  end
  local function valid_spoon_3f(name, repo)
    if repos[repo] then
      if repos[repo].data then
        if repos[repo].data[name] then
          return true
        else
          return logger.ef("Spoon '%s' does not exist in repository '%s'. Please check and try again.", name, repo)
        end
      else
        return logger.ef("Repository data for '%s' not available - call (update-repo! \"%s\"), then try again.", repo, repo)
      end
    else
      return logger.ef("Invalid or unknown repository '%s'", repo)
    end
  end
  local function async_install_spoon_from_zip_url_21(url, callback)
    local urlparts = hs.http.urlParts(url)
    local dlfile = urlparts.lastPathComponent
    if ((dlfile and (dlfile ~= "")) and (urlparts.pathExtension == "zip")) then
      local function _20_(status, body, headers)
        return install_spoon_from_zip_url_callback_21(urlparts, callback, status, body, headers)
      end
      hs.http.asyncGet(url, nil, _20_)
      return true
    else
      logger.ef("Invalid URL %s, must point to a zip file", url)
      return nil
    end
  end
  local function install_spoon_from_zip_url_21(url)
    local urlparts = hs.http.urlParts(url)
    local dlfile = urlparts.lastPathComponent
    if ((dlfile and (dlfile ~= "")) and (urlparts.pathExtension == "zip")) then
      local a, b, c = hs.http.get(url)
      return install_spoon_from_zip_url_callback_21(urlparts, nil, a, b, c)
    else
      logger.ef("Invalid URL %s, must point to a zip file", url)
      return nil
    end
  end
  local function async_install_spoon_from_repo_21(name, repo, callback)
    local repo0 = (repo or "default")
    if valid_spoon_3f(name, repo0) then
      async_install_spoon_from_zip_url_21(repos[repo0].data[name].download_url, callback)
    else
    end
    return nil
  end
  local function install_spoon_from_repo_21(name, repo)
    local repo0 = (repo or "default")
    if valid_spoon_3f(name, repo0) then
      return install_spoon_from_zip_url_21(repos[repo0].data[name].download_url)
    else
      return nil
    end
  end
  local function and_use_21(name, arg)
    local arg0 = (arg or {})
    if arg0.disable then
      return true
    elseif hs.spoons.use(name, arg0, true) then
      return true
    else
      local repo = (arg0.repo or "default")
      if repos[repo] then
        if repos[repo].data then
          local function load_and_config(_, success)
            if success then
              hs.notify.show("Spoon installed", (name .. ".spoon is now available"), "")
              return hs.spoons.use(name, arg0)
            else
              return logger.ef("Error installing Spoon '%s' from repo '%s'", name, repo)
            end
          end
          if use_syncinstall then
            return load_and_config(nil, install_spoon_from_repo_21(name, repo))
          else
            return async_install_spoon_from_repo_21(name, repo, load_and_config)
          end
        else
          local function update_repo_and_continue(_, success)
            if success then
              return and_use_21(name, arg0)
            else
              return logger.ef("Error updating repository '%s'", repo)
            end
          end
          if use_syncinstall then
            return update_repo_and_continue(nil, update_repo_21(repo))
          else
            return async_update_repo_21(repo, update_repo_and_continue)
          end
        end
      else
        return logger.ef("Unknown repository '%s' for Spoon", repo, name)
      end
    end
  end
  return {["and-use!"] = and_use_21, ["add-repo!"] = add_repo_21, search = search, ["repo-list"] = repo_list, ["update-repo!"] = update_repo_21, ["async-update-repo!"] = async_update_repo_21, ["update-all-repos!"] = update_all_repos_21, ["async-update-all-repos!"] = async_update_all_repos_21, ["install-spoon-from-zip-url!"] = install_spoon_from_zip_url_21, ["async-install-spoon-from-zip-url!"] = async_install_spoon_from_zip_url_21, ["install-spoon-from-repo!"] = install_spoon_from_repo_21, ["async-install-spoon-from-repo!"] = async_install_spoon_from_repo_21}
end
spoons = require("spoons")
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
    local function _41_()
      return remove_notification(notif)
    end
    close_btn:setClickCallback(_41_)
    local function _42_()
      return remove_notification(notif)
    end
    notif["timer"] = hs.timer.doAfter(notification_duration, _42_)
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
  local _local_44_ = require("lib.cljlib-shim")
  local string_3f = _local_44_["string?"]
  local _local_76_ = require("sheaf.event-registry")
  local make_event_registry = _local_76_["make-event-registry"]
  local define_event_21 = _local_76_["define-event!"]
  local _local_77_ = require("lib.hierarchy")
  local make_hierarchy = _local_77_["make-hierarchy"]
  local derive_21 = _local_77_["derive!"]
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
  define_event_21(event_registry, "space-watcher.events/space-changed", "Active space/desktop changed", {["space-number"] = __fnl_global__number_3f, ["all-spaces"] = __fnl_global__table_3f, ["active-spaces"] = __fnl_global__table_3f})
  derive_21(event_hierarchy, "space-watcher.events/space-changed", "event.kind.space/changed")
  define_event_21(event_registry, "screen-watcher.events/screen-changed", "Screen layout changed", {["all-spaces"] = __fnl_global__table_3f, ["active-spaces"] = __fnl_global__table_3f})
  derive_21(event_hierarchy, "screen-watcher.events/screen-changed", "event.kind.screen/layout-changed")
  return {["event-registry"] = event_registry}
end
package.preload["sheaf.event-registry"] = package.preload["sheaf.event-registry"] or function(...)
  local _local_45_ = require("lib.cljlib-shim")
  local some = _local_45_.some
  local seq = _local_45_.seq
  local _local_69_ = require("lib.hierarchy")
  local descendants = _local_69_.descendants
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
    local or_72_ = event_defined_3f(registry, selector)
    if not or_72_ then
      local function _73_(_241)
        return event_defined_3f(registry, _241)
      end
      or_72_ = some(_73_, seq(descendants(registry.hierarchy, selector)))
    end
    return or_72_
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
  local _local_46_ = require("lib.cljlib-shim")
  local hash_set = _local_46_["hash-set"]
  local conj = _local_46_.conj
  local disj = _local_46_.disj
  local contains_3f = _local_46_["contains?"]
  local into = _local_46_.into
  local mapcat = _local_46_.mapcat
  local empty_3f = _local_46_["empty?"]
  local seq = _local_46_.seq
  local function ensure_entry(h, tag)
    if (nil == h[tag]) then
      h[tag] = {parents = hash_set(), children = hash_set()}
      return nil
    else
      return nil
    end
  end
  local function parents(h, tag)
    local _49_
    do
      local t_48_ = h
      if (nil ~= t_48_) then
        t_48_ = t_48_[tag]
      else
      end
      if (nil ~= t_48_) then
        t_48_ = t_48_.parents
      else
      end
      _49_ = t_48_
    end
    return (_49_ or hash_set())
  end
  local function children(h, tag)
    local _53_
    do
      local t_52_ = h
      if (nil ~= t_52_) then
        t_52_ = t_52_[tag]
      else
      end
      if (nil ~= t_52_) then
        t_52_ = t_52_.children
      else
      end
      _53_ = t_52_
    end
    return (_53_ or hash_set())
  end
  local function ancestors(h, tag)
    local ps = parents(h, tag)
    if empty_3f(ps) then
      return ps
    else
      local function _56_(_241)
        return ancestors(h, _241)
      end
      return into(ps, mapcat(_56_, seq(ps)))
    end
  end
  local function descendants(h, tag)
    local cs = children(h, tag)
    if empty_3f(cs) then
      return cs
    else
      local function _58_(_241)
        return descendants(h, _241)
      end
      return into(cs, mapcat(_58_, seq(cs)))
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
local _local_78_ = require("events")
local event_registry = _local_78_["event-registry"]
package.preload["event_sources"] = package.preload["event_sources"] or function(...)
  local _local_89_ = require("sheaf.source-registry")
  local make_source_registry = _local_89_["make-source-registry"]
  local add_source_type_21 = _local_89_["add-source-type!"]
  local start_event_source_21 = _local_89_["start-event-source!"]
  local _local_90_ = require("events")
  local event_registry = _local_90_["event-registry"]
  local _local_96_ = require("event_sources.file-watcher")
  local file_watcher_source_type = _local_96_["file-watcher-source-type"]
  local _local_101_ = require("event_sources.hotkey")
  local hotkey_source_type = _local_101_["hotkey-source-type"]
  local _local_106_ = require("event_sources.space-watcher")
  local space_watcher_source_type = _local_106_["space-watcher-source-type"]
  local _local_111_ = require("event_sources.screen-watcher")
  local screen_watcher_source_type = _local_111_["screen-watcher-source-type"]
  local source_registry = make_source_registry({["event-registry"] = event_registry})
  add_source_type_21(source_registry, file_watcher_source_type)
  add_source_type_21(source_registry, hotkey_source_type)
  add_source_type_21(source_registry, space_watcher_source_type)
  add_source_type_21(source_registry, screen_watcher_source_type)
  start_event_source_21(source_registry, "event-source.file-watcher/config-dir", "event-source.type/file-watcher", {path = hs.configdir})
  start_event_source_21(source_registry, "event-source.hotkey/ctrl+cmd+e", "event-source.type/hotkey", {mods = {"ctrl", "cmd"}, key = "e"})
  start_event_source_21(source_registry, "event-source.space-watcher/default", "event-source.type/space-watcher", {})
  start_event_source_21(source_registry, "event-source.screen-watcher/default", "event-source.type/screen-watcher", {})
  return {["source-registry"] = source_registry}
end
package.preload["sheaf.source-registry"] = package.preload["sheaf.source-registry"] or function(...)
  local _local_79_ = require("sheaf.event-registry")
  local dispatch_event_21 = _local_79_["dispatch-event!"]
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
    local function _86_(event_name, event_data)
      return dispatch_event_21(registry["event-registry"], event_name, instance_name, event_data)
    end
    emit = _86_
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
  local _local_91_ = require("lib.cljlib-shim")
  local mapv = _local_91_.mapv
  local assoc = _local_91_.assoc
  local string_3f = _local_91_["string?"]
  local _local_92_ = require("sheaf.source-registry")
  local make_source_type = _local_92_["make-source-type"]
  local function start_file_watcher(self, emit)
    local path = self.config.path
    local handler
    local function _93_(files, attrs)
      local evs
      local function _94_(_241, _242)
        return assoc(_241, "file-path", _242)
      end
      evs = mapv(_94_, attrs, files)
      for _, ev in ipairs(evs) do
        emit("file-watcher.events/file-change", ev)
      end
      return nil
    end
    handler = _93_
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
  local _local_97_ = require("lib.cljlib-shim")
  local string_3f = _local_97_["string?"]
  local _local_98_ = require("sheaf.source-registry")
  local make_source_type = _local_98_["make-source-type"]
  local function start_hotkey(self, emit)
    local mods = self.config.mods
    local key = self.config.key
    local handler
    local function _99_()
      return emit("hotkey.events/pressed", {mods = mods, key = key})
    end
    handler = _99_
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
package.preload["event_sources.space-watcher"] = package.preload["event_sources.space-watcher"] or function(...)
  local _local_102_ = require("sheaf.source-registry")
  local make_source_type = _local_102_["make-source-type"]
  local function snapshot_spaces()
    local spaces_layout = hs.spaces.allSpaces()
    local tbl_26_ = {}
    local i_27_ = 0
    for _, screen in ipairs(hs.screen.allScreens()) do
      local val_28_
      do
        local uuid = screen:getUUID()
        val_28_ = {uuid, spaces_layout[uuid]}
      end
      if (nil ~= val_28_) then
        i_27_ = (i_27_ + 1)
        tbl_26_[i_27_] = val_28_
      else
      end
    end
    return tbl_26_
  end
  local function start_space_watcher(self, emit)
    local handler
    local function _104_(space_number)
      return emit("space-watcher.events/space-changed", {["space-number"] = space_number, ["all-spaces"] = snapshot_spaces(), ["active-spaces"] = hs.spaces.activeSpaces()})
    end
    handler = _104_
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
package.preload["event_sources.screen-watcher"] = package.preload["event_sources.screen-watcher"] or function(...)
  local _local_107_ = require("sheaf.source-registry")
  local make_source_type = _local_107_["make-source-type"]
  local function snapshot_spaces()
    local spaces_layout = hs.spaces.allSpaces()
    local tbl_26_ = {}
    local i_27_ = 0
    for _, screen in ipairs(hs.screen.allScreens()) do
      local val_28_
      do
        local uuid = screen:getUUID()
        val_28_ = {uuid, spaces_layout[uuid]}
      end
      if (nil ~= val_28_) then
        i_27_ = (i_27_ + 1)
        tbl_26_[i_27_] = val_28_
      else
      end
    end
    return tbl_26_
  end
  local function start_screen_watcher(self, emit)
    local handler
    local function _109_()
      return emit("screen-watcher.events/screen-changed", {["all-spaces"] = snapshot_spaces(), ["active-spaces"] = hs.spaces.activeSpaces()})
    end
    handler = _109_
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
require("event_sources")
package.preload["commands"] = package.preload["commands"] or function(...)
  local _local_116_ = require("sheaf.command-registry")
  local make_command_registry = _local_116_["make-command-registry"]
  local add_command_21 = _local_116_["add-command!"]
  local _local_119_ = require("commands.toggle-expose")
  local toggle_expose_command = _local_119_["toggle-expose-command"]
  local _local_126_ = require("commands.space-indicator")
  local update_menubar_command = _local_126_["update-menubar-command"]
  local command_registry = make_command_registry()
  add_command_21(command_registry, toggle_expose_command)
  add_command_21(command_registry, update_menubar_command)
  return {["command-registry"] = command_registry}
end
package.preload["sheaf.command-registry"] = package.preload["sheaf.command-registry"] or function(...)
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
  local _local_117_ = require("sheaf.command-registry")
  local make_command = _local_117_["make-command"]
  local expose = hs.expose.new()
  local toggle_expose_command
  local function _118_(params)
    return expose:toggleShow()
  end
  toggle_expose_command = make_command("expose.commands/toggle-show", "Toggle the Hammerspoon Expose window picker", {fn = _118_})
  return {["toggle-expose-command"] = toggle_expose_command}
end
package.preload["commands.space-indicator"] = package.preload["commands.space-indicator"] or function(...)
  local _local_120_ = require("sheaf.command-registry")
  local make_command = _local_120_["make-command"]
  local menubar = hs.menubar.new(true, "cosmicHammerSpaceIndicator")
  if menubar then
    menubar:setTitle("...")
  else
  end
  local update_menubar_command
  local function _122_(params)
    if menubar then
      local _123_
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
        _123_ = tbl_26_
      end
      return menubar:setTitle(table.concat(_123_, "|"))
    else
      return nil
    end
  end
  update_menubar_command = make_command("space-indicator.commands/update-menubar", "Update the space indicator menubar with active space indices", {schema = {["active-spaces"] = __fnl_global__table_3f}, fn = _122_})
  return {["update-menubar-command"] = update_menubar_command}
end
require("commands")
package.preload["behaviors"] = package.preload["behaviors"] or function(...)
  local _local_143_ = require("sheaf.behavior-registry")
  local make_behavior_registry = _local_143_["make-behavior-registry"]
  local add_behavior_21 = _local_143_["add-behavior!"]
  local _local_144_ = require("events")
  local event_registry = _local_144_["event-registry"]
  local _local_145_ = require("commands")
  local command_registry = _local_145_["command-registry"]
  local _local_152_ = require("behaviors.compile-fennel")
  local compile_fennel_behavior = _local_152_["compile-fennel-behavior"]
  local _local_159_ = require("behaviors.reload-hammerspoon")
  local reload_hammerspoon_behavior = _local_159_["reload-hammerspoon-behavior"]
  local _local_162_ = require("behaviors.toggle-expose")
  local toggle_expose_behavior = _local_162_["toggle-expose-behavior"]
  local _local_166_ = require("behaviors.update-space-indicator")
  local update_space_indicator_behavior = _local_166_["update-space-indicator-behavior"]
  local behavior_registry = make_behavior_registry({["event-registry"] = event_registry, ["command-registry"] = command_registry})
  add_behavior_21(behavior_registry, compile_fennel_behavior)
  add_behavior_21(behavior_registry, reload_hammerspoon_behavior)
  add_behavior_21(behavior_registry, toggle_expose_behavior)
  add_behavior_21(behavior_registry, update_space_indicator_behavior)
  return {["behavior-registry"] = behavior_registry}
end
package.preload["sheaf.behavior-registry"] = package.preload["sheaf.behavior-registry"] or function(...)
  local _local_127_ = require("lib.cljlib-shim")
  local some = _local_127_.some
  local _local_128_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_128_["valid-event-selector?"]
  local _local_129_ = require("sheaf.command-registry")
  local command_defined_3f = _local_129_["command-defined?"]
  local _local_130_ = require("lib.hierarchy")
  local isa_3f = _local_130_["isa?"]
  local function make_behavior_registry(opts)
    if (nil == opts["event-registry"]) then
      error("make-behavior-registry: :event-registry is required")
    else
    end
    if (nil == opts["command-registry"]) then
      error("make-behavior-registry: :command-registry is required")
    else
    end
    return {behaviors = {}, ["event-registry"] = opts["event-registry"], ["command-registry"] = opts["command-registry"]}
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
    return {name = opts.name, description = opts.description, ["respond-to"] = opts["respond-to"], commands = (opts.commands or {}), fn = opts.fn}
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
    for alias, cmd_name in pairs(behavior.commands) do
      if not command_defined_3f(registry["command-registry"], cmd_name) then
        error(("add-behavior! " .. tostring(name) .. ": command '" .. tostring(cmd_name) .. "' (alias '" .. tostring(alias) .. "') not found in command-registry"))
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
      local function _141_(_241)
        return isa_3f(registry["event-registry"].hierarchy, event_name, _241)
      end
      return some(_141_, behavior["respond-to"])
    end
  end
  return {["make-behavior-registry"] = make_behavior_registry, ["make-behavior"] = make_behavior, ["add-behavior!"] = add_behavior_21, ["behavior-defined?"] = behavior_defined_3f, ["get-behavior"] = get_behavior, ["list-behaviors"] = list_behaviors, ["behavior-responds-to?"] = behavior_responds_to_3f}
end
package.preload["behaviors.compile-fennel"] = package.preload["behaviors.compile-fennel"] or function(...)
  local _local_146_ = require("sheaf.behavior-registry")
  local make_behavior = _local_146_["make-behavior"]
  local compile_fennel_behavior
  local function _147_(file_change_event)
    local path
    do
      local t_148_ = file_change_event
      if (nil ~= t_148_) then
        t_148_ = t_148_["event-data"]
      else
      end
      if (nil ~= t_148_) then
        t_148_ = t_148_["file-path"]
      else
      end
      path = t_148_
    end
    if ((nil ~= path) and (".fnl" == path:sub(-4))) then
      return print(hs.execute("./compile.sh", true))
    else
      return nil
    end
  end
  compile_fennel_behavior = make_behavior({name = "compile-fennel.behaviors/compile-fennel", description = "Watch fennel files in hammerspoon folder and recompile them.", ["respond-to"] = {"event.kind.fs/file-change"}, fn = _147_})
  return {["compile-fennel-behavior"] = compile_fennel_behavior}
end
package.preload["behaviors.reload-hammerspoon"] = package.preload["behaviors.reload-hammerspoon"] or function(...)
  local _local_153_ = require("sheaf.behavior-registry")
  local make_behavior = _local_153_["make-behavior"]
  local notify = require("notify")
  local reloading_3f = false
  local reload = hs.timer.delayed.new(0.5, hs.reload)
  local reload_hammerspoon_behavior
  local function _154_(file_change_event)
    local path
    do
      local t_155_ = file_change_event
      if (nil ~= t_155_) then
        t_155_ = t_155_["event-data"]
      else
      end
      if (nil ~= t_155_) then
        t_155_ = t_155_["file-path"]
      else
      end
      path = t_155_
    end
    if (not reloading_3f and (nil ~= path) and (".hammerspoon/init.lua" == path:sub(-21))) then
      reloading_3f = true
      notify.warn("Reloading...")
      return reload:start()
    else
      return nil
    end
  end
  reload_hammerspoon_behavior = make_behavior({name = "reload-hammerspoon.behaviors/reload-hammerspoon", description = "When init.lua changes, reload hammerspoon.", ["respond-to"] = {"event.kind.fs/file-change"}, fn = _154_})
  return {["reload-hammerspoon-behavior"] = reload_hammerspoon_behavior}
end
package.preload["behaviors.toggle-expose"] = package.preload["behaviors.toggle-expose"] or function(...)
  local _local_160_ = require("sheaf.behavior-registry")
  local make_behavior = _local_160_["make-behavior"]
  local toggle_expose_behavior
  local function _161_(event, cmd)
    return cmd["toggle-show"]({})
  end
  toggle_expose_behavior = make_behavior({name = "expose.behaviors/toggle-expose", description = "Toggle the Hammerspoon Expose window picker", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["toggle-show"] = "expose.commands/toggle-show"}, fn = _161_})
  return {["toggle-expose-behavior"] = toggle_expose_behavior}
end
package.preload["behaviors.update-space-indicator"] = package.preload["behaviors.update-space-indicator"] or function(...)
  local _local_163_ = require("sheaf.behavior-registry")
  local make_behavior = _local_163_["make-behavior"]
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
  local function _165_(event, cmd)
    local indices = compute_active_space_indices(event["event-data"]["all-spaces"], event["event-data"]["active-spaces"])
    return cmd["update-menubar"]({["active-spaces"] = indices})
  end
  update_space_indicator_behavior = make_behavior({name = "space-indicator.behaviors/update-on-change", description = "Update space indicator menubar when spaces or screens change", ["respond-to"] = {"event.kind.space/changed", "event.kind.screen/any"}, commands = {["update-menubar"] = "space-indicator.commands/update-menubar"}, fn = _165_})
  return {["update-space-indicator-behavior"] = update_space_indicator_behavior}
end
require("behaviors")
package.preload["subscriptions"] = package.preload["subscriptions"] or function(...)
  local _local_187_ = require("sheaf.subscription-registry")
  local make_subscription_registry = _local_187_["make-subscription-registry"]
  local define_subscription_21 = _local_187_["define-subscription!"]
  local _local_188_ = require("events")
  local event_registry = _local_188_["event-registry"]
  local _local_189_ = require("behaviors")
  local behavior_registry = _local_189_["behavior-registry"]
  local _local_190_ = require("event_sources")
  local source_registry = _local_190_["source-registry"]
  local subscription_registry = make_subscription_registry({["event-registry"] = event_registry, ["behavior-registry"] = behavior_registry, ["source-registry"] = source_registry})
  define_subscription_21(subscription_registry, "sub/reload-on-config-change", {description = "Reload Hammerspoon when init.lua changes", behavior = "reload-hammerspoon.behaviors/reload-hammerspoon", ["source-selector"] = "event-source.file-watcher/config-dir", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/compile-on-fnl-change", {description = "Recompile Fennel when .fnl files change", behavior = "compile-fennel.behaviors/compile-fennel", ["source-selector"] = "event-source.file-watcher/config-dir", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/toggle-expose-on-hotkey", {description = "Toggle Expose when ctrl+cmd+e is pressed", behavior = "expose.behaviors/toggle-expose", ["source-selector"] = "event-source.hotkey/ctrl+cmd+e", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-space-change", {description = "Update space indicator when space changes", behavior = "space-indicator.behaviors/update-on-change", ["source-selector"] = "event-source.space-watcher/default", ["event-selector"] = "event.kind.space/changed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-screen-change", {description = "Update space indicator when screen layout changes", behavior = "space-indicator.behaviors/update-on-change", ["source-selector"] = "event-source.screen-watcher/default", ["event-selector"] = "event.kind.screen/layout-changed"})
  return {["subscription-registry"] = subscription_registry}
end
package.preload["sheaf.subscription-registry"] = package.preload["sheaf.subscription-registry"] or function(...)
  local _local_167_ = require("lib.cljlib-shim")
  local hash_set = _local_167_["hash-set"]
  local conj = _local_167_.conj
  local disj = _local_167_.disj
  local into = _local_167_.into
  local seq = _local_167_.seq
  local filter = _local_167_.filter
  local _local_168_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_168_["valid-event-selector?"]
  local _local_169_ = require("sheaf.behavior-registry")
  local behavior_defined_3f = _local_169_["behavior-defined?"]
  local _local_170_ = require("sheaf.source-registry")
  local source_instance_exists_3f = _local_170_["source-instance-exists?"]
  local _local_171_ = require("lib.hierarchy")
  local ancestors = _local_171_.ancestors
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
      local t_177_ = registry.index
      if (nil ~= t_177_) then
        t_177_ = t_177_[source]
      else
      end
      if (nil ~= t_177_) then
        t_177_ = t_177_[event]
      else
      end
      behavior_set = t_177_
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
    local subscription = {name = name, description = opts.description, behavior = opts.behavior, ["event-selector"] = opts["event-selector"], ["source-selector"] = opts["source-selector"], ["target-selector"] = opts["target-selector"], ["require-tags"] = (opts["require-tags"] or {}), ["exclude-tags"] = (opts["exclude-tags"] or {})}
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
local _local_191_ = require("subscriptions")
local subscription_registry = _local_191_["subscription-registry"]
package.preload["sheaf.dispatcher"] = package.preload["sheaf.dispatcher"] or function(...)
  local _local_192_ = require("lib.cljlib-shim")
  local mapv = _local_192_.mapv
  local filter = _local_192_.filter
  local seq = _local_192_.seq
  local _local_193_ = require("sheaf.event-registry")
  local add_event_handler_21 = _local_193_["add-event-handler!"]
  local _local_194_ = require("sheaf.behavior-registry")
  local behavior_responds_to_3f = _local_194_["behavior-responds-to?"]
  local get_behavior = _local_194_["get-behavior"]
  local _local_195_ = require("sheaf.subscription-registry")
  local get_subscribed_behaviors = _local_195_["get-subscribed-behaviors"]
  local _local_196_ = require("sheaf.source-registry")
  local source_instance_exists_3f = _local_196_["source-instance-exists?"]
  local _local_197_ = require("sheaf.command-registry")
  local invoke_command_21 = _local_197_["invoke-command!"]
  local function build_cmd_table(command_registry, behavior)
    local cmd = {}
    for alias, cmd_name in pairs((behavior.commands or {})) do
      local function _198_(params)
        return invoke_command_21(command_registry, cmd_name, params)
      end
      cmd[alias] = _198_
    end
    return cmd
  end
  local function get_behaviors_for_event(subscription_registry, event)
    local behavior_registry = subscription_registry["behavior-registry"]
    local source_registry = subscription_registry["source-registry"]
    if not source_instance_exists_3f(source_registry, event["event-source"]) then
      print(("[WARN] get-behaviors-for-event: unknown source instance '" .. tostring(event["event-source"]) .. "'"))
    else
    end
    local behavior_names = (get_subscribed_behaviors(subscription_registry, event["event-source"], event["event-name"]) or {})
    local valid_names
    local function _200_(name)
      local responds_3f = behavior_responds_to_3f(behavior_registry, name, event["event-name"])
      if not responds_3f then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' does not respond to event '" .. tostring(event["event-name"]) .. "'"))
      else
      end
      return responds_3f
    end
    valid_names = filter(_200_, behavior_names)
    local function _202_(name)
      local behavior = get_behavior(behavior_registry, name)
      if (nil == behavior) then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' not found in registry"))
      else
      end
      return behavior
    end
    return mapv(_202_, (seq(valid_names) or {}))
  end
  local function start_dispatcher_21(subscription_registry)
    local event_registry = subscription_registry["event-registry"]
    local command_registry = subscription_registry["behavior-registry"]["command-registry"]
    local cmd_cache = {}
    local get_cmd_table
    local function _204_(behavior)
      local cached = cmd_cache[behavior.name]
      if cached then
        return cached
      else
        local cmd = build_cmd_table(command_registry, behavior)
        cmd_cache[behavior.name] = cmd
        return cmd
      end
    end
    get_cmd_table = _204_
    local function _206_(event)
      local bs = get_behaviors_for_event(subscription_registry, event)
      for _, behavior in pairs(bs) do
        if behavior then
          behavior.fn(event, get_cmd_table(behavior))
        else
        end
      end
      return nil
    end
    add_event_handler_21(event_registry, "dispatcher/behavior-router", _206_)
    local function _208_(event)
      if _G["event-bus.debug-mode?"] then
        return print("got event", hs.inspect(event))
      else
        return nil
      end
    end
    return add_event_handler_21(event_registry, "dispatcher/debug-handler", _208_)
  end
  return {["start-dispatcher!"] = start_dispatcher_21}
end
local _local_210_ = require("sheaf.dispatcher")
local start_dispatcher_21 = _local_210_["start-dispatcher!"]
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
    local function _214_()
      while process_event_21(event_loop) do
      end
      return nil
    end
    timer = hs.timer.new(0.01, _214_)
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
local _local_216_ = require("sheaf.event-loop")
local make_event_loop = _local_216_["make-event-loop"]
local start_event_loop_21 = _local_216_["start-event-loop!"]
start_dispatcher_21(subscription_registry)
local event_loop = make_event_loop(event_registry)
start_event_loop_21(event_loop)
notify.warn("Reload Succeeded")
return {}
