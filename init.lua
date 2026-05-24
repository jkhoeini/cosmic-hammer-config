hs.console.clearConsole()
_G["event-bus.debug-mode?"] = false
hs.ipc.cliInstall()
hs.window.animationDuration = 0.0
local paper_wm
package.preload["paper-wm"] = package.preload["paper-wm"] or function(...)
  local Window = hs.window
  local Screen = hs.screen
  local Spaces = hs.spaces
  local Timer = hs.timer
  local Watcher = hs.uielement.watcher
  local WindowFilter = hs.window.filter
  local Rect = hs.geometry.rect
  local config = {["window-gap"] = 35, ["screen-margin"] = 16, ["window-ratios"] = {0.421875, 0.84375}}
  local logger = hs.logger.new("PaperWM")
  local Direction = {LEFT = -1, RIGHT = 1, UP = -2, DOWN = 2, WIDTH = 3, HEIGHT = 4, ASCENDING = 5, DESCENDING = 6}
  local window_list = {}
  local index_table = {}
  local ui_watchers = {}
  local focused_window = nil
  local pending_window = nil
  local window_filter = nil
  local screen_watcher = nil
  local hotkeys = {}
  local function get_space(index)
    local layout = Spaces.allSpaces()
    local idx = index
    local result = nil
    for _, screen in ipairs(Screen.allScreens()) do
      if result then break end
      local screen_uuid = screen:getUUID()
      local num_spaces = #layout[screen_uuid]
      if (idx <= num_spaces) then
        result = layout[screen_uuid][idx]
      else
        idx = (idx - num_spaces)
      end
    end
    return result
  end
  local function get_first_visible_window(columns, screen)
    local x = screen:frame().x
    local result = nil
    for _, windows in ipairs((columns or {})) do
      if result then break end
      local window = windows[1]
      if (window:frame().x >= x) then
        result = window
      else
      end
    end
    return result
  end
  local function get_column(space, col)
    return (window_list[space] or {})[col]
  end
  local function get_window(space, col, row)
    return (get_column(space, col) or {})[row]
  end
  local function get_canvas(screen)
    local f = screen:frame()
    local gap = config["window-gap"]
    return Rect((f.x + gap), (f.y + gap), (f.w - (2 * gap)), (f.h - (2 * gap)))
  end
  local function update_index_table_21(space, column)
    local columns = (window_list[space] or {})
    for col = column, #columns do
      for row, window in ipairs(get_column(space, col)) do
        index_table[window:id()] = {space = space, col = col, row = row}
      end
    end
    return nil
  end
  local function move_window_21(window, frame)
    local padding = 0.02
    local watcher = ui_watchers[window:id()]
    if not watcher then
      logger.e("window does not have ui watcher")
      return
    else
    end
    if (frame == window:frame()) then
      logger.v("no change in window frame")
      return
    else
    end
    watcher:stop()
    window:setFrame(frame)
    local function _5_()
      return watcher:start({Watcher.windowMoved, Watcher.windowResized})
    end
    return Timer.doAfter((Window.animationDuration + padding), _5_)
  end
  local function tile_column_21(windows, bounds, h, w, id, h4id)
    local last_window = nil
    local frame = nil
    local col_width = w
    for _, window in ipairs(windows) do
      frame = window:frame()
      col_width = (col_width or frame.w)
      if bounds.x then
        frame.x = bounds.x
      elseif bounds.x2 then
        frame.x = (bounds.x2 - col_width)
      else
      end
      if h then
        if (id and h4id and (window:id() == id)) then
          frame.h = h4id
        else
          frame.h = h
        end
      else
      end
      frame.y = bounds.y
      frame.w = col_width
      frame.y2 = math.min(frame.y2, bounds.y2)
      move_window_21(window, frame)
      bounds.y = math.min((frame.y2 + config["window-gap"]), bounds.y2)
      last_window = window
    end
    if (frame and (frame.y2 ~= bounds.y2)) then
      frame.y2 = bounds.y2
      move_window_21(last_window, frame)
    else
    end
    return col_width
  end
  local function tile_space_21(space)
    if (not space or (Spaces.spaceType(space) ~= "user")) then
      logger.e("current space invalid")
      return
    else
    end
    local screen = Screen(Spaces.spaceDisplay(space))
    if not screen then
      logger.e("no screen for space")
      return
    else
    end
    local fw = Window.focusedWindow()
    local anchor_window
    if (fw and (Spaces.windowSpaces(fw)[1] == space)) then
      anchor_window = fw
    else
      anchor_window = get_first_visible_window(window_list[space], screen)
    end
    if not anchor_window then
      logger.e("no anchor window in space")
      return
    else
    end
    local anchor_index = index_table[anchor_window:id()]
    if not anchor_index then
      logger.e("anchor index not found")
      return
    else
    end
    local screen_frame = screen:frame()
    local left_margin = (screen_frame.x + config["screen-margin"])
    local right_margin = (screen_frame.x2 - config["screen-margin"])
    local canvas = get_canvas(screen)
    local anchor_frame = anchor_window:frame()
    anchor_frame.x = math.max(anchor_frame.x, canvas.x)
    anchor_frame.w = math.min(anchor_frame.w, canvas.w)
    anchor_frame.h = math.min(anchor_frame.h, canvas.h)
    if (anchor_frame.x2 > canvas.x2) then
      anchor_frame.x = (canvas.x2 - anchor_frame.w)
    else
    end
    local column = get_column(space, anchor_index.col)
    if not column then
      logger.e("no anchor window column")
      return
    else
    end
    if (#column == 1) then
      anchor_frame.y = canvas.y
      anchor_frame.h = canvas.h
      move_window_21(anchor_window, anchor_frame)
    else
      local n = (#column - 1)
      local h = math.floor((math.max(0, (canvas.h - anchor_frame.h - (n * config["window-gap"]))) / n))
      local bounds = {x = anchor_frame.x, x2 = nil, y = canvas.y, y2 = canvas.y2}
      tile_column_21(column, bounds, h, anchor_frame.w, anchor_window:id(), anchor_frame.h)
    end
    local x = math.min((anchor_frame.x2 + config["window-gap"]), right_margin)
    for col = (anchor_index.col + 1), #(window_list[space] or {}) do
      local bounds = {x = x, x2 = nil, y = canvas.y, y2 = canvas.y2}
      local column_width = tile_column_21(get_column(space, col), bounds)
      x = math.min((x + column_width + config["window-gap"]), right_margin)
    end
    local x2 = math.max((anchor_frame.x - config["window-gap"]), left_margin)
    for col = (anchor_index.col - 1), 1, -1 do
      local bounds = {x = nil, x2 = x2, y = canvas.y, y2 = canvas.y2}
      local column_width = tile_column_21(get_column(space, col), bounds)
      x2 = math.max((x2 - column_width - config["window-gap"]), left_margin)
    end
    return nil
  end
  local add_window_21 = nil
  local remove_window_21 = nil
  local focus_window = nil
  local function window_event_handler(window, event)
    logger.df("%s for [%s] id: %d", event, window, ((window and window:id()) or -1))
    local space = nil
    if (event == "windowFocused") then
      if (pending_window and (window == pending_window)) then
        local function _18_()
          logger.vf("pending window timer for %s", window)
          return window_event_handler(window, event)
        end
        Timer.doAfter(Window.animationDuration, _18_)
        return
      else
      end
      focused_window = window
      space = Spaces.windowSpaces(window)[1]
    elseif ((event == "windowVisible") or (event == "windowUnfullscreened")) then
      space = add_window_21(window)
      if (pending_window and (window == pending_window)) then
        pending_window = nil
      elseif not space then
        pending_window = window
        local function _20_()
          return window_event_handler(window, event)
        end
        Timer.doAfter(Window.animationDuration, _20_)
        return
      else
      end
    elseif (event == "windowNotVisible") then
      space = remove_window_21(window)
    elseif (event == "windowFullscreened") then
      space = remove_window_21(window, true)
    elseif ((event == "AXWindowMoved") or (event == "AXWindowResized")) then
      space = Spaces.windowSpaces(window)[1]
    else
    end
    if space then
      return tile_space_21(space)
    else
      return nil
    end
  end
  local function focus_space(space, window)
    local screen = Screen(Spaces.spaceDisplay(space))
    if not screen then
      return
    else
    end
    local target_window = (window or get_first_visible_window(window_list[space], screen))
    local do_space_focus
    local function _25_()
      if target_window then
        local function check_focus(win, n)
          local focused_3f = true
          for _ = 1, n do
            focused_3f = (focused_3f and (Window.focusedWindow() == win))
            if not focused_3f then
              return false
            else
            end
            coroutine.yield(false)
          end
          return focused_3f
        end
        while true do
          target_window:focus()
          coroutine.yield(false)
          if ((Spaces.focusedSpace() == space) and check_focus(target_window, 3)) then
            break
          else
          end
        end
      else
        local point = screen:frame()
        point.x = (point.x + math.floor((point.w / 2)))
        point.y = (point.y - 4)
        while true do
          hs.eventtap.leftClick(point)
          coroutine.yield(false)
          if (Spaces.focusedSpace() == space) then
            break
          else
          end
        end
      end
      hs.mouse.absolutePosition(hs.geometry.rectMidPoint(screen:frame()))
      return true
    end
    do_space_focus = coroutine.wrap(_25_)
    local start_time = Timer.secondsSinceEpoch()
    local function _30_(timer)
      if ((Timer.secondsSinceEpoch() - start_time) > 4) then
        logger.ef("focusSpace() timeout! space %d focused space %d", space, Spaces.focusedSpace())
        return timer:stop()
      else
        return nil
      end
    end
    return Timer.doUntil(do_space_focus, _30_, Window.animationDuration)
  end
  local function _32_(add_win)
    if (add_win:tabCount() > 0) then
      hs.notify.show("PaperWM", "Windows with tabs are not supported!", "See https://github.com/mogenson/PaperWM.spoon/issues/39")
      return
    else
    end
    if index_table[add_win:id()] then
      return
    else
    end
    local space = Spaces.windowSpaces(add_win)[1]
    if not space then
      logger.e("add window does not have a space")
      return
    else
    end
    if not window_list[space] then
      window_list[space] = {}
    else
    end
    local add_column = 1
    if (focused_window and ((index_table[focused_window:id()] or {}).space == space) and (focused_window:id() ~= add_win:id())) then
      add_column = (index_table[focused_window:id()].col + 1)
    else
      local x = add_win:frame().center.x
      for col, windows in ipairs(window_list[space]) do
        if (x < windows[1]:frame().center.x) then
          add_column = col
          break
        else
        end
      end
    end
    table.insert(window_list[space], add_column, {add_win})
    update_index_table_21(space, add_column)
    do
      local watcher
      local function _39_(window, event)
        return window_event_handler(window, event)
      end
      watcher = add_win:newWatcher(_39_)
      watcher:start({Watcher.windowMoved, Watcher.windowResized})
      ui_watchers[add_win:id()] = watcher
    end
    return space
  end
  add_window_21 = _32_
  local function _40_(remove_win, _3fskip_focus)
    local remove_index = index_table[remove_win:id()]
    if not remove_index then
      logger.e("remove index not found")
      return
    else
    end
    if not _3fskip_focus then
      local fw = Window.focusedWindow()
      if (fw and (remove_win:id() == fw:id())) then
        for _, direction in ipairs({Direction.DOWN, Direction.UP, Direction.LEFT, Direction.RIGHT}) do
          if focus_window(direction, remove_index) then
            break
          else
          end
        end
      else
      end
    else
    end
    table.remove(window_list[remove_index.space][remove_index.col], remove_index.row)
    if (#window_list[remove_index.space][remove_index.col] == 0) then
      table.remove(window_list[remove_index.space], remove_index.col)
    else
    end
    ui_watchers[remove_win:id()]:stop()
    ui_watchers[remove_win:id()] = nil
    index_table[remove_win:id()] = nil
    update_index_table_21(remove_index.space, remove_index.col)
    if (#window_list[remove_index.space] == 0) then
      window_list[remove_index.space] = nil
    else
    end
    return remove_index.space
  end
  remove_window_21 = _40_
  local function _47_(direction, _3ffocused_index)
    local fi = _3ffocused_index
    if not fi then
      local fw = Window.focusedWindow()
      if not fw then
        logger.d("focused window not found")
        return
      else
      end
      fi = index_table[fw:id()]
    else
    end
    if not fi then
      logger.e("focused index not found")
      return
    else
    end
    local new_focused = nil
    if ((direction == Direction.LEFT) or (direction == Direction.RIGHT)) then
      for row = fi.row, 1, -1 do
        new_focused = get_window(fi.space, (fi.col + direction), row)
        if new_focused then
          break
        else
        end
      end
    elseif ((direction == Direction.UP) or (direction == Direction.DOWN)) then
      new_focused = get_window(fi.space, fi.col, (fi.row + math.floor((direction / 2))))
    else
    end
    if not new_focused then
      logger.d("new focused window not found")
      return
    else
    end
    new_focused:focus()
    return new_focused
  end
  focus_window = _47_
  local function swap_windows_21(direction)
    local fw = Window.focusedWindow()
    if not fw then
      logger.d("focused window not found")
      return
    else
    end
    local fi = index_table[fw:id()]
    if not fi then
      logger.e("focused index not found")
      return
    else
    end
    if ((direction == Direction.LEFT) or (direction == Direction.RIGHT)) then
      local target_col = (fi.col + direction)
      local target_column = get_column(fi.space, target_col)
      if not target_column then
        logger.d("target column not found")
        return
      else
      end
      local focused_column = get_column(fi.space, fi.col)
      window_list[fi.space][target_col] = focused_column
      window_list[fi.space][fi.col] = target_column
      for row, window in ipairs(target_column) do
        index_table[window:id()] = {space = fi.space, col = fi.col, row = row}
      end
      for row, window in ipairs(focused_column) do
        index_table[window:id()] = {space = fi.space, col = target_col, row = row}
      end
      local focused_frame = fw:frame()
      local target_frame = target_column[1]:frame()
      if (direction == Direction.LEFT) then
        focused_frame.x = target_frame.x
        target_frame.x = (focused_frame.x2 + config["window-gap"])
      else
        target_frame.x = focused_frame.x
        focused_frame.x = (target_frame.x2 + config["window-gap"])
      end
      for _, window in ipairs(target_column) do
        local frame = window:frame()
        frame.x = target_frame.x
        move_window_21(window, frame)
      end
      for _, window in ipairs(focused_column) do
        local frame = window:frame()
        frame.x = focused_frame.x
        move_window_21(window, frame)
      end
    elseif ((direction == Direction.UP) or (direction == Direction.DOWN)) then
      local target_row = (fi.row + math.floor((direction / 2)))
      local target_window = get_window(fi.space, fi.col, target_row)
      if not target_window then
        logger.d("target window not found")
        return
      else
      end
      window_list[fi.space][fi.col][target_row] = fw
      window_list[fi.space][fi.col][fi.row] = target_window
      do
        local target_index = {space = fi.space, col = fi.col, row = target_row}
        index_table[target_window:id()] = fi
        index_table[fw:id()] = target_index
      end
      local focused_frame = fw:frame()
      local target_frame = target_window:frame()
      if (direction == Direction.UP) then
        focused_frame.y = target_frame.y
        target_frame.y = (focused_frame.y2 + config["window-gap"])
      else
        target_frame.y = focused_frame.y
        focused_frame.y = (target_frame.y2 + config["window-gap"])
      end
      move_window_21(fw, focused_frame)
      move_window_21(target_window, target_frame)
    else
    end
    return tile_space_21(fi.space)
  end
  local function center_window_21()
    local fw = Window.focusedWindow()
    if not fw then
      logger.d("focused window not found")
      return
    else
    end
    local frame = fw:frame()
    local sf = fw:screen():frame()
    frame.x = ((sf.x + math.floor((sf.w / 2))) - math.floor((frame.w / 2)))
    move_window_21(fw, frame)
    return tile_space_21(Spaces.windowSpaces(fw)[1])
  end
  local function set_window_full_width_21()
    local fw = Window.focusedWindow()
    if not fw then
      logger.d("focused window not found")
      return
    else
    end
    local canvas = get_canvas(fw:screen())
    local frame = fw:frame()
    frame.x = canvas.x
    frame.w = canvas.w
    move_window_21(fw, frame)
    return tile_space_21(Spaces.windowSpaces(fw)[1])
  end
  local function cycle_window_size_21(direction, cycle_direction)
    local fw = Window.focusedWindow()
    if not fw then
      logger.d("focused window not found")
      return
    else
    end
    local function find_new_size(area_size, frame_size, dir)
      local sizes
      do
        local tbl_26_ = {}
        local i_27_ = 0
        for _, ratio in ipairs(config["window-ratios"]) do
          local val_28_ = ((ratio * (area_size + config["window-gap"])) - config["window-gap"])
          if (nil ~= val_28_) then
            i_27_ = (i_27_ + 1)
            tbl_26_[i_27_] = val_28_
          else
          end
        end
        sizes = tbl_26_
      end
      local new_size = nil
      if (dir == Direction.ASCENDING) then
        new_size = sizes[1]
        for _, size in ipairs(sizes) do
          if (size > (frame_size + 10)) then
            new_size = size
            break
          else
          end
        end
      elseif (dir == Direction.DESCENDING) then
        new_size = sizes[#sizes]
        for i = #sizes, 1, -1 do
          if (sizes[i] < (frame_size - 10)) then
            new_size = sizes[i]
            break
          else
          end
        end
      else
        logger.e("invalid cycle direction")
        return
      end
      return new_size
    end
    local canvas = get_canvas(fw:screen())
    local frame = fw:frame()
    if (direction == Direction.WIDTH) then
      local new_width = find_new_size(canvas.w, frame.w, cycle_direction)
      frame.x = (frame.x + math.floor(((frame.w - new_width) / 2)))
      frame.w = new_width
    elseif (direction == Direction.HEIGHT) then
      local new_height = find_new_size(canvas.h, frame.h, cycle_direction)
      frame.y = math.max(canvas.y, (frame.y + math.floor(((frame.h - new_height) / 2))))
      frame.h = new_height
      frame.y = (frame.y - math.max(0, (frame.y2 - canvas.y2)))
    else
      logger.e("invalid direction for cycle")
      return
    end
    move_window_21(fw, frame)
    return tile_space_21(Spaces.windowSpaces(fw)[1])
  end
  local function slurp_window_21()
    local fw = Window.focusedWindow()
    if not fw then
      logger.d("focused window not found")
      return
    else
    end
    local fi = index_table[fw:id()]
    if not fi then
      logger.e("focused index not found")
      return
    else
    end
    local column = get_column(fi.space, (fi.col - 1))
    if not column then
      logger.d("column not found")
      return
    else
    end
    table.remove(window_list[fi.space][fi.col], fi.row)
    if (#window_list[fi.space][fi.col] == 0) then
      table.remove(window_list[fi.space], fi.col)
    else
    end
    table.insert(column, fw)
    local num_windows = #column
    index_table[fw:id()] = {space = fi.space, col = (fi.col - 1), row = num_windows}
    update_index_table_21(fi.space, fi.col)
    local canvas = get_canvas(fw:screen())
    local bounds = {x = column[1]:frame().x, x2 = nil, y = canvas.y, y2 = canvas.y2}
    local h = math.floor((math.max(0, (canvas.h - ((num_windows - 1) * config["window-gap"]))) / num_windows))
    tile_column_21(column, bounds, h)
    return tile_space_21(fi.space)
  end
  local function barf_window_21()
    local fw = Window.focusedWindow()
    if not fw then
      logger.d("focused window not found")
      return
    else
    end
    local fi = index_table[fw:id()]
    if not fi then
      logger.e("focused index not found")
      return
    else
    end
    local column = get_column(fi.space, fi.col)
    if (#column == 1) then
      logger.d("only window in column")
      return
    else
    end
    table.remove(column, fi.row)
    table.insert(window_list[fi.space], (fi.col + 1), {fw})
    update_index_table_21(fi.space, fi.col)
    local num_windows = #column
    local canvas = get_canvas(fw:screen())
    local frame = fw:frame()
    local bounds = {x = frame.x, x2 = nil, y = canvas.y, y2 = canvas.y2}
    local h = math.floor((math.max(0, (canvas.h - ((num_windows - 1) * config["window-gap"]))) / num_windows))
    frame.y = canvas.y
    frame.x = (frame.x2 + config["window-gap"])
    frame.h = canvas.h
    move_window_21(fw, frame)
    tile_column_21(column, bounds, h)
    return tile_space_21(fi.space)
  end
  local function switch_to_space_21(index)
    local space = get_space(index)
    if not space then
      logger.d("space not found")
      return
    else
    end
    Spaces.gotoSpace(space)
    return focus_space(space)
  end
  local function increment_space_21(direction)
    if ((direction ~= Direction.LEFT) and (direction ~= Direction.RIGHT)) then
      logger.d("move is invalid, left and right only")
      return
    else
    end
    local curr_space_id = Spaces.focusedSpace()
    local layout = Spaces.allSpaces()
    local curr_space_idx = -1
    local num_spaces = 0
    for _, screen in ipairs(Screen.allScreens()) do
      local screen_uuid = screen:getUUID()
      if (curr_space_idx < 0) then
        for idx, space_id in ipairs(layout[screen_uuid]) do
          if (curr_space_id == space_id) then
            curr_space_idx = (idx + num_spaces)
            break
          else
          end
        end
      else
      end
      num_spaces = (num_spaces + #layout[screen_uuid])
    end
    if (curr_space_idx >= 0) then
      local new_idx = ((((curr_space_idx - 1) + direction) % num_spaces) + 1)
      return switch_to_space_21(new_idx)
    else
      return nil
    end
  end
  local function move_window_to_space_21(index, _3fwindow)
    local fw = (_3fwindow or Window.focusedWindow())
    if not fw then
      logger.d("focused window not found")
      return
    else
    end
    local fi = index_table[fw:id()]
    if not fi then
      logger.e("focused index not found")
      return
    else
    end
    local new_space = get_space(index)
    if not new_space then
      logger.d("space not found")
      return
    else
    end
    if (new_space == Spaces.windowSpaces(fw)[1]) then
      logger.d("window already on space")
      return
    else
    end
    if (Spaces.spaceType(new_space) ~= "user") then
      logger.d("space is invalid")
      return
    else
    end
    local screen = Screen(Spaces.spaceDisplay(new_space))
    if not screen then
      logger.d("no screen for space")
      return
    else
    end
    local old_space = remove_window_21(fw, true)
    if not old_space then
      logger.e("can't remove focused window")
      return
    else
    end
    local version = hs.host.operatingSystemVersion()
    if (((version.major * 100) + version.minor) >= 1405) then
      local start_point = fw:frame()
      local end_point = screen:frame()
      start_point.x = (start_point.x + math.floor((start_point.w / 2)))
      start_point.y = (start_point.y + 4)
      end_point.x = (end_point.x + math.floor((end_point.w / 2)))
      end_point.y = (end_point.y + config["window-gap"] + 4)
      local do_window_drag
      local function _88_()
        start_point.x = (start_point.x + math.floor(((end_point.x - start_point.x) / 2)))
        start_point.y = (start_point.y + math.floor(((end_point.y - start_point.y) / 2)))
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, start_point):post()
        coroutine.yield(false)
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, end_point):post()
        while true do
          coroutine.yield(false)
          if (Spaces.windowSpaces(fw)[1] == new_space) then
            break
          else
          end
        end
        add_window_21(fw)
        tile_space_21(old_space)
        tile_space_21(new_space)
        focus_space(new_space, fw)
        return true
      end
      do_window_drag = coroutine.wrap(_88_)
      local start_time = Timer.secondsSinceEpoch()
      hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, start_point):post()
      Spaces.gotoSpace(new_space)
      local function _90_(timer)
        if ((Timer.secondsSinceEpoch() - start_time) > 4) then
          logger.ef("moveWindowToSpace() timeout! new %d curr %d win %d", new_space, Spaces.activeSpaceOnScreen(screen:id()), Spaces.windowSpaces(fw)[1])
          return timer:stop()
        else
          return nil
        end
      end
      return Timer.doUntil(do_window_drag, _90_, Window.animationDuration)
    else
      Spaces.moveWindowToSpace(fw, new_space)
      add_window_21(fw)
      tile_space_21(old_space)
      tile_space_21(new_space)
      Spaces.gotoSpace(new_space)
      return focus_space(new_space, fw)
    end
  end
  local function refresh_windows_21()
    local all_windows = window_filter:getWindows()
    local retile_spaces = {}
    for _, window in ipairs(all_windows) do
      local index = index_table[window:id()]
      if not index then
        local space = add_window_21(window)
        if space then
          retile_spaces[space] = true
        else
        end
      elseif (index.space ~= Spaces.windowSpaces(window)[1]) then
        remove_window_21(window)
        local space = add_window_21(window)
        if space then
          retile_spaces[space] = true
        else
        end
      else
      end
    end
    for space, _ in pairs(retile_spaces) do
      tile_space_21(space)
    end
    return nil
  end
  local function bind_hotkeys_21()
    local bind
    local function _96_(mods, key, action)
      return table.insert(hotkeys, hs.hotkey.bind(mods, key, action))
    end
    bind = _96_
    local function _97_()
      return focus_window(Direction.LEFT)
    end
    bind({"alt", "cmd"}, "left", _97_)
    local function _98_()
      return focus_window(Direction.RIGHT)
    end
    bind({"alt", "cmd"}, "right", _98_)
    local function _99_()
      return focus_window(Direction.UP)
    end
    bind({"alt", "cmd"}, "up", _99_)
    local function _100_()
      return focus_window(Direction.DOWN)
    end
    bind({"alt", "cmd"}, "down", _100_)
    local function _101_()
      return swap_windows_21(Direction.LEFT)
    end
    bind({"alt", "cmd", "shift"}, "left", _101_)
    local function _102_()
      return swap_windows_21(Direction.RIGHT)
    end
    bind({"alt", "cmd", "shift"}, "right", _102_)
    local function _103_()
      return swap_windows_21(Direction.UP)
    end
    bind({"alt", "cmd", "shift"}, "up", _103_)
    local function _104_()
      return swap_windows_21(Direction.DOWN)
    end
    bind({"alt", "cmd", "shift"}, "down", _104_)
    local function _105_()
      return center_window_21()
    end
    bind({"alt", "cmd"}, "c", _105_)
    local function _106_()
      return set_window_full_width_21()
    end
    bind({"alt", "cmd"}, "f", _106_)
    local function _107_()
      return cycle_window_size_21(Direction.WIDTH, Direction.ASCENDING)
    end
    bind({"alt", "cmd"}, "r", _107_)
    local function _108_()
      return cycle_window_size_21(Direction.HEIGHT, Direction.ASCENDING)
    end
    bind({"alt", "cmd", "shift"}, "r", _108_)
    local function _109_()
      return cycle_window_size_21(Direction.WIDTH, Direction.DESCENDING)
    end
    bind({"ctrl", "alt", "cmd"}, "r", _109_)
    local function _110_()
      return cycle_window_size_21(Direction.HEIGHT, Direction.DESCENDING)
    end
    bind({"ctrl", "alt", "cmd", "shift"}, "r", _110_)
    local function _111_()
      return slurp_window_21()
    end
    bind({"alt", "cmd"}, "i", _111_)
    local function _112_()
      return barf_window_21()
    end
    bind({"alt", "cmd"}, "o", _112_)
    local function _113_()
      return increment_space_21(Direction.LEFT)
    end
    bind({"alt", "cmd"}, ",", _113_)
    local function _114_()
      return increment_space_21(Direction.RIGHT)
    end
    bind({"alt", "cmd"}, ".", _114_)
    for i = 1, 9 do
      local function _115_()
        return switch_to_space_21(i)
      end
      bind({"alt", "cmd"}, tostring(i), _115_)
    end
    for i = 1, 9 do
      local function _116_()
        return move_window_to_space_21(i)
      end
      bind({"alt", "cmd", "shift"}, tostring(i), _116_)
    end
    local function _117_()
      return __fnl_global__stop_21()
    end
    return bind({"alt", "cmd", "shift"}, "q", _117_)
  end
  local function start_21()
    if not Spaces.screensHaveSeparateSpaces() then
      logger.e("please check 'Displays have separate Spaces' in System Preferences -> Mission Control")
    else
    end
    window_list = {}
    index_table = {}
    ui_watchers = {}
    window_filter = WindowFilter.new():setOverrideFilter({visible = true, hasTitlebar = true, allowRoles = "AXStandardWindow", fullscreen = false})
    refresh_windows_21()
    local function _119_(window, _, event)
      return window_event_handler(window, event)
    end
    window_filter:subscribe({WindowFilter.windowFocused, WindowFilter.windowVisible, WindowFilter.windowNotVisible, WindowFilter.windowFullscreened, WindowFilter.windowUnfullscreened}, _119_)
    local function _120_()
      return refresh_windows_21()
    end
    screen_watcher = Screen.watcher.new(_120_)
    screen_watcher:start()
    return bind_hotkeys_21()
  end
  local function stop_21()
    if window_filter then
      window_filter:unsubscribeAll()
    else
    end
    for _, watcher in pairs(ui_watchers) do
      watcher:stop()
    end
    if screen_watcher then
      screen_watcher:stop()
    else
    end
    for _, hk in ipairs(hotkeys) do
      hk:delete()
    end
    hotkeys = {}
    return nil
  end
  return {["start!"] = start_21, ["stop!"] = stop_21, ["refresh-windows!"] = refresh_windows_21, config = config}
end
paper_wm = require("paper-wm")
paper_wm["start!"]()
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
    local function _130_()
      return remove_notification(notif)
    end
    close_btn:setClickCallback(_130_)
    local function _131_()
      return remove_notification(notif)
    end
    notif["timer"] = hs.timer.doAfter(notification_duration, _131_)
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
  local _local_133_ = require("lib.cljlib-shim")
  local string_3f = _local_133_["string?"]
  local _local_165_ = require("sheaf.event-registry")
  local make_event_registry = _local_165_["make-event-registry"]
  local define_event_21 = _local_165_["define-event!"]
  local _local_166_ = require("lib.hierarchy")
  local make_hierarchy = _local_166_["make-hierarchy"]
  local derive_21 = _local_166_["derive!"]
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
  local _local_134_ = require("lib.cljlib-shim")
  local some = _local_134_.some
  local seq = _local_134_.seq
  local _local_158_ = require("lib.hierarchy")
  local descendants = _local_158_.descendants
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
    local or_161_ = event_defined_3f(registry, selector)
    if not or_161_ then
      local function _162_(_241)
        return event_defined_3f(registry, _241)
      end
      or_161_ = some(_162_, seq(descendants(registry.hierarchy, selector)))
    end
    return or_161_
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
  local _local_135_ = require("lib.cljlib-shim")
  local hash_set = _local_135_["hash-set"]
  local conj = _local_135_.conj
  local disj = _local_135_.disj
  local contains_3f = _local_135_["contains?"]
  local into = _local_135_.into
  local mapcat = _local_135_.mapcat
  local empty_3f = _local_135_["empty?"]
  local seq = _local_135_.seq
  local function ensure_entry(h, tag)
    if (nil == h[tag]) then
      h[tag] = {parents = hash_set(), children = hash_set()}
      return nil
    else
      return nil
    end
  end
  local function parents(h, tag)
    local _138_
    do
      local t_137_ = h
      if (nil ~= t_137_) then
        t_137_ = t_137_[tag]
      else
      end
      if (nil ~= t_137_) then
        t_137_ = t_137_.parents
      else
      end
      _138_ = t_137_
    end
    return (_138_ or hash_set())
  end
  local function children(h, tag)
    local _142_
    do
      local t_141_ = h
      if (nil ~= t_141_) then
        t_141_ = t_141_[tag]
      else
      end
      if (nil ~= t_141_) then
        t_141_ = t_141_.children
      else
      end
      _142_ = t_141_
    end
    return (_142_ or hash_set())
  end
  local function ancestors(h, tag)
    local ps = parents(h, tag)
    if empty_3f(ps) then
      return ps
    else
      local function _145_(_241)
        return ancestors(h, _241)
      end
      return into(ps, mapcat(_145_, seq(ps)))
    end
  end
  local function descendants(h, tag)
    local cs = children(h, tag)
    if empty_3f(cs) then
      return cs
    else
      local function _147_(_241)
        return descendants(h, _241)
      end
      return into(cs, mapcat(_147_, seq(cs)))
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
local _local_167_ = require("events")
local event_registry = _local_167_["event-registry"]
package.preload["traits"] = package.preload["traits"] or function(...)
  local _local_168_ = require("lib.hierarchy")
  local make_hierarchy = _local_168_["make-hierarchy"]
  local derive_21 = _local_168_["derive!"]
  local _local_177_ = require("sheaf.trait-registry")
  local make_trait_registry = _local_177_["make-trait-registry"]
  local make_trait = _local_177_["make-trait"]
  local add_trait_21 = _local_177_["add-trait!"]
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
  derive_21(trait_hierarchy, "trait/has-window-filter", "trait.kind/windowing")
  derive_21(trait_hierarchy, "trait/has-layout", "trait.kind/windowing")
  derive_21(trait_hierarchy, "trait/has-delayed-timer", "trait.kind/scheduling")
  local trait_registry = make_trait_registry({hierarchy = trait_hierarchy})
  add_trait_21(trait_registry, make_trait("trait/has-menubar", "Component state includes an hs.menubar object", {schema = {menubar = non_nil_3f}}))
  add_trait_21(trait_registry, make_trait("trait/has-expose", "Component state includes an hs.expose object", {schema = {expose = non_nil_3f}}))
  add_trait_21(trait_registry, make_trait("trait/has-chooser", "Component state includes an hs.chooser object", {schema = {chooser = non_nil_3f}}))
  add_trait_21(trait_registry, make_trait("trait/has-window-filter", "Component state includes an hs.window.filter", {schema = {["window-filter"] = non_nil_3f}}))
  add_trait_21(trait_registry, make_trait("trait/has-layout", "Component state includes window layout tables", {schema = {["window-list"] = non_nil_3f, ["index-table"] = non_nil_3f}}))
  add_trait_21(trait_registry, make_trait("trait/has-delayed-timer", "Component state includes an hs.timer.delayed", {schema = {timer = non_nil_3f}}))
  return {["trait-registry"] = trait_registry}
end
package.preload["sheaf.trait-registry"] = package.preload["sheaf.trait-registry"] or function(...)
  local _local_169_ = require("lib.hierarchy")
  local isa_3f = _local_169_["isa?"]
  local function make_trait_registry(opts)
    if (nil == opts.hierarchy) then
      error("make-trait-registry: :hierarchy is required")
    else
    end
    return {traits = {}, hierarchy = opts.hierarchy}
  end
  local function make_trait(name, description, opts)
    if (nil == opts.schema) then
      error(("make-trait: :schema is required for " .. tostring(name)))
    else
    end
    return {name = name, description = description, schema = opts.schema}
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
    for key, pred in pairs(trait.schema) do
      if not ok then break end
      local val = state[key]
      if not pred(val) then
        ok = false
      else
      end
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
local _local_178_ = require("traits")
local trait_registry = _local_178_["trait-registry"]
package.preload["components"] = package.preload["components"] or function(...)
  local _local_179_ = require("lib.hierarchy")
  local make_hierarchy = _local_179_["make-hierarchy"]
  local derive_21 = _local_179_["derive!"]
  local _local_197_ = require("sheaf.component-registry")
  local make_component_registry = _local_197_["make-component-registry"]
  local add_component_type_21 = _local_197_["add-component-type!"]
  local start_component_21 = _local_197_["start-component!"]
  local make_instance_name = _local_197_["make-instance-name"]
  local _local_208_ = require("sheaf.tag-registry")
  local make_tag_registry = _local_208_["make-tag-registry"]
  local attach_tag_21 = _local_208_["attach-tag!"]
  local _local_209_ = require("traits")
  local trait_registry = _local_209_["trait-registry"]
  local _local_215_ = require("components.space-indicator")
  local space_indicator_type = _local_215_["space-indicator-type"]
  local _local_218_ = require("components.expose")
  local expose_type = _local_218_["expose-type"]
  local _local_221_ = require("components.emacs")
  local emacs_type = _local_221_["emacs-type"]
  local _local_225_ = require("components.reload-hammerspoon")
  local reload_hammerspoon_type = _local_225_["reload-hammerspoon-type"]
  local _local_228_ = require("components.compile-fennel")
  local compile_fennel_type = _local_228_["compile-fennel-type"]
  local component_hierarchy = make_hierarchy()
  derive_21(component_hierarchy, "component.kind/space-indicator", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/expose", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/emacs", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/reload-hammerspoon", "component.kind/any")
  derive_21(component_hierarchy, "component.kind/compile-fennel", "component.kind/any")
  derive_21(component_hierarchy, "component.type/space-indicator", "component.kind/space-indicator")
  derive_21(component_hierarchy, "component.type/expose", "component.kind/expose")
  derive_21(component_hierarchy, "component.type/emacs", "component.kind/emacs")
  derive_21(component_hierarchy, "component.type/reload-hammerspoon", "component.kind/reload-hammerspoon")
  derive_21(component_hierarchy, "component.type/compile-fennel", "component.kind/compile-fennel")
  local component_registry = make_component_registry({hierarchy = component_hierarchy, ["trait-registry"] = trait_registry})
  add_component_type_21(component_registry, space_indicator_type)
  add_component_type_21(component_registry, expose_type)
  add_component_type_21(component_registry, emacs_type)
  add_component_type_21(component_registry, reload_hammerspoon_type)
  add_component_type_21(component_registry, compile_fennel_type)
  local space_indicator_name = make_instance_name("component.type/space-indicator", "main")
  local expose_name = make_instance_name("component.type/expose", "main")
  local emacs_name = make_instance_name("component.type/emacs", "main")
  local reload_hammerspoon_name = make_instance_name("component.type/reload-hammerspoon", "main")
  local compile_fennel_name = make_instance_name("component.type/compile-fennel", "main")
  start_component_21(component_registry, "component.type/space-indicator", space_indicator_name, {})
  start_component_21(component_registry, "component.type/expose", expose_name, {})
  start_component_21(component_registry, "component.type/emacs", emacs_name, {})
  start_component_21(component_registry, "component.type/reload-hammerspoon", reload_hammerspoon_name, {})
  start_component_21(component_registry, "component.type/compile-fennel", compile_fennel_name, {})
  local tag_registry = make_tag_registry()
  attach_tag_21(tag_registry, space_indicator_name, "tag/space-indicator")
  attach_tag_21(tag_registry, expose_name, "tag/expose")
  attach_tag_21(tag_registry, emacs_name, "tag/emacs")
  attach_tag_21(tag_registry, reload_hammerspoon_name, "tag/reload-hammerspoon")
  attach_tag_21(tag_registry, compile_fennel_name, "tag/compile-fennel")
  return {["component-registry"] = component_registry, ["tag-registry"] = tag_registry}
end
package.preload["sheaf.component-registry"] = package.preload["sheaf.component-registry"] or function(...)
  local _local_180_ = require("lib.hierarchy")
  local isa_3f = _local_180_["isa?"]
  local _local_181_ = require("sheaf.trait-registry")
  local trait_defined_3f = _local_181_["trait-defined?"]
  local satisfies_all_3f = _local_181_["satisfies-all?"]
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
  local function valid_instance_name_3f(type_name, instance_name)
    local descriptor = type_name__3edescriptor(type_name)
    if (nil == descriptor) then
      return false
    else
      return (nil ~= string.match(tostring(instance_name), ("^component%." .. descriptor .. "%.instance/.+$")))
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
    return {["component-types"] = {}, instances = {}, hierarchy = opts.hierarchy, ["trait-registry"] = opts["trait-registry"]}
  end
  local function make_component_type(name, description, opts)
    if (nil == opts["start-fn"]) then
      error(("make-component-type: :start-fn is required for " .. tostring(name)))
    else
    end
    return {name = name, description = description, traits = (opts.traits or {}), ["config-schema"] = (opts["config-schema"] or {}), ["start-fn"] = opts["start-fn"], ["stop-fn"] = opts["stop-fn"]}
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
    registry.instances[instance_name] = {name = instance_name, type = type_name, config = (config or {}), state = state}
    return print(("[INFO] Started component instance: " .. tostring(instance_name)))
  end
  local function stop_component_21(registry, instance_name)
    local instance = get_component_instance(registry, instance_name)
    if (nil == instance) then
      error(("stop-component!: instance not found: " .. tostring(instance_name)))
    else
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
  return {["make-instance-name"] = make_instance_name, ["valid-instance-name?"] = valid_instance_name_3f, ["make-component-registry"] = make_component_registry, ["make-component-type"] = make_component_type, ["add-component-type!"] = add_component_type_21, ["component-type-defined?"] = component_type_defined_3f, ["get-component-type"] = get_component_type, ["list-component-types"] = list_component_types, ["component-instance-exists?"] = component_instance_exists_3f, ["get-component-instance"] = get_component_instance, ["list-component-instances"] = list_component_instances, ["start-component!"] = start_component_21, ["stop-component!"] = stop_component_21, ["component-type-isa?"] = component_type_isa_3f}
end
package.preload["sheaf.tag-registry"] = package.preload["sheaf.tag-registry"] or function(...)
  local _local_198_ = require("lib.cljlib-shim")
  local hash_set = _local_198_["hash-set"]
  local conj = _local_198_.conj
  local disj = _local_198_.disj
  local contains_3f = _local_198_["contains?"]
  local empty_3f = _local_198_["empty?"]
  local seq = _local_198_.seq
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
      local _201_
      if seq(new_set) then
        _201_ = new_set
      else
        _201_ = nil
      end
      registry["instance-tags"][instance_name] = _201_
    else
    end
    if tag_insts then
      local new_set = disj(tag_insts, instance_name)
      local _204_
      if seq(new_set) then
        _204_ = new_set
      else
        _204_ = nil
      end
      registry["tag-instances"][tag] = _204_
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
  local _local_210_ = require("sheaf.component-registry")
  local make_component_type = _local_210_["make-component-type"]
  local space_indicator_type
  local function _211_(config)
    local menubar = hs.menubar.new(true, "cosmicHammerSpaceIndicator")
    if menubar then
      menubar:setTitle("...")
    else
    end
    return {menubar = menubar}
  end
  local function _213_(state)
    if state.menubar then
      return state.menubar:delete()
    else
      return nil
    end
  end
  space_indicator_type = make_component_type("component.type/space-indicator", "Space indicator menubar component", {traits = {"trait/has-menubar"}, ["start-fn"] = _211_, ["stop-fn"] = _213_})
  return {["space-indicator-type"] = space_indicator_type}
end
package.preload["components.expose"] = package.preload["components.expose"] or function(...)
  local _local_216_ = require("sheaf.component-registry")
  local make_component_type = _local_216_["make-component-type"]
  local expose_type
  local function _217_(config)
    return {expose = hs.expose.new()}
  end
  expose_type = make_component_type("component.type/expose", "Expose window picker component", {traits = {"trait/has-expose"}, ["start-fn"] = _217_})
  return {["expose-type"] = expose_type}
end
package.preload["components.emacs"] = package.preload["components.emacs"] or function(...)
  local _local_219_ = require("sheaf.component-registry")
  local make_component_type = _local_219_["make-component-type"]
  local emacs_type
  local function _220_(config)
    return {}
  end
  emacs_type = make_component_type("component.type/emacs", "Emacs integration component", {["start-fn"] = _220_})
  return {["emacs-type"] = emacs_type}
end
package.preload["components.reload-hammerspoon"] = package.preload["components.reload-hammerspoon"] or function(...)
  local _local_222_ = require("sheaf.component-registry")
  local make_component_type = _local_222_["make-component-type"]
  local reload_hammerspoon_type
  local function _223_(config)
    return {timer = hs.timer.delayed.new(0.5, hs.reload), ["reloading?"] = false}
  end
  local function _224_(state)
    return state.timer:stop()
  end
  reload_hammerspoon_type = make_component_type("component.type/reload-hammerspoon", "Hammerspoon config reloader with debounce timer", {traits = {"trait/has-delayed-timer"}, ["start-fn"] = _223_, ["stop-fn"] = _224_})
  return {["reload-hammerspoon-type"] = reload_hammerspoon_type}
end
package.preload["components.compile-fennel"] = package.preload["components.compile-fennel"] or function(...)
  local _local_226_ = require("sheaf.component-registry")
  local make_component_type = _local_226_["make-component-type"]
  local compile_fennel_type
  local function _227_(config)
    return {}
  end
  compile_fennel_type = make_component_type("component.type/compile-fennel", "Fennel source file compiler", {["start-fn"] = _227_})
  return {["compile-fennel-type"] = compile_fennel_type}
end
require("components")
package.preload["event_sources"] = package.preload["event_sources"] or function(...)
  local _local_239_ = require("sheaf.source-registry")
  local make_source_registry = _local_239_["make-source-registry"]
  local add_source_type_21 = _local_239_["add-source-type!"]
  local start_event_source_21 = _local_239_["start-event-source!"]
  local _local_240_ = require("events")
  local event_registry = _local_240_["event-registry"]
  local _local_246_ = require("event_sources.file-watcher")
  local file_watcher_source_type = _local_246_["file-watcher-source-type"]
  local _local_251_ = require("event_sources.hotkey")
  local hotkey_source_type = _local_251_["hotkey-source-type"]
  local _local_256_ = require("event_sources.space-watcher")
  local space_watcher_source_type = _local_256_["space-watcher-source-type"]
  local _local_261_ = require("event_sources.screen-watcher")
  local screen_watcher_source_type = _local_261_["screen-watcher-source-type"]
  local _local_262_ = require("components")
  local tag_registry = _local_262_["tag-registry"]
  local _local_263_ = require("sheaf.tag-registry")
  local attach_tag_21 = _local_263_["attach-tag!"]
  local source_registry = make_source_registry({["event-registry"] = event_registry})
  add_source_type_21(source_registry, file_watcher_source_type)
  add_source_type_21(source_registry, hotkey_source_type)
  add_source_type_21(source_registry, space_watcher_source_type)
  add_source_type_21(source_registry, screen_watcher_source_type)
  start_event_source_21(source_registry, "event-source.file-watcher/config-dir", "event-source.type/file-watcher", {path = hs.configdir})
  attach_tag_21(tag_registry, "event-source.file-watcher/config-dir", "tag/config-watcher")
  start_event_source_21(source_registry, "event-source.hotkey/ctrl+cmd+e", "event-source.type/hotkey", {mods = {"ctrl", "cmd"}, key = "e"})
  attach_tag_21(tag_registry, "event-source.hotkey/ctrl+cmd+e", "tag/expose-hotkey")
  start_event_source_21(source_registry, "event-source.hotkey/cmd+alt+return", "event-source.type/hotkey", {mods = {"cmd", "alt"}, key = "return"})
  attach_tag_21(tag_registry, "event-source.hotkey/cmd+alt+return", "tag/emacs-hotkey")
  start_event_source_21(source_registry, "event-source.space-watcher/default", "event-source.type/space-watcher", {})
  attach_tag_21(tag_registry, "event-source.space-watcher/default", "tag/space-watcher")
  start_event_source_21(source_registry, "event-source.screen-watcher/default", "event-source.type/screen-watcher", {})
  attach_tag_21(tag_registry, "event-source.screen-watcher/default", "tag/screen-watcher")
  return {["source-registry"] = source_registry}
end
package.preload["sheaf.source-registry"] = package.preload["sheaf.source-registry"] or function(...)
  local _local_229_ = require("sheaf.event-registry")
  local dispatch_event_21 = _local_229_["dispatch-event!"]
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
    local function _236_(event_name, event_data)
      return dispatch_event_21(registry["event-registry"], event_name, instance_name, event_data)
    end
    emit = _236_
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
  local _local_241_ = require("lib.cljlib-shim")
  local mapv = _local_241_.mapv
  local assoc = _local_241_.assoc
  local string_3f = _local_241_["string?"]
  local _local_242_ = require("sheaf.source-registry")
  local make_source_type = _local_242_["make-source-type"]
  local function start_file_watcher(self, emit)
    local path = self.config.path
    local handler
    local function _243_(files, attrs)
      local evs
      local function _244_(_241, _242)
        return assoc(_241, "file-path", _242)
      end
      evs = mapv(_244_, attrs, files)
      for _, ev in ipairs(evs) do
        emit("file-watcher.events/file-change", ev)
      end
      return nil
    end
    handler = _243_
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
  local _local_247_ = require("lib.cljlib-shim")
  local string_3f = _local_247_["string?"]
  local _local_248_ = require("sheaf.source-registry")
  local make_source_type = _local_248_["make-source-type"]
  local function start_hotkey(self, emit)
    local mods = self.config.mods
    local key = self.config.key
    local handler
    local function _249_()
      return emit("hotkey.events/pressed", {mods = mods, key = key})
    end
    handler = _249_
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
  local _local_252_ = require("sheaf.source-registry")
  local make_source_type = _local_252_["make-source-type"]
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
    local function _254_(space_number)
      return emit("space-watcher.events/space-changed", {["space-number"] = space_number, ["all-spaces"] = snapshot_spaces(), ["active-spaces"] = hs.spaces.activeSpaces()})
    end
    handler = _254_
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
  local _local_257_ = require("sheaf.source-registry")
  local make_source_type = _local_257_["make-source-type"]
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
    local function _259_()
      return emit("screen-watcher.events/screen-changed", {["all-spaces"] = snapshot_spaces(), ["active-spaces"] = hs.spaces.activeSpaces()})
    end
    handler = _259_
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
  local _local_268_ = require("sheaf.command-registry")
  local make_command_registry = _local_268_["make-command-registry"]
  local add_command_21 = _local_268_["add-command!"]
  local _local_271_ = require("commands.toggle-expose")
  local toggle_expose_command = _local_271_["toggle-expose-command"]
  local _local_278_ = require("commands.space-indicator")
  local update_menubar_command = _local_278_["update-menubar-command"]
  local _local_281_ = require("commands.compile-fennel")
  local compile_command = _local_281_["compile-command"]
  local _local_285_ = require("commands.reload-hammerspoon")
  local reload_hammerspoon_command = _local_285_["reload-hammerspoon-command"]
  local _local_288_ = require("commands.open-in-app")
  local open_in_app_command = _local_288_["open-in-app-command"]
  local _local_293_ = require("commands.show-chooser")
  local show_chooser_command = _local_293_["show-chooser-command"]
  local _local_298_ = require("commands.open-emacs")
  local open_emacs_command = _local_298_["open-emacs-command"]
  local command_registry = make_command_registry()
  add_command_21(command_registry, toggle_expose_command)
  add_command_21(command_registry, update_menubar_command)
  add_command_21(command_registry, compile_command)
  add_command_21(command_registry, reload_hammerspoon_command)
  add_command_21(command_registry, open_in_app_command)
  add_command_21(command_registry, show_chooser_command)
  add_command_21(command_registry, open_emacs_command)
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
  local _local_269_ = require("sheaf.command-registry")
  local make_command = _local_269_["make-command"]
  local expose = hs.expose.new()
  local toggle_expose_command
  local function _270_(params)
    return expose:toggleShow()
  end
  toggle_expose_command = make_command("expose.commands/toggle-show", "Toggle the Hammerspoon Expose window picker", {fn = _270_})
  return {["toggle-expose-command"] = toggle_expose_command}
end
package.preload["commands.space-indicator"] = package.preload["commands.space-indicator"] or function(...)
  local _local_272_ = require("sheaf.command-registry")
  local make_command = _local_272_["make-command"]
  local menubar = hs.menubar.new(true, "cosmicHammerSpaceIndicator")
  if menubar then
    menubar:setTitle("...")
  else
  end
  local update_menubar_command
  local function _274_(params)
    if menubar then
      local _275_
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
        _275_ = tbl_26_
      end
      return menubar:setTitle(table.concat(_275_, "|"))
    else
      return nil
    end
  end
  update_menubar_command = make_command("space-indicator.commands/update-menubar", "Update the space indicator menubar with active space indices", {schema = {["active-spaces"] = __fnl_global__table_3f}, fn = _274_})
  return {["update-menubar-command"] = update_menubar_command}
end
package.preload["commands.compile-fennel"] = package.preload["commands.compile-fennel"] or function(...)
  local _local_279_ = require("sheaf.command-registry")
  local make_command = _local_279_["make-command"]
  local compile_command
  local function _280_(params)
    return print(hs.execute("./compile.sh", true))
  end
  compile_command = make_command("compile-fennel.commands/compile", "Compile Fennel source files", {fn = _280_})
  return {["compile-command"] = compile_command}
end
package.preload["commands.reload-hammerspoon"] = package.preload["commands.reload-hammerspoon"] or function(...)
  local _local_282_ = require("sheaf.command-registry")
  local make_command = _local_282_["make-command"]
  local notify = require("notify")
  local reloading_3f = false
  local reload = hs.timer.delayed.new(0.5, hs.reload)
  local reload_hammerspoon_command
  local function _283_(params)
    if not reloading_3f then
      reloading_3f = true
      notify.warn("Reloading...")
      return reload:start()
    else
      return nil
    end
  end
  reload_hammerspoon_command = make_command("reload-hammerspoon.commands/reload", "Reload Hammerspoon config with debounce", {fn = _283_})
  return {["reload-hammerspoon-command"] = reload_hammerspoon_command}
end
package.preload["commands.open-in-app"] = package.preload["commands.open-in-app"] or function(...)
  local _local_286_ = require("sheaf.command-registry")
  local make_command = _local_286_["make-command"]
  local open_in_app_command
  local function _287_(params)
    return hs.urlevent.openURLWithBundle(params.url, params["bundle-id"])
  end
  open_in_app_command = make_command("url-dispatch.commands/open-in-app", "Open a URL in a specific app by bundle ID", {schema = {url = __fnl_global__string_3f, ["bundle-id"] = __fnl_global__string_3f}, fn = _287_})
  return {["open-in-app-command"] = open_in_app_command}
end
package.preload["commands.show-chooser"] = package.preload["commands.show-chooser"] or function(...)
  local _local_289_ = require("sheaf.command-registry")
  local make_command = _local_289_["make-command"]
  local show_chooser_command
  local function _290_(params)
    local url = params.url
    local chooser
    local function _291_(choice)
      if choice then
        return hs.urlevent.openURLWithBundle(url, choice["bundle-id"])
      else
        return nil
      end
    end
    chooser = hs.chooser.new(_291_)
    chooser:choices(params.choices)
    return chooser:show()
  end
  show_chooser_command = make_command("url-dispatch.commands/show-chooser", "Show an async browser picker dialog for a URL", {schema = {url = __fnl_global__string_3f, choices = __fnl_global__table_3f}, fn = _290_})
  return {["show-chooser-command"] = show_chooser_command}
end
package.preload["commands.open-emacs"] = package.preload["commands.open-emacs"] or function(...)
  local _local_294_ = require("sheaf.command-registry")
  local make_command = _local_294_["make-command"]
  local emacsclient_path = hs.application.find("Emacs"):path():gsub("Emacs.app", "bin/emacsclient")
  local open_emacs_command
  local function _295_(params)
    io.popen(("'" .. emacsclient_path .. "' -n -c &"))
    local function _296_()
      local app = hs.application.find("Emacs")
      if app then
        return app:activate()
      else
        return nil
      end
    end
    return hs.timer.doAfter(0.3, _296_)
  end
  open_emacs_command = make_command("emacs.commands/open-emacs", "Open a new emacsclient frame", {fn = _295_})
  return {["open-emacs-command"] = open_emacs_command}
end
require("commands")
package.preload["behaviors"] = package.preload["behaviors"] or function(...)
  local _local_315_ = require("sheaf.behavior-registry")
  local make_behavior_registry = _local_315_["make-behavior-registry"]
  local add_behavior_21 = _local_315_["add-behavior!"]
  local _local_316_ = require("events")
  local event_registry = _local_316_["event-registry"]
  local _local_317_ = require("commands")
  local command_registry = _local_317_["command-registry"]
  local _local_324_ = require("behaviors.compile-fennel")
  local compile_fennel_behavior = _local_324_["compile-fennel-behavior"]
  local _local_331_ = require("behaviors.reload-hammerspoon")
  local reload_hammerspoon_behavior = _local_331_["reload-hammerspoon-behavior"]
  local _local_334_ = require("behaviors.toggle-expose")
  local toggle_expose_behavior = _local_334_["toggle-expose-behavior"]
  local _local_338_ = require("behaviors.update-space-indicator")
  local update_space_indicator_behavior = _local_338_["update-space-indicator-behavior"]
  local _local_341_ = require("behaviors.open-emacs")
  local open_emacs_behavior = _local_341_["open-emacs-behavior"]
  local behavior_registry = make_behavior_registry({["event-registry"] = event_registry, ["command-registry"] = command_registry})
  add_behavior_21(behavior_registry, compile_fennel_behavior)
  add_behavior_21(behavior_registry, reload_hammerspoon_behavior)
  add_behavior_21(behavior_registry, toggle_expose_behavior)
  add_behavior_21(behavior_registry, update_space_indicator_behavior)
  add_behavior_21(behavior_registry, open_emacs_behavior)
  return {["behavior-registry"] = behavior_registry}
end
package.preload["sheaf.behavior-registry"] = package.preload["sheaf.behavior-registry"] or function(...)
  local _local_299_ = require("lib.cljlib-shim")
  local some = _local_299_.some
  local _local_300_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_300_["valid-event-selector?"]
  local _local_301_ = require("sheaf.command-registry")
  local command_defined_3f = _local_301_["command-defined?"]
  local _local_302_ = require("lib.hierarchy")
  local isa_3f = _local_302_["isa?"]
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
      local function _313_(_241)
        return isa_3f(registry["event-registry"].hierarchy, event_name, _241)
      end
      return some(_313_, behavior["respond-to"])
    end
  end
  return {["make-behavior-registry"] = make_behavior_registry, ["make-behavior"] = make_behavior, ["add-behavior!"] = add_behavior_21, ["behavior-defined?"] = behavior_defined_3f, ["get-behavior"] = get_behavior, ["list-behaviors"] = list_behaviors, ["behavior-responds-to?"] = behavior_responds_to_3f}
end
package.preload["behaviors.compile-fennel"] = package.preload["behaviors.compile-fennel"] or function(...)
  local _local_318_ = require("sheaf.behavior-registry")
  local make_behavior = _local_318_["make-behavior"]
  local compile_fennel_behavior
  local function _319_(file_change_event, cmd)
    local path
    do
      local t_320_ = file_change_event
      if (nil ~= t_320_) then
        t_320_ = t_320_["event-data"]
      else
      end
      if (nil ~= t_320_) then
        t_320_ = t_320_["file-path"]
      else
      end
      path = t_320_
    end
    if ((nil ~= path) and (".fnl" == path:sub(-4))) then
      return cmd.compile({})
    else
      return nil
    end
  end
  compile_fennel_behavior = make_behavior({name = "compile-fennel.behaviors/compile-fennel", description = "Watch fennel files in hammerspoon folder and recompile them.", ["respond-to"] = {"event.kind.fs/file-change"}, commands = {compile = "compile-fennel.commands/compile"}, fn = _319_})
  return {["compile-fennel-behavior"] = compile_fennel_behavior}
end
package.preload["behaviors.reload-hammerspoon"] = package.preload["behaviors.reload-hammerspoon"] or function(...)
  local _local_325_ = require("sheaf.behavior-registry")
  local make_behavior = _local_325_["make-behavior"]
  local reload_hammerspoon_behavior
  local function _326_(file_change_event, cmd)
    local path
    do
      local t_327_ = file_change_event
      if (nil ~= t_327_) then
        t_327_ = t_327_["event-data"]
      else
      end
      if (nil ~= t_327_) then
        t_327_ = t_327_["file-path"]
      else
      end
      path = t_327_
    end
    if ((nil ~= path) and (".hammerspoon/init.lua" == path:sub(-21))) then
      return cmd.reload({})
    else
      return nil
    end
  end
  reload_hammerspoon_behavior = make_behavior({name = "reload-hammerspoon.behaviors/reload-hammerspoon", description = "When init.lua changes, reload hammerspoon.", ["respond-to"] = {"event.kind.fs/file-change"}, commands = {reload = "reload-hammerspoon.commands/reload"}, fn = _326_})
  return {["reload-hammerspoon-behavior"] = reload_hammerspoon_behavior}
end
package.preload["behaviors.toggle-expose"] = package.preload["behaviors.toggle-expose"] or function(...)
  local _local_332_ = require("sheaf.behavior-registry")
  local make_behavior = _local_332_["make-behavior"]
  local toggle_expose_behavior
  local function _333_(event, cmd)
    return cmd["toggle-show"]({})
  end
  toggle_expose_behavior = make_behavior({name = "expose.behaviors/toggle-expose", description = "Toggle the Hammerspoon Expose window picker", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["toggle-show"] = "expose.commands/toggle-show"}, fn = _333_})
  return {["toggle-expose-behavior"] = toggle_expose_behavior}
end
package.preload["behaviors.update-space-indicator"] = package.preload["behaviors.update-space-indicator"] or function(...)
  local _local_335_ = require("sheaf.behavior-registry")
  local make_behavior = _local_335_["make-behavior"]
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
  local function _337_(event, cmd)
    local indices = compute_active_space_indices(event["event-data"]["all-spaces"], event["event-data"]["active-spaces"])
    return cmd["update-menubar"]({["active-spaces"] = indices})
  end
  update_space_indicator_behavior = make_behavior({name = "space-indicator.behaviors/update-on-change", description = "Update space indicator menubar when spaces or screens change", ["respond-to"] = {"event.kind.space/changed", "event.kind.screen/any"}, commands = {["update-menubar"] = "space-indicator.commands/update-menubar"}, fn = _337_})
  return {["update-space-indicator-behavior"] = update_space_indicator_behavior}
end
package.preload["behaviors.open-emacs"] = package.preload["behaviors.open-emacs"] or function(...)
  local _local_339_ = require("sheaf.behavior-registry")
  local make_behavior = _local_339_["make-behavior"]
  local open_emacs_behavior
  local function _340_(event, cmd)
    return cmd["open-emacs"]({})
  end
  open_emacs_behavior = make_behavior({name = "emacs.behaviors/open-emacs", description = "Open a new emacsclient frame on hotkey press", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["open-emacs"] = "emacs.commands/open-emacs"}, fn = _340_})
  return {["open-emacs-behavior"] = open_emacs_behavior}
end
require("behaviors")
package.preload["subscriptions"] = package.preload["subscriptions"] or function(...)
  local _local_361_ = require("sheaf.subscription-registry")
  local make_subscription_registry = _local_361_["make-subscription-registry"]
  local define_subscription_21 = _local_361_["define-subscription!"]
  local _local_362_ = require("events")
  local event_registry = _local_362_["event-registry"]
  local _local_363_ = require("behaviors")
  local behavior_registry = _local_363_["behavior-registry"]
  local _local_364_ = require("components")
  local tag_registry = _local_364_["tag-registry"]
  local subscription_registry = make_subscription_registry({["event-registry"] = event_registry, ["behavior-registry"] = behavior_registry, ["tag-registry"] = tag_registry})
  define_subscription_21(subscription_registry, "sub/reload-on-config-change", {description = "Reload Hammerspoon when init.lua changes", behavior = "reload-hammerspoon.behaviors/reload-hammerspoon", ["source-tag"] = "tag/config-watcher", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/compile-on-fnl-change", {description = "Recompile Fennel when .fnl files change", behavior = "compile-fennel.behaviors/compile-fennel", ["source-tag"] = "tag/config-watcher", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/toggle-expose-on-hotkey", {description = "Toggle Expose when ctrl+cmd+e is pressed", behavior = "expose.behaviors/toggle-expose", ["source-tag"] = "tag/expose-hotkey", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-space-change", {description = "Update space indicator when space changes", behavior = "space-indicator.behaviors/update-on-change", ["source-tag"] = "tag/space-watcher", ["event-selector"] = "event.kind.space/changed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-screen-change", {description = "Update space indicator when screen layout changes", behavior = "space-indicator.behaviors/update-on-change", ["source-tag"] = "tag/screen-watcher", ["event-selector"] = "event.kind.screen/layout-changed"})
  define_subscription_21(subscription_registry, "sub/open-emacs-on-hotkey", {description = "Open emacsclient frame when cmd+alt+return is pressed", behavior = "emacs.behaviors/open-emacs", ["source-tag"] = "tag/emacs-hotkey", ["event-selector"] = "event.kind.hotkey/pressed"})
  return {["subscription-registry"] = subscription_registry}
end
package.preload["sheaf.subscription-registry"] = package.preload["sheaf.subscription-registry"] or function(...)
  local _local_342_ = require("lib.cljlib-shim")
  local hash_set = _local_342_["hash-set"]
  local conj = _local_342_.conj
  local disj = _local_342_.disj
  local into = _local_342_.into
  local seq = _local_342_.seq
  local filter = _local_342_.filter
  local _local_343_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_343_["valid-event-selector?"]
  local _local_344_ = require("sheaf.behavior-registry")
  local behavior_defined_3f = _local_344_["behavior-defined?"]
  local _local_345_ = require("sheaf.tag-registry")
  local get_tags = _local_345_["get-tags"]
  local _local_346_ = require("lib.hierarchy")
  local ancestors = _local_346_.ancestors
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
    local behavior = subscription.behavior
    if (nil == registry.index[tag]) then
      registry.index[tag] = {}
    else
    end
    if (nil == registry.index[tag][event]) then
      registry.index[tag][event] = hash_set()
    else
    end
    registry.index[tag][event] = conj(registry.index[tag][event], behavior)
    return nil
  end
  local function index_remove_21(registry, subscription)
    local tag = subscription["source-tag"]
    local event = subscription["event-selector"]
    local behavior = subscription.behavior
    local behavior_set
    do
      local t_352_ = registry.index
      if (nil ~= t_352_) then
        t_352_ = t_352_[tag]
      else
      end
      if (nil ~= t_352_) then
        t_352_ = t_352_[event]
      else
      end
      behavior_set = t_352_
    end
    if behavior_set then
      registry.index[tag][event] = disj(behavior_set, behavior)
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
    validate_required_field_21(name, opts, "source-tag")
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
    local subscription = {name = name, description = opts.description, behavior = opts.behavior, ["event-selector"] = opts["event-selector"], ["source-tag"] = opts["source-tag"], ["target-tag"] = opts["target-tag"]}
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
  local function get_subscribed_behaviors(registry, source_instance_name, event_name)
    local tags = get_tags(registry["tag-registry"], source_instance_name)
    local event_selectors = conj(ancestors(registry["event-registry"].hierarchy, event_name), event_name)
    local all_behavior_names
    do
      local result = hash_set()
      for tag, _ in pairs(tags) do
        local tag_subs = (registry.index[tag] or {})
        local inner = result
        for _0, e in pairs(event_selectors) do
          inner = into(inner, (tag_subs[e] or {}))
        end
        result = inner
      end
      all_behavior_names = result
    end
    return seq(all_behavior_names)
  end
  return {["make-subscription-registry"] = make_subscription_registry, ["define-subscription!"] = define_subscription_21, ["remove-subscription!"] = remove_subscription_21, ["get-subscription"] = get_subscription, ["list-subscriptions"] = list_subscriptions, ["subscription-defined?"] = subscription_defined_3f, ["get-subscribed-behaviors"] = get_subscribed_behaviors}
end
local _local_365_ = require("subscriptions")
local subscription_registry = _local_365_["subscription-registry"]
package.preload["sheaf.dispatcher"] = package.preload["sheaf.dispatcher"] or function(...)
  local _local_366_ = require("lib.cljlib-shim")
  local mapv = _local_366_.mapv
  local filter = _local_366_.filter
  local seq = _local_366_.seq
  local _local_367_ = require("sheaf.event-registry")
  local add_event_handler_21 = _local_367_["add-event-handler!"]
  local _local_368_ = require("sheaf.behavior-registry")
  local behavior_responds_to_3f = _local_368_["behavior-responds-to?"]
  local get_behavior = _local_368_["get-behavior"]
  local _local_369_ = require("sheaf.subscription-registry")
  local get_subscribed_behaviors = _local_369_["get-subscribed-behaviors"]
  local _local_370_ = require("sheaf.tag-registry")
  local get_tags = _local_370_["get-tags"]
  local _local_371_ = require("sheaf.command-registry")
  local invoke_command_21 = _local_371_["invoke-command!"]
  local function build_cmd_table(command_registry, behavior)
    local cmd = {}
    for alias, cmd_name in pairs((behavior.commands or {})) do
      local function _372_(params)
        return invoke_command_21(command_registry, cmd_name, params)
      end
      cmd[alias] = _372_
    end
    return cmd
  end
  local function get_behaviors_for_event(subscription_registry, event)
    local behavior_registry = subscription_registry["behavior-registry"]
    do
      local source_tags = get_tags(subscription_registry["tag-registry"], event["event-source"])
      if (nil == next(source_tags)) then
        print(("[WARN] get-behaviors-for-event: source instance '" .. tostring(event["event-source"]) .. "' has no tags"))
      else
      end
    end
    local behavior_names = (get_subscribed_behaviors(subscription_registry, event["event-source"], event["event-name"]) or {})
    local valid_names
    local function _374_(name)
      local responds_3f = behavior_responds_to_3f(behavior_registry, name, event["event-name"])
      if not responds_3f then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' does not respond to event '" .. tostring(event["event-name"]) .. "'"))
      else
      end
      return responds_3f
    end
    valid_names = filter(_374_, behavior_names)
    local function _376_(name)
      local behavior = get_behavior(behavior_registry, name)
      if (nil == behavior) then
        print(("[ERROR] get-behaviors-for-event: behavior '" .. tostring(name) .. "' not found in registry"))
      else
      end
      return behavior
    end
    return mapv(_376_, (seq(valid_names) or {}))
  end
  local function start_dispatcher_21(subscription_registry)
    local event_registry = subscription_registry["event-registry"]
    local command_registry = subscription_registry["behavior-registry"]["command-registry"]
    local cmd_cache = {}
    local get_cmd_table
    local function _378_(behavior)
      local cached = cmd_cache[behavior.name]
      if cached then
        return cached
      else
        local cmd = build_cmd_table(command_registry, behavior)
        cmd_cache[behavior.name] = cmd
        return cmd
      end
    end
    get_cmd_table = _378_
    local function _380_(event)
      local bs = get_behaviors_for_event(subscription_registry, event)
      for _, behavior in pairs(bs) do
        if behavior then
          behavior.fn(event, get_cmd_table(behavior))
        else
        end
      end
      return nil
    end
    add_event_handler_21(event_registry, "dispatcher/behavior-router", _380_)
    local function _382_(event)
      if _G["event-bus.debug-mode?"] then
        return print("got event", hs.inspect(event))
      else
        return nil
      end
    end
    return add_event_handler_21(event_registry, "dispatcher/debug-handler", _382_)
  end
  return {["start-dispatcher!"] = start_dispatcher_21}
end
local _local_384_ = require("sheaf.dispatcher")
local start_dispatcher_21 = _local_384_["start-dispatcher!"]
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
    local function _388_()
      while process_event_21(event_loop) do
      end
      return nil
    end
    timer = hs.timer.new(0.01, _388_)
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
local _local_390_ = require("sheaf.event-loop")
local make_event_loop = _local_390_["make-event-loop"]
local start_event_loop_21 = _local_390_["start-event-loop!"]
start_dispatcher_21(subscription_registry)
local event_loop = make_event_loop(event_registry)
start_event_loop_21(event_loop)
notify.warn("Reload Succeeded")
return {}
