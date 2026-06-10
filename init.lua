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
  local _local_164_ = require("sheaf.event-registry")
  local make_event_registry = _local_164_["make-event-registry"]
  local define_event_21 = _local_164_["define-event!"]
  local _local_165_ = require("lib.hierarchy")
  local make_hierarchy = _local_165_["make-hierarchy"]
  local derive_21 = _local_165_["derive!"]
  local number_3f
  local function _166_(x)
    return (type(x) == "number")
  end
  number_3f = _166_
  local table_3f
  local function _167_(x)
    return (type(x) == "table")
  end
  table_3f = _167_
  local nil_or_string_3f
  local function _168_(x)
    return ((x == nil) or string_3f(x))
  end
  nil_or_string_3f = _168_
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
  derive_21(event_hierarchy, "event.kind.url/any", "event.kind/any")
  derive_21(event_hierarchy, "event.kind.url/opened", "event.kind.url/any")
  local event_registry = make_event_registry({hierarchy = event_hierarchy})
  define_event_21(event_registry, "file-watcher.events/file-change", "File change detected in watched directory", {["file-path"] = string_3f})
  derive_21(event_hierarchy, "file-watcher.events/file-change", "event.kind.fs/file-change")
  define_event_21(event_registry, "hotkey.events/pressed", "Hotkey was pressed", {mods = table_3f, key = string_3f})
  derive_21(event_hierarchy, "hotkey.events/pressed", "event.kind.hotkey/pressed")
  define_event_21(event_registry, "space-watcher.events/space-changed", "Active space/desktop changed", {["space-number"] = number_3f, ["all-spaces"] = table_3f, ["active-spaces"] = table_3f})
  derive_21(event_hierarchy, "space-watcher.events/space-changed", "event.kind.space/changed")
  define_event_21(event_registry, "screen-watcher.events/screen-changed", "Screen layout changed", {["all-spaces"] = table_3f, ["active-spaces"] = table_3f})
  derive_21(event_hierarchy, "screen-watcher.events/screen-changed", "event.kind.screen/layout-changed")
  define_event_21(event_registry, "window-watcher.events/focused", "Window gained focus", {["window-id"] = number_3f, ["app-name"] = string_3f, ["window-title"] = string_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-watcher.events/focused", "event.kind.window/focused")
  define_event_21(event_registry, "window-watcher.events/visible", "Window became visible", {["window-id"] = number_3f, ["app-name"] = string_3f, ["window-title"] = string_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-watcher.events/visible", "event.kind.window/visible")
  define_event_21(event_registry, "window-watcher.events/not-visible", "Window is no longer visible", {["window-id"] = number_3f, ["app-name"] = string_3f, ["window-title"] = string_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-watcher.events/not-visible", "event.kind.window/not-visible")
  define_event_21(event_registry, "window-watcher.events/fullscreened", "Window entered fullscreen", {["window-id"] = number_3f, ["app-name"] = string_3f, ["window-title"] = string_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-watcher.events/fullscreened", "event.kind.window/fullscreened")
  define_event_21(event_registry, "window-watcher.events/unfullscreened", "Window exited fullscreen", {["window-id"] = number_3f, ["app-name"] = string_3f, ["window-title"] = string_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-watcher.events/unfullscreened", "event.kind.window/unfullscreened")
  define_event_21(event_registry, "window-watcher.events/moved", "Window was moved or resized", {["window-id"] = number_3f, ["app-name"] = string_3f, ["window-title"] = string_3f, frame = table_3f})
  derive_21(event_hierarchy, "window-watcher.events/moved", "event.kind.window/moved")
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
  define_event_21(event_registry, "url-handler.events/url-opened", "URL opened via default browser handler", {url = string_3f, original = string_3f, scheme = string_3f, host = string_3f, path = nil_or_string_3f, params = table_3f, sender = nil_or_string_3f, ["sender-bundle-id"] = nil_or_string_3f})
  derive_21(event_hierarchy, "url-handler.events/url-opened", "event.kind.url/opened")
  return {["event-registry"] = event_registry}
end
package.preload["sheaf.event-registry"] = package.preload["sheaf.event-registry"] or function(...)
  local _local_157_ = require("lib.hierarchy")
  local isa_3f = _local_157_["isa?"]
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
    local or_160_ = event_defined_3f(registry, selector)
    if not or_160_ then
      local found = false
      for event_name, _ in pairs(registry.events) do
        if found then break end
        if isa_3f(registry.hierarchy, event_name, selector) then
          found = true
        else
        end
      end
      or_160_ = found
    end
    return or_160_
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
  local _local_134_ = require("lib.cljlib-shim")
  local hash_set = _local_134_["hash-set"]
  local conj = _local_134_.conj
  local disj = _local_134_.disj
  local contains_3f = _local_134_["contains?"]
  local into = _local_134_.into
  local mapcat = _local_134_.mapcat
  local empty_3f = _local_134_["empty?"]
  local seq = _local_134_.seq
  local function ensure_entry(h, tag)
    if (nil == h[tag]) then
      h[tag] = {parents = hash_set(), children = hash_set()}
      return nil
    else
      return nil
    end
  end
  local function parents(h, tag)
    local _137_
    do
      local t_136_ = h
      if (nil ~= t_136_) then
        t_136_ = t_136_[tag]
      else
      end
      if (nil ~= t_136_) then
        t_136_ = t_136_.parents
      else
      end
      _137_ = t_136_
    end
    return (_137_ or hash_set())
  end
  local function children(h, tag)
    local _141_
    do
      local t_140_ = h
      if (nil ~= t_140_) then
        t_140_ = t_140_[tag]
      else
      end
      if (nil ~= t_140_) then
        t_140_ = t_140_.children
      else
      end
      _141_ = t_140_
    end
    return (_141_ or hash_set())
  end
  local function ancestors(h, tag)
    local ps = parents(h, tag)
    if empty_3f(ps) then
      return ps
    else
      local function _144_(_241)
        return ancestors(h, _241)
      end
      return into(ps, mapcat(_144_, seq(ps)))
    end
  end
  local function descendants(h, tag)
    local cs = children(h, tag)
    if empty_3f(cs) then
      return cs
    else
      local function _146_(_241)
        return descendants(h, _241)
      end
      return into(cs, mapcat(_146_, seq(cs)))
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
local _local_169_ = require("events")
local event_registry = _local_169_["event-registry"]
package.preload["traits"] = package.preload["traits"] or function(...)
  local _local_170_ = require("lib.hierarchy")
  local make_hierarchy = _local_170_["make-hierarchy"]
  local derive_21 = _local_170_["derive!"]
  local _local_189_ = require("sheaf.trait-registry")
  local make_trait_registry = _local_189_["make-trait-registry"]
  local make_trait = _local_189_["make-trait"]
  local add_trait_21 = _local_189_["add-trait!"]
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
  derive_21(trait_hierarchy, "trait/has-delayed-timer", "trait.kind/scheduling")
  derive_21(trait_hierarchy, "trait.kind/data", "trait.kind/any")
  derive_21(trait_hierarchy, "trait/has-url-routing-rules", "trait.kind/data")
  local trait_registry = make_trait_registry({hierarchy = trait_hierarchy})
  add_trait_21(trait_registry, make_trait("trait/has-menubar", "Component state includes an hs.menubar object", {menubar = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-expose", "Component state includes an hs.expose object", {expose = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-chooser", "Component state includes an hs.chooser object", {chooser = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-canvas", "Component state includes hs.canvas objects", {["active-canvas"] = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-window-filter", "Component state includes an hs.window.filter", {["window-filter"] = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-layout", "Component state includes window layout tables", {["window-list"] = non_nil_3f, ["index-table"] = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-delayed-timer", "Component state includes an hs.timer.delayed", {timer = non_nil_3f}))
  add_trait_21(trait_registry, make_trait("trait/has-url-routing-rules", "Component state includes URL routing configuration: browsers, fallback, and rules", {browsers = non_nil_3f, fallback = non_nil_3f, rules = non_nil_3f}))
  return {["trait-registry"] = trait_registry}
end
package.preload["sheaf.trait-registry"] = package.preload["sheaf.trait-registry"] or function(...)
  local _local_171_ = require("lib.hierarchy")
  local isa_3f = _local_171_["isa?"]
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
    local _174_
    do
      local t_173_ = attrs
      if (nil ~= t_173_) then
        t_173_ = t_173_.attrs
      else
      end
      _174_ = t_173_
    end
    local or_176_ = _174_
    if not or_176_ then
      local t_177_ = attrs
      if (nil ~= t_177_) then
        t_177_ = t_177_.schema
      else
      end
      or_176_ = t_177_
    end
    return (or_176_ or attrs)
  end
  local function normalize_pred(attrs, pred)
    local or_179_ = pred
    if not or_179_ then
      local t_180_ = attrs
      if (nil ~= t_180_) then
        t_180_ = t_180_.pred
      else
      end
      or_179_ = t_180_
    end
    return or_179_
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
local _local_190_ = require("traits")
local trait_registry = _local_190_["trait-registry"]
package.preload["shapes"] = package.preload["shapes"] or function(...)
  local _local_207_ = require("sheaf.shape-registry")
  local make_shape_registry = _local_207_["make-shape-registry"]
  local make_shape = _local_207_["make-shape"]
  local add_shape_21 = _local_207_["add-shape!"]
  local _local_208_ = require("traits")
  local trait_registry = _local_208_["trait-registry"]
  local shape_registry = make_shape_registry({["trait-registry"] = trait_registry})
  add_shape_21(shape_registry, make_shape("shape/url-routing-rules", "URL routing configuration: browsers, fallback action, and ordered rules", {{name = "default", traits = {"trait/has-url-routing-rules"}}}))
  return {["shape-registry"] = shape_registry}
end
package.preload["sheaf.shape-registry"] = package.preload["sheaf.shape-registry"] or function(...)
  local _local_191_ = require("sheaf.trait-registry")
  local satisfies_all_3f = _local_191_["satisfies-all?"]
  local trait_defined_3f = _local_191_["trait-defined?"]
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
local _local_209_ = require("shapes")
local shape_registry = _local_209_["shape-registry"]
package.preload["event_sources"] = package.preload["event_sources"] or function(...)
  local _local_220_ = require("sheaf.source-registry")
  local make_source_registry = _local_220_["make-source-registry"]
  local add_source_type_21 = _local_220_["add-source-type!"]
  local _local_221_ = require("events")
  local event_registry = _local_221_["event-registry"]
  local _local_227_ = require("event_sources.file-watcher")
  local file_watcher_source_type = _local_227_["file-watcher-source-type"]
  local _local_232_ = require("event_sources.hotkey")
  local hotkey_source_type = _local_232_["hotkey-source-type"]
  local _local_237_ = require("event_sources.space-watcher")
  local space_watcher_source_type = _local_237_["space-watcher-source-type"]
  local _local_242_ = require("event_sources.screen-watcher")
  local screen_watcher_source_type = _local_242_["screen-watcher-source-type"]
  local _local_248_ = require("event_sources.window-watcher")
  local window_watcher_source_type = _local_248_["window-watcher-source-type"]
  local _local_257_ = require("event_sources.window-element-watcher")
  local window_element_watcher_source_type = _local_257_["window-element-watcher-source-type"]
  local _local_266_ = require("event_sources.app-watcher")
  local app_watcher_source_type = _local_266_["app-watcher-source-type"]
  local _local_301_ = require("event_sources.url-handler")
  local url_handler_source_type = _local_301_["url-handler-source-type"]
  local source_registry = make_source_registry({["event-registry"] = event_registry})
  add_source_type_21(source_registry, file_watcher_source_type)
  add_source_type_21(source_registry, hotkey_source_type)
  add_source_type_21(source_registry, space_watcher_source_type)
  add_source_type_21(source_registry, screen_watcher_source_type)
  add_source_type_21(source_registry, window_watcher_source_type)
  add_source_type_21(source_registry, window_element_watcher_source_type)
  add_source_type_21(source_registry, app_watcher_source_type)
  add_source_type_21(source_registry, url_handler_source_type)
  return {["source-registry"] = source_registry}
end
package.preload["sheaf.source-registry"] = package.preload["sheaf.source-registry"] or function(...)
  local _local_210_ = require("sheaf.event-registry")
  local dispatch_event_21 = _local_210_["dispatch-event!"]
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
    local function _217_(event_name, event_data)
      return dispatch_event_21(registry["event-registry"], event_name, instance_name, event_data)
    end
    emit = _217_
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
  local _local_222_ = require("lib.cljlib-shim")
  local mapv = _local_222_.mapv
  local assoc = _local_222_.assoc
  local string_3f = _local_222_["string?"]
  local _local_223_ = require("sheaf.source-registry")
  local make_source_type = _local_223_["make-source-type"]
  local function start_file_watcher(self, emit)
    local path = self.config.path
    local handler
    local function _224_(files, attrs)
      local evs
      local function _225_(_241, _242)
        return assoc(_241, "file-path", _242)
      end
      evs = mapv(_225_, attrs, files)
      for _, ev in ipairs(evs) do
        emit("file-watcher.events/file-change", ev)
      end
      return nil
    end
    handler = _224_
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
  local _local_228_ = require("lib.cljlib-shim")
  local string_3f = _local_228_["string?"]
  local _local_229_ = require("sheaf.source-registry")
  local make_source_type = _local_229_["make-source-type"]
  local function start_hotkey(self, emit)
    local mods = self.config.mods
    local key = self.config.key
    local handler
    local function _230_()
      return emit("hotkey.events/pressed", {mods = mods, key = key})
    end
    handler = _230_
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
  local _local_233_ = require("sheaf.source-registry")
  local make_source_type = _local_233_["make-source-type"]
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
    local function _235_(space_number)
      return emit("space-watcher.events/space-changed", {["space-number"] = space_number, ["all-spaces"] = snapshot_spaces(), ["active-spaces"] = hs.spaces.activeSpaces()})
    end
    handler = _235_
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
  local _local_238_ = require("sheaf.source-registry")
  local make_source_type = _local_238_["make-source-type"]
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
    local function _240_()
      return emit("screen-watcher.events/screen-changed", {["all-spaces"] = snapshot_spaces(), ["active-spaces"] = hs.spaces.activeSpaces()})
    end
    handler = _240_
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
package.preload["event_sources.window-watcher"] = package.preload["event_sources.window-watcher"] or function(...)
  local _local_243_ = require("sheaf.source-registry")
  local make_source_type = _local_243_["make-source-type"]
  local WindowFilter = hs.window.filter
  local function make_event_data(window, appName)
    return {["window-id"] = window:id(), ["app-name"] = appName, ["window-title"] = window:title(), frame = window:frame()}
  end
  local function start_window_watcher(self, emit)
    local wf = WindowFilter.new():setOverrideFilter({allowRoles = {"AXUnknown", "AXStandardWindow", "AXDialog", "AXSystemDialog"}})
    local handler
    local function _244_(window, appName, event)
      if window then
        local data = make_event_data(window, appName)
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
        else
          return nil
        end
      else
        return nil
      end
    end
    handler = _244_
    wf:subscribe({WindowFilter.windowFocused, WindowFilter.windowVisible, WindowFilter.windowNotVisible, WindowFilter.windowFullscreened, WindowFilter.windowUnfullscreened, WindowFilter.windowMoved}, handler)
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
  local window_watcher_source_type = make_source_type("event-source.type/window-watcher", "Emits events on window focus, visibility, and fullscreen changes", {["config-schema"] = {}, emits = {"window-watcher.events/focused", "window-watcher.events/visible", "window-watcher.events/not-visible", "window-watcher.events/fullscreened", "window-watcher.events/unfullscreened", "window-watcher.events/moved"}, ["start-fn"] = start_window_watcher, ["stop-fn"] = stop_window_watcher})
  return {["window-watcher-source-type"] = window_watcher_source_type}
end
package.preload["event_sources.window-element-watcher"] = package.preload["event_sources.window-element-watcher"] or function(...)
  local _local_249_ = require("sheaf.source-registry")
  local make_source_type = _local_249_["make-source-type"]
  local Watcher = hs.uielement.watcher
  local number_3f
  local function _250_(x)
    return (type(x) == "number")
  end
  number_3f = _250_
  local function start_window_element_watcher(self, emit)
    local window_id = self.config["window-id"]
    local window = hs.window.get(window_id)
    if not window then
      print(("window-element-watcher: window not found for id " .. tostring(window_id)))
      return nil
    else
      local callback
      local function _251_(element, event_name, _watcher_obj, _user_data)
        local ok, frame
        local function _252_()
          return element:frame()
        end
        ok, frame = pcall(_252_)
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
      callback = _251_
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
package.preload["event_sources.app-watcher"] = package.preload["event_sources.app-watcher"] or function(...)
  local _local_258_ = require("sheaf.source-registry")
  local make_source_type = _local_258_["make-source-type"]
  local AppWatcher = hs.application.watcher
  local function make_event_data(appName, appObject)
    local _259_
    if appObject then
      _259_ = appObject:bundleID()
    else
      _259_ = ""
    end
    local _261_
    if appObject then
      _261_ = appObject:pid()
    else
      _261_ = 0
    end
    return {["app-name"] = (appName or ""), ["bundle-id"] = _259_, pid = _261_}
  end
  local function start_app_watcher(self, emit)
    local handler
    local function _263_(appName, eventType, appObject)
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
    handler = _263_
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
  local _local_267_ = require("sheaf.source-registry")
  local make_source_type = _local_267_["make-source-type"]
  local _local_284_ = require("event_sources.url-decoders")
  local run_decoders = _local_284_["run-decoders"]
  local default_decoders = _local_284_["default-decoders"]
  local parse_url_parts = _local_284_["parse-url-parts"]
  local table_3f
  local function _285_(x)
    return (type(x) == "table")
  end
  table_3f = _285_
  local number_3f
  local function _286_(x)
    return (type(x) == "number")
  end
  number_3f = _286_
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
    local prev_http = hs.urlevent.getDefaultHandler("http")
    local prev_https = hs.urlevent.getDefaultHandler("https")
    local callback
    local function _291_(scheme, host, params, full_url, sender_pid)
      print(("[DEBUG] url-handler: received URL=" .. tostring(full_url) .. " scheme=" .. tostring(scheme) .. " host=" .. tostring(host) .. " senderPID=" .. tostring(sender_pid)))
      local original = full_url
      local decoded = run_decoders(decoders, max_depth, full_url)
      local parts = parse_url_parts(decoded)
      local decoded_params = extract_params(parts, params)
      local sender_name, sender_bid = resolve_sender(sender_pid)
      print(("[DEBUG] url-handler: emitting event, decoded=" .. tostring(decoded) .. " sender=" .. tostring(sender_name) .. " bid=" .. tostring(sender_bid)))
      local _292_
      if parts then
        _292_ = parts.scheme
      else
        _292_ = (scheme or "")
      end
      local _294_
      if parts then
        _294_ = parts.host
      else
        _294_ = (host or "")
      end
      local _296_
      if parts then
        _296_ = parts.path
      else
        _296_ = nil
      end
      return emit("url-handler.events/url-opened", {url = decoded, original = original, scheme = _292_, host = _294_, path = _296_, params = decoded_params, sender = sender_name, ["sender-bundle-id"] = sender_bid})
    end
    callback = _291_
    hs.urlevent.setDefaultHandler("http")
    hs.urlevent.httpCallback = callback
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
  local _local_268_ = require("lib.cljlib-shim")
  local string_3f = _local_268_["string?"]
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
  local function _278_(ctx)
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
  slack_redir_decoder = {name = "slack-redir", match = {host = "*.slack-redir.net"}, ["decode-fn"] = _278_}
  local outlook_safelinks_decoder
  local function _281_(ctx)
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
  outlook_safelinks_decoder = {name = "outlook-safelinks", match = {host = "safelinks.protection.outlook.com"}, ["decode-fn"] = _281_}
  local default_decoders = {slack_redir_decoder, outlook_safelinks_decoder}
  return {["run-decoders"] = run_decoders, ["default-decoders"] = default_decoders, ["wildcard-match?"] = wildcard_match_3f, ["decoder-matches?"] = decoder_matches_3f, ["parse-url-parts"] = parse_url_parts}
end
require("event_sources")
package.preload["components"] = package.preload["components"] or function(...)
  local _local_302_ = require("lib.hierarchy")
  local make_hierarchy = _local_302_["make-hierarchy"]
  local derive_21 = _local_302_["derive!"]
  local _local_341_ = require("sheaf.component-registry")
  local make_component_registry = _local_341_["make-component-registry"]
  local add_component_type_21 = _local_341_["add-component-type!"]
  local start_component_21 = _local_341_["start-component!"]
  local make_instance_name = _local_341_["make-instance-name"]
  local _local_342_ = require("sheaf.tag-registry")
  local make_tag_registry = _local_342_["make-tag-registry"]
  local attach_tag_21 = _local_342_["attach-tag!"]
  local _local_343_ = require("traits")
  local trait_registry = _local_343_["trait-registry"]
  local _local_344_ = require("event_sources")
  local source_registry = _local_344_["source-registry"]
  local _local_350_ = require("components.space-indicator")
  local space_indicator_type = _local_350_["space-indicator-type"]
  local _local_353_ = require("components.expose")
  local expose_type = _local_353_["expose-type"]
  local _local_356_ = require("components.emacs")
  local emacs_type = _local_356_["emacs-type"]
  local _local_360_ = require("components.reload-hammerspoon")
  local reload_hammerspoon_type = _local_360_["reload-hammerspoon-type"]
  local _local_363_ = require("components.compile-fennel")
  local compile_fennel_type = _local_363_["compile-fennel-type"]
  local _local_366_ = require("components.config-watcher")
  local config_watcher_type = _local_366_["config-watcher-type"]
  local _local_369_ = require("components.window-watcher")
  local window_watcher_type = _local_369_["window-watcher-type"]
  local _local_372_ = require("components.app-watcher")
  local app_watcher_type = _local_372_["app-watcher-type"]
  local _local_378_ = require("components.window-border")
  local window_border_type = _local_378_["window-border-type"]
  local _local_382_ = require("components.url-dispatch")
  local url_dispatch_type = _local_382_["url-dispatch-type"]
  local _local_385_ = require("components.url-routing-rules")
  local url_routing_rules_type = _local_385_["url-routing-rules-type"]
  local component_hierarchy = make_hierarchy()
  derive_21(component_hierarchy, "component.kind/space-indicator", "component.kind/any")
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
  derive_21(component_hierarchy, "component.type/space-indicator", "component.kind/space-indicator")
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
  local tag_registry = make_tag_registry()
  local component_registry = make_component_registry({hierarchy = component_hierarchy, ["trait-registry"] = trait_registry, ["source-registry"] = source_registry, ["tag-registry"] = tag_registry})
  add_component_type_21(component_registry, space_indicator_type)
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
  local space_indicator_name = make_instance_name("component.type/space-indicator", "main")
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
  attach_tag_21(tag_registry, space_indicator_name, "tag/space-indicator")
  attach_tag_21(tag_registry, expose_name, "tag/expose")
  attach_tag_21(tag_registry, emacs_name, "tag/emacs")
  attach_tag_21(tag_registry, reload_hammerspoon_name, "tag/reload-hammerspoon")
  attach_tag_21(tag_registry, compile_fennel_name, "tag/compile-fennel")
  attach_tag_21(tag_registry, window_border_name, "tag/window-border")
  attach_tag_21(tag_registry, url_dispatch_name, "tag/url-dispatch")
  attach_tag_21(tag_registry, url_routing_rules_name, "tag/url-routing-rules")
  return {["component-registry"] = component_registry, ["tag-registry"] = tag_registry}
end
package.preload["sheaf.component-registry"] = package.preload["sheaf.component-registry"] or function(...)
  local _local_303_ = require("lib.hierarchy")
  local isa_3f = _local_303_["isa?"]
  local _local_304_ = require("sheaf.trait-registry")
  local trait_defined_3f = _local_304_["trait-defined?"]
  local satisfies_all_3f = _local_304_["satisfies-all?"]
  local _local_305_ = require("sheaf.source-registry")
  local source_type_defined_3f = _local_305_["source-type-defined?"]
  local start_event_source_21 = _local_305_["start-event-source!"]
  local stop_event_source_21 = _local_305_["stop-event-source!"]
  local _local_316_ = require("sheaf.tag-registry")
  local attach_tag_21 = _local_316_["attach-tag!"]
  local detach_tag_21 = _local_316_["detach-tag!"]
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
        local ok, result = pcall(start_event_source_21, registry["source-registry"], source_name, source_decl.type, (source_decl.config or {}))
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
  local _local_306_ = require("lib.cljlib-shim")
  local hash_set = _local_306_["hash-set"]
  local conj = _local_306_.conj
  local disj = _local_306_.disj
  local contains_3f = _local_306_["contains?"]
  local seq = _local_306_.seq
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
      local _309_
      if seq(new_set) then
        _309_ = new_set
      else
        _309_ = nil
      end
      registry["instance-tags"][instance_name] = _309_
    else
    end
    if tag_insts then
      local new_set = disj(tag_insts, instance_name)
      local _312_
      if seq(new_set) then
        _312_ = new_set
      else
        _312_ = nil
      end
      registry["tag-instances"][tag] = _312_
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
  local _local_345_ = require("sheaf.component-registry")
  local make_component_type = _local_345_["make-component-type"]
  local space_indicator_type
  local function _346_(config)
    local menubar = hs.menubar.new(true, "cosmicHammerSpaceIndicator")
    if menubar then
      menubar:setTitle("...")
    else
    end
    return {menubar = menubar}
  end
  local function _348_(state)
    if state.menubar then
      return state.menubar:delete()
    else
      return nil
    end
  end
  space_indicator_type = make_component_type("component.type/space-indicator", "Space indicator menubar component", {traits = {"trait/has-menubar"}, sources = {{type = "event-source.type/space-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/space-watcher"}}, {type = "event-source.type/screen-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/screen-watcher"}}}, ["start-fn"] = _346_, ["stop-fn"] = _348_})
  return {["space-indicator-type"] = space_indicator_type}
end
package.preload["components.expose"] = package.preload["components.expose"] or function(...)
  local _local_351_ = require("sheaf.component-registry")
  local make_component_type = _local_351_["make-component-type"]
  local expose_type
  local function _352_(config)
    return {expose = hs.expose.new()}
  end
  expose_type = make_component_type("component.type/expose", "Expose window picker component", {traits = {"trait/has-expose"}, sources = {{type = "event-source.type/hotkey", config = {mods = {"ctrl", "cmd"}, key = "e"}, ["instance-name"] = "toggle", tags = {"tag/expose-hotkey"}}}, ["start-fn"] = _352_})
  return {["expose-type"] = expose_type}
end
package.preload["components.emacs"] = package.preload["components.emacs"] or function(...)
  local _local_354_ = require("sheaf.component-registry")
  local make_component_type = _local_354_["make-component-type"]
  local emacs_type
  local function _355_(config)
    return {}
  end
  emacs_type = make_component_type("component.type/emacs", "Emacs integration component", {sources = {{type = "event-source.type/hotkey", config = {mods = {"cmd", "alt"}, key = "return"}, ["instance-name"] = "open", tags = {"tag/emacs-hotkey"}}}, ["start-fn"] = _355_})
  return {["emacs-type"] = emacs_type}
end
package.preload["components.reload-hammerspoon"] = package.preload["components.reload-hammerspoon"] or function(...)
  local _local_357_ = require("sheaf.component-registry")
  local make_component_type = _local_357_["make-component-type"]
  local reload_hammerspoon_type
  local function _358_(config)
    return {timer = hs.timer.delayed.new(0.5, hs.reload), ["reloading?"] = false}
  end
  local function _359_(state)
    return state.timer:stop()
  end
  reload_hammerspoon_type = make_component_type("component.type/reload-hammerspoon", "Hammerspoon config reloader with debounce timer", {traits = {"trait/has-delayed-timer"}, ["start-fn"] = _358_, ["stop-fn"] = _359_})
  return {["reload-hammerspoon-type"] = reload_hammerspoon_type}
end
package.preload["components.compile-fennel"] = package.preload["components.compile-fennel"] or function(...)
  local _local_361_ = require("sheaf.component-registry")
  local make_component_type = _local_361_["make-component-type"]
  local compile_fennel_type
  local function _362_(config)
    return {}
  end
  compile_fennel_type = make_component_type("component.type/compile-fennel", "Fennel source file compiler", {["start-fn"] = _362_})
  return {["compile-fennel-type"] = compile_fennel_type}
end
package.preload["components.config-watcher"] = package.preload["components.config-watcher"] or function(...)
  local _local_364_ = require("sheaf.component-registry")
  local make_component_type = _local_364_["make-component-type"]
  local config_watcher_type
  local function _365_(config)
    return {}
  end
  config_watcher_type = make_component_type("component.type/config-watcher", "Watches config directory for file changes", {sources = {{type = "event-source.type/file-watcher", config = {path = hs.configdir}, ["instance-name"] = "config-dir", tags = {"tag/config-watcher"}}}, ["start-fn"] = _365_})
  return {["config-watcher-type"] = config_watcher_type}
end
package.preload["components.window-watcher"] = package.preload["components.window-watcher"] or function(...)
  local _local_367_ = require("sheaf.component-registry")
  local make_component_type = _local_367_["make-component-type"]
  local window_watcher_type
  local function _368_(config)
    return {}
  end
  window_watcher_type = make_component_type("component.type/window-watcher", "Watches window focus, visibility, and fullscreen changes", {sources = {{type = "event-source.type/window-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/window-watcher"}}}, ["start-fn"] = _368_})
  return {["window-watcher-type"] = window_watcher_type}
end
package.preload["components.app-watcher"] = package.preload["components.app-watcher"] or function(...)
  local _local_370_ = require("sheaf.component-registry")
  local make_component_type = _local_370_["make-component-type"]
  local app_watcher_type
  local function _371_(config)
    return {}
  end
  app_watcher_type = make_component_type("component.type/app-watcher", "Watches application lifecycle events (launch, quit, activate, deactivate, hidden)", {sources = {{type = "event-source.type/app-watcher", config = {}, ["instance-name"] = "default", tags = {"tag/app-watcher"}}}, ["start-fn"] = _371_})
  return {["app-watcher-type"] = app_watcher_type}
end
package.preload["components.window-border"] = package.preload["components.window-border"] or function(...)
  local _local_373_ = require("sheaf.component-registry")
  local make_component_type = _local_373_["make-component-type"]
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
  local function _374_(config)
    local cr = (config["corner-radius"] or 9)
    local active = make_border_canvas(config["active-color"], config.width, cr)
    local inactive = make_border_canvas(config["inactive-color"], config.width, cr)
    return {["active-canvas"] = active, ["inactive-canvas"] = inactive, ["active-window-id"] = nil, ["border-width"] = config.width, ["default-corner-radius"] = cr}
  end
  local function _375_(state)
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
  window_border_type = make_component_type("component.type/window-border", "Draws colored borders around active and inactive windows", {traits = {"trait/has-canvas"}, ["start-fn"] = _374_, ["stop-fn"] = _375_})
  return {["window-border-type"] = window_border_type}
end
package.preload["components.url-dispatch"] = package.preload["components.url-dispatch"] or function(...)
  local _local_379_ = require("sheaf.component-registry")
  local make_component_type = _local_379_["make-component-type"]
  local _local_380_ = require("event_sources.url-decoders")
  local default_decoders = _local_380_["default-decoders"]
  local url_dispatch_type
  local function _381_(config)
    return {}
  end
  url_dispatch_type = make_component_type("component.type/url-dispatch", "URL dispatch handler - routes URLs through decoders and opens them", {sources = {{type = "event-source.type/url-handler", config = {decoders = default_decoders}, ["instance-name"] = "main", tags = {"tag/url-handler"}}}, ["start-fn"] = _381_})
  return {["url-dispatch-type"] = url_dispatch_type}
end
package.preload["components.url-routing-rules"] = package.preload["components.url-routing-rules"] or function(...)
  local _local_383_ = require("sheaf.component-registry")
  local make_component_type = _local_383_["make-component-type"]
  local url_routing_rules_type
  local function _384_(config)
    return {browsers = {{id = "orion", ["bundle-id"] = "com.kagi.kagimacOS"}, {id = "firefox", ["bundle-id"] = "org.mozilla.firefox"}, {id = "arc", ["bundle-id"] = "company.thebrowser.Browser"}, {id = "chrome", ["bundle-id"] = "com.google.Chrome"}, {id = "safari", ["bundle-id"] = "com.apple.Safari"}, {id = "brave", ["bundle-id"] = "com.brave.Browser"}, {id = "edge", ["bundle-id"] = "com.microsoft.edgemac"}, {id = "zen", ["bundle-id"] = "app.zen-browser.zen"}, {id = "dia", ["bundle-id"] = "company.thebrowser.dia"}, {id = "figma", ["bundle-id"] = "com.figma.Desktop"}, {id = "helium", ["bundle-id"] = "net.imput.helium"}, {id = "ora", ["bundle-id"] = "com.orabrowser.app"}, {id = "surf", ["bundle-id"] = "surf.deta"}}, fallback = {type = "choose", ["browser-ids"] = "all"}, rules = {}}
  end
  url_routing_rules_type = make_component_type("component.type/url-routing-rules", "URL routing configuration: browsers, fallback action, and ordered rules", {traits = {"trait/has-url-routing-rules"}, ["start-fn"] = _384_})
  return {["url-routing-rules-type"] = url_routing_rules_type}
end
local _local_386_ = require("components")
local component_registry = _local_386_["component-registry"]
package.preload["commands"] = package.preload["commands"] or function(...)
  local _local_393_ = require("sheaf.command-registry")
  local make_command_registry = _local_393_["make-command-registry"]
  local add_command_21 = _local_393_["add-command!"]
  local _local_394_ = require("traits")
  local trait_registry = _local_394_["trait-registry"]
  local _local_397_ = require("commands.toggle-expose")
  local toggle_expose_command = _local_397_["toggle-expose-command"]
  local _local_403_ = require("commands.space-indicator")
  local update_menubar_command = _local_403_["update-menubar-command"]
  local _local_406_ = require("commands.compile-fennel")
  local compile_command = _local_406_["compile-command"]
  local _local_410_ = require("commands.reload-hammerspoon")
  local reload_hammerspoon_command = _local_410_["reload-hammerspoon-command"]
  local _local_413_ = require("commands.open-in-app")
  local open_in_app_command = _local_413_["open-in-app-command"]
  local _local_419_ = require("commands.show-chooser")
  local show_chooser_command = _local_419_["show-chooser-command"]
  local _local_425_ = require("commands.open-emacs")
  local open_emacs_command = _local_425_["open-emacs-command"]
  local _local_436_ = require("commands.window-border")
  local show_active_border_command = _local_436_["show-active-border-command"]
  local show_inactive_border_command = _local_436_["show-inactive-border-command"]
  local hide_borders_command = _local_436_["hide-borders-command"]
  local command_registry = make_command_registry({["trait-registry"] = trait_registry})
  add_command_21(command_registry, toggle_expose_command)
  add_command_21(command_registry, update_menubar_command)
  add_command_21(command_registry, compile_command)
  add_command_21(command_registry, reload_hammerspoon_command)
  add_command_21(command_registry, open_in_app_command)
  add_command_21(command_registry, show_chooser_command)
  add_command_21(command_registry, open_emacs_command)
  add_command_21(command_registry, show_active_border_command)
  add_command_21(command_registry, show_inactive_border_command)
  add_command_21(command_registry, hide_borders_command)
  return {["command-registry"] = command_registry}
end
package.preload["sheaf.command-registry"] = package.preload["sheaf.command-registry"] or function(...)
  local _local_387_ = require("sheaf.trait-registry")
  local trait_defined_3f = _local_387_["trait-defined?"]
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
  local _local_395_ = require("sheaf.command-registry")
  local make_command = _local_395_["make-command"]
  local toggle_expose_command
  local function _396_(component, params)
    component.state.expose:toggleShow()
    return nil
  end
  toggle_expose_command = make_command("expose.commands/toggle-show", "Toggle the Hammerspoon Expose window picker", {["requires-traits"] = {"trait/has-expose"}, fn = _396_})
  return {["toggle-expose-command"] = toggle_expose_command}
end
package.preload["commands.space-indicator"] = package.preload["commands.space-indicator"] or function(...)
  local _local_398_ = require("sheaf.command-registry")
  local make_command = _local_398_["make-command"]
  local update_menubar_command
  local function _399_(component, params)
    if component.state.menubar then
      local _400_
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
        _400_ = tbl_26_
      end
      component.state.menubar:setTitle(table.concat(_400_, "|"))
    else
    end
    return nil
  end
  update_menubar_command = make_command("space-indicator.commands/update-menubar", "Update the space indicator menubar with active space indices", {["requires-traits"] = {"trait/has-menubar"}, schema = {["active-spaces"] = __fnl_global__table_3f}, fn = _399_})
  return {["update-menubar-command"] = update_menubar_command}
end
package.preload["commands.compile-fennel"] = package.preload["commands.compile-fennel"] or function(...)
  local _local_404_ = require("sheaf.command-registry")
  local make_command = _local_404_["make-command"]
  local compile_command
  local function _405_(component, params)
    print(hs.execute("./compile.sh", true))
    return nil
  end
  compile_command = make_command("compile-fennel.commands/compile", "Compile Fennel source files", {fn = _405_})
  return {["compile-command"] = compile_command}
end
package.preload["commands.reload-hammerspoon"] = package.preload["commands.reload-hammerspoon"] or function(...)
  local _local_407_ = require("sheaf.command-registry")
  local make_command = _local_407_["make-command"]
  local notify = require("notify")
  local reload_hammerspoon_command
  local function _408_(component, params)
    if not component.state["reloading?"] then
      notify.warn("Reloading...")
      component.state.timer:start()
      return {timer = component.state.timer, ["reloading?"] = true}
    else
      return nil
    end
  end
  reload_hammerspoon_command = make_command("reload-hammerspoon.commands/reload", "Reload Hammerspoon config with debounce", {["requires-traits"] = {"trait/has-delayed-timer"}, fn = _408_})
  return {["reload-hammerspoon-command"] = reload_hammerspoon_command}
end
package.preload["commands.open-in-app"] = package.preload["commands.open-in-app"] or function(...)
  local _local_411_ = require("sheaf.command-registry")
  local make_command = _local_411_["make-command"]
  local open_in_app_command
  local function _412_(component, params)
    print(("[DEBUG] open-in-app: url=" .. tostring(params.url) .. " bundle-id=" .. tostring(params["bundle-id"])))
    hs.urlevent.openURLWithBundle(params.url, params["bundle-id"])
    return nil
  end
  open_in_app_command = make_command("url-dispatch.commands/open-in-app", "Open a URL in a specific app by bundle ID", {schema = {url = __fnl_global__string_3f, ["bundle-id"] = __fnl_global__string_3f}, fn = _412_})
  return {["open-in-app-command"] = open_in_app_command}
end
package.preload["commands.show-chooser"] = package.preload["commands.show-chooser"] or function(...)
  local _local_414_ = require("sheaf.command-registry")
  local make_command = _local_414_["make-command"]
  local active_chooser = nil
  local show_chooser_command
  local function _415_(component, params)
    print(("[DEBUG] show-chooser: url=" .. tostring(params.url) .. " choices=" .. tostring(#(params.choices or {}))))
    if ((nil == params.choices) or (0 == #params.choices)) then
      print("[WARN] show-chooser: no choices provided, skipping")
      return nil
    else
    end
    do
      local url = params.url
      local chooser
      local function _417_(choice)
        if choice then
          print(("[DEBUG] show-chooser: user chose " .. tostring(choice.text) .. " (" .. tostring(choice["bundle-id"]) .. ")"))
          return hs.urlevent.openURLWithBundle(url, choice["bundle-id"])
        else
          return print("[DEBUG] show-chooser: user dismissed chooser")
        end
      end
      chooser = hs.chooser.new(_417_)
      chooser:choices(params.choices)
      chooser:show()
      active_chooser = chooser
    end
    return nil
  end
  show_chooser_command = make_command("url-dispatch.commands/show-chooser", "Show an async browser picker dialog for a URL", {schema = {url = __fnl_global__string_3f, choices = __fnl_global__table_3f}, fn = _415_})
  return {["show-chooser-command"] = show_chooser_command}
end
package.preload["commands.open-emacs"] = package.preload["commands.open-emacs"] or function(...)
  local _local_420_ = require("sheaf.command-registry")
  local make_command = _local_420_["make-command"]
  local emacsclient_path
  do
    local app = hs.application.find("Emacs")
    if app then
      emacsclient_path = app:path():gsub("Emacs.app", "bin/emacsclient")
    else
      emacsclient_path = "/opt/homebrew/bin/emacsclient"
    end
  end
  local open_emacs_command
  local function _422_(component, params)
    io.popen(("'" .. emacsclient_path .. "' -n -c &"))
    local function _423_()
      local app = hs.application.find("Emacs")
      if app then
        return app:activate()
      else
        return nil
      end
    end
    hs.timer.doAfter(0.3, _423_)
    return nil
  end
  open_emacs_command = make_command("emacs.commands/open-emacs", "Open a new emacsclient frame", {fn = _422_})
  return {["open-emacs-command"] = open_emacs_command}
end
package.preload["commands.window-border"] = package.preload["commands.window-border"] or function(...)
  local _local_426_ = require("sheaf.command-registry")
  local make_command = _local_426_["make-command"]
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
  local function _429_(component, params)
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
  show_active_border_command = make_command("window-border.commands/show-active-border", "Position and show the active window border around a window frame", {["requires-traits"] = {"trait/has-canvas"}, fn = _429_})
  local show_inactive_border_command
  local function _431_(component, params)
    do
      local bw = component.state["border-width"]
      local cr = resolve_corner_radius(params["window-id"], component.state["default-corner-radius"])
      position_border_canvas(component.state["inactive-canvas"], bw, cr, params.frame)
    end
    return nil
  end
  show_inactive_border_command = make_command("window-border.commands/show-inactive-border", "Position and show the inactive window border around a window frame", {["requires-traits"] = {"trait/has-canvas"}, fn = _431_})
  local hide_borders_command
  local function _432_(component, params)
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
  hide_borders_command = make_command("window-border.commands/hide-borders", "Hide both active and inactive window border overlays", {["requires-traits"] = {"trait/has-canvas"}, fn = _432_})
  return {["show-active-border-command"] = show_active_border_command, ["show-inactive-border-command"] = show_inactive_border_command, ["hide-borders-command"] = hide_borders_command}
end
require("commands")
package.preload["behaviors"] = package.preload["behaviors"] or function(...)
  local _local_457_ = require("sheaf.behavior-registry")
  local make_behavior_registry = _local_457_["make-behavior-registry"]
  local add_behavior_21 = _local_457_["add-behavior!"]
  local _local_458_ = require("events")
  local event_registry = _local_458_["event-registry"]
  local _local_459_ = require("commands")
  local command_registry = _local_459_["command-registry"]
  local _local_460_ = require("shapes")
  local shape_registry = _local_460_["shape-registry"]
  local _local_467_ = require("behaviors.compile-fennel")
  local compile_fennel_behavior = _local_467_["compile-fennel-behavior"]
  local _local_474_ = require("behaviors.reload-hammerspoon")
  local reload_hammerspoon_behavior = _local_474_["reload-hammerspoon-behavior"]
  local _local_478_ = require("behaviors.toggle-expose")
  local toggle_expose_behavior = _local_478_["toggle-expose-behavior"]
  local _local_483_ = require("behaviors.update-space-indicator")
  local update_space_indicator_behavior = _local_483_["update-space-indicator-behavior"]
  local _local_487_ = require("behaviors.open-emacs")
  local open_emacs_behavior = _local_487_["open-emacs-behavior"]
  local _local_495_ = require("behaviors.window-border")
  local update_on_focus_behavior = _local_495_["update-on-focus-behavior"]
  local update_on_move_behavior = _local_495_["update-on-move-behavior"]
  local hide_on_disappear_behavior = _local_495_["hide-on-disappear-behavior"]
  local _local_572_ = require("behaviors.url-routing")
  local route_url_behavior = _local_572_["route-url-behavior"]
  local behavior_registry = make_behavior_registry({["event-registry"] = event_registry, ["command-registry"] = command_registry, ["shape-registry"] = shape_registry})
  add_behavior_21(behavior_registry, compile_fennel_behavior)
  add_behavior_21(behavior_registry, reload_hammerspoon_behavior)
  add_behavior_21(behavior_registry, toggle_expose_behavior)
  add_behavior_21(behavior_registry, update_space_indicator_behavior)
  add_behavior_21(behavior_registry, open_emacs_behavior)
  add_behavior_21(behavior_registry, update_on_focus_behavior)
  add_behavior_21(behavior_registry, update_on_move_behavior)
  add_behavior_21(behavior_registry, hide_on_disappear_behavior)
  add_behavior_21(behavior_registry, route_url_behavior)
  return {["behavior-registry"] = behavior_registry}
end
package.preload["sheaf.behavior-registry"] = package.preload["sheaf.behavior-registry"] or function(...)
  local _local_437_ = require("lib.cljlib-shim")
  local some = _local_437_.some
  local _local_438_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_438_["valid-event-selector?"]
  local _local_439_ = require("sheaf.command-registry")
  local command_defined_3f = _local_439_["command-defined?"]
  local _local_440_ = require("sheaf.shape-registry")
  local shape_defined_3f = _local_440_["shape-defined?"]
  local _local_441_ = require("lib.hierarchy")
  local isa_3f = _local_441_["isa?"]
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
      local function _455_(_241)
        return isa_3f(registry["event-registry"].hierarchy, event_name, _241)
      end
      return some(_455_, behavior["respond-to"])
    end
  end
  return {["make-behavior-registry"] = make_behavior_registry, ["make-behavior"] = make_behavior, ["add-behavior!"] = add_behavior_21, ["behavior-defined?"] = behavior_defined_3f, ["get-behavior"] = get_behavior, ["list-behaviors"] = list_behaviors, ["behavior-responds-to?"] = behavior_responds_to_3f}
end
package.preload["behaviors.compile-fennel"] = package.preload["behaviors.compile-fennel"] or function(...)
  local _local_461_ = require("sheaf.behavior-registry")
  local make_behavior = _local_461_["make-behavior"]
  local compile_fennel_behavior
  local function _462_(file_change_event, candidates, send_cmd)
    local path
    do
      local t_463_ = file_change_event
      if (nil ~= t_463_) then
        t_463_ = t_463_["event-data"]
      else
      end
      if (nil ~= t_463_) then
        t_463_ = t_463_["file-path"]
      else
      end
      path = t_463_
    end
    local target = candidates.compile[1]
    if (target and (nil ~= path) and (".fnl" == path:sub(-4))) then
      return send_cmd(target, "compile", {})
    else
      return nil
    end
  end
  compile_fennel_behavior = make_behavior({name = "compile-fennel.behaviors/compile-fennel", description = "Watch fennel files in hammerspoon folder and recompile them.", ["respond-to"] = {"event.kind.fs/file-change"}, commands = {compile = "compile-fennel.commands/compile"}, fn = _462_})
  return {["compile-fennel-behavior"] = compile_fennel_behavior}
end
package.preload["behaviors.reload-hammerspoon"] = package.preload["behaviors.reload-hammerspoon"] or function(...)
  local _local_468_ = require("sheaf.behavior-registry")
  local make_behavior = _local_468_["make-behavior"]
  local reload_hammerspoon_behavior
  local function _469_(file_change_event, candidates, send_cmd)
    local path
    do
      local t_470_ = file_change_event
      if (nil ~= t_470_) then
        t_470_ = t_470_["event-data"]
      else
      end
      if (nil ~= t_470_) then
        t_470_ = t_470_["file-path"]
      else
      end
      path = t_470_
    end
    local target = candidates.reload[1]
    if (target and (nil ~= path) and ("/init.lua" == path:sub(-9))) then
      return send_cmd(target, "reload", {})
    else
      return nil
    end
  end
  reload_hammerspoon_behavior = make_behavior({name = "reload-hammerspoon.behaviors/reload-hammerspoon", description = "When init.lua changes, reload hammerspoon.", ["respond-to"] = {"event.kind.fs/file-change"}, commands = {reload = "reload-hammerspoon.commands/reload"}, fn = _469_})
  return {["reload-hammerspoon-behavior"] = reload_hammerspoon_behavior}
end
package.preload["behaviors.toggle-expose"] = package.preload["behaviors.toggle-expose"] or function(...)
  local _local_475_ = require("sheaf.behavior-registry")
  local make_behavior = _local_475_["make-behavior"]
  local toggle_expose_behavior
  local function _476_(event, candidates, send_cmd)
    local target = candidates["toggle-show"][1]
    if target then
      return send_cmd(target, "toggle-show", {})
    else
      return nil
    end
  end
  toggle_expose_behavior = make_behavior({name = "expose.behaviors/toggle-expose", description = "Toggle the Hammerspoon Expose window picker", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["toggle-show"] = "expose.commands/toggle-show"}, fn = _476_})
  return {["toggle-expose-behavior"] = toggle_expose_behavior}
end
package.preload["behaviors.update-space-indicator"] = package.preload["behaviors.update-space-indicator"] or function(...)
  local _local_479_ = require("sheaf.behavior-registry")
  local make_behavior = _local_479_["make-behavior"]
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
  local function _481_(event, candidates, send_cmd)
    local target = candidates["update-menubar"][1]
    if target then
      local indices = compute_active_space_indices(event["event-data"]["all-spaces"], event["event-data"]["active-spaces"])
      return send_cmd(target, "update-menubar", {["active-spaces"] = indices})
    else
      return nil
    end
  end
  update_space_indicator_behavior = make_behavior({name = "space-indicator.behaviors/update-on-change", description = "Update space indicator menubar when spaces or screens change", ["respond-to"] = {"event.kind.space/changed", "event.kind.screen/any"}, commands = {["update-menubar"] = "space-indicator.commands/update-menubar"}, fn = _481_})
  return {["update-space-indicator-behavior"] = update_space_indicator_behavior}
end
package.preload["behaviors.open-emacs"] = package.preload["behaviors.open-emacs"] or function(...)
  local _local_484_ = require("sheaf.behavior-registry")
  local make_behavior = _local_484_["make-behavior"]
  local open_emacs_behavior
  local function _485_(event, candidates, send_cmd)
    local target = candidates["open-emacs"][1]
    if target then
      return send_cmd(target, "open-emacs", {})
    else
      return nil
    end
  end
  open_emacs_behavior = make_behavior({name = "emacs.behaviors/open-emacs", description = "Open a new emacsclient frame on hotkey press", ["respond-to"] = {"event.kind.hotkey/pressed"}, commands = {["open-emacs"] = "emacs.commands/open-emacs"}, fn = _485_})
  return {["open-emacs-behavior"] = open_emacs_behavior}
end
package.preload["behaviors.window-border"] = package.preload["behaviors.window-border"] or function(...)
  local _local_488_ = require("sheaf.behavior-registry")
  local make_behavior = _local_488_["make-behavior"]
  local update_on_focus_behavior
  local function _489_(event, candidates, send_cmd)
    local target = candidates["show-active"][1]
    if target then
      return send_cmd(target, "show-active", {["window-id"] = event["event-data"]["window-id"], frame = event["event-data"].frame})
    else
      return nil
    end
  end
  update_on_focus_behavior = make_behavior({name = "window-border.behaviors/update-on-focus", description = "Show active border around the newly focused window", ["respond-to"] = {"event.kind.window/focused", "event.kind.window/visible"}, commands = {["show-active"] = "window-border.commands/show-active-border", ["show-inactive"] = "window-border.commands/show-inactive-border"}, fn = _489_})
  local update_on_move_behavior
  local function _491_(event, candidates, send_cmd)
    local target = candidates["show-active"][1]
    if target then
      return send_cmd(target, "show-active", {["window-id"] = event["event-data"]["window-id"], frame = event["event-data"].frame, ["only-if-active"] = true})
    else
      return nil
    end
  end
  update_on_move_behavior = make_behavior({name = "window-border.behaviors/update-on-move", description = "Reposition active border when a window moves or resizes", ["respond-to"] = {"event.kind.window/moved"}, commands = {["show-active"] = "window-border.commands/show-active-border"}, fn = _491_})
  local hide_on_disappear_behavior
  local function _493_(event, candidates, send_cmd)
    local target = candidates.hide[1]
    if target then
      return send_cmd(target, "hide", {["window-id"] = event["event-data"]["window-id"], ["only-if-active"] = true})
    else
      return nil
    end
  end
  hide_on_disappear_behavior = make_behavior({name = "window-border.behaviors/hide-on-disappear", description = "Hide active border when the focused window disappears", ["respond-to"] = {"event.kind.window/not-visible"}, commands = {hide = "window-border.commands/hide-borders"}, fn = _493_})
  return {["update-on-focus-behavior"] = update_on_focus_behavior, ["update-on-move-behavior"] = update_on_move_behavior, ["hide-on-disappear-behavior"] = hide_on_disappear_behavior}
end
package.preload["behaviors.url-routing"] = package.preload["behaviors.url-routing"] or function(...)
  local _local_496_ = require("sheaf.behavior-registry")
  local make_behavior = _local_496_["make-behavior"]
  local _local_535_ = require("lib.url-routing")
  local build_browser_lookup = _local_535_["build-browser-lookup"]
  local resolve_browser = _local_535_["resolve-browser"]
  local resolve_browsers = _local_535_["resolve-browsers"]
  local make_chooser_choices = _local_535_["make-chooser-choices"]
  local parse_url = _local_535_["parse-url"]
  local match_rule_3f = _local_535_["match-rule?"]
  local find_matching_rule = _local_535_["find-matching-rule"]
  local function dispatch_open_in_app(action, url, lookup, target, send_cmd)
    print(("[DEBUG] url-routing: dispatch-open-in-app browser-id=" .. tostring(action["browser-id"])))
    local browser = resolve_browser(action["browser-id"], lookup)
    if browser then
      print(("[DEBUG] url-routing: opening in " .. tostring(browser.name) .. " (" .. tostring(browser["bundle-id"]) .. ")"))
      return send_cmd(target, "open-in-app", {url = url, ["bundle-id"] = browser["bundle-id"]})
    else
      return nil
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
        return dispatch_open_in_app(action, url, lookup, target, send_cmd)
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
  local function _544_(event, candidates, send_cmd, inputs)
    print("[DEBUG] url-routing: behavior invoked")
    local url
    do
      local t_545_ = event
      if (nil ~= t_545_) then
        t_545_ = t_545_["event-data"]
      else
      end
      if (nil ~= t_545_) then
        t_545_ = t_545_.url
      else
      end
      url = t_545_
    end
    local sender_bundle_id
    do
      local t_548_ = event
      if (nil ~= t_548_) then
        t_548_ = t_548_["event-data"]
      else
      end
      if (nil ~= t_548_) then
        t_548_ = t_548_["sender-bundle-id"]
      else
      end
      sender_bundle_id = t_548_
    end
    print(("[DEBUG] url-routing: url=" .. tostring(url) .. " sender=" .. tostring(sender_bundle_id)))
    if (nil == url) then
      print("[WARN] url-routing: event missing :url in event-data")
      return nil
    else
    end
    local function _554_()
      if inputs then
        local t_552_ = inputs
        if (nil ~= t_552_) then
          t_552_ = t_552_.rules
        else
        end
        return t_552_
      else
        return nil
      end
    end
    print(("[DEBUG] url-routing: inputs=" .. tostring(inputs) .. " inputs.rules=" .. tostring(_554_())))
    local rules_state
    if inputs then
      local t_555_ = inputs
      if (nil ~= t_555_) then
        t_555_ = t_555_.rules
      else
      end
      rules_state = t_555_
    else
      rules_state = nil
    end
    local browsers
    local _559_
    do
      local t_558_ = rules_state
      if (nil ~= t_558_) then
        t_558_ = t_558_.browsers
      else
      end
      _559_ = t_558_
    end
    browsers = (_559_ or {})
    local rules
    local _562_
    do
      local t_561_ = rules_state
      if (nil ~= t_561_) then
        t_561_ = t_561_.rules
      else
      end
      _562_ = t_561_
    end
    rules = (_562_ or {})
    local fallback
    do
      local t_564_ = rules_state
      if (nil ~= t_564_) then
        t_564_ = t_564_.fallback
      else
      end
      fallback = t_564_
    end
    local lookup = build_browser_lookup(browsers)
    local parsed = parse_url(url)
    local matched_rule = find_matching_rule(parsed, sender_bundle_id, rules)
    local action
    if matched_rule then
      action = matched_rule.action
    else
      action = fallback
    end
    local function _567_()
      if matched_rule then
        return matched_rule.id
      else
        return nil
      end
    end
    local function _569_()
      local t_568_ = action
      if (nil ~= t_568_) then
        t_568_ = t_568_.type
      else
      end
      return t_568_
    end
    print(("[DEBUG] url-routing: browsers=" .. tostring(#browsers) .. " matched-rule=" .. tostring(_567_()) .. " action.type=" .. tostring(_569_())))
    if action then
      return dispatch_action(action, url, browsers, lookup, candidates, send_cmd)
    else
      return print(("[WARN] url-routing: no matching rule and no fallback for URL '" .. tostring(url) .. "'"))
    end
  end
  route_url_behavior = make_behavior({name = "url-dispatch.behaviors/route-url", description = "Route opened URLs to browsers based on structured routing rules", ["respond-to"] = {"event.kind.url/opened"}, commands = {["open-in-app"] = "url-dispatch.commands/open-in-app", ["show-chooser"] = "url-dispatch.commands/show-chooser"}, inputs = {rules = "shape/url-routing-rules"}, fn = _544_})
  return {["route-url-behavior"] = route_url_behavior}
end
package.preload["lib.url-routing"] = package.preload["lib.url-routing"] or function(...)
  local _local_497_ = require("lib.cljlib-shim")
  local some = _local_497_.some
  local seq = _local_497_.seq
  local empty_3f = _local_497_["empty?"]
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
    local _532_
    if match_spec.urls then
      _532_ = match_urls_3f(parsed_url, match_spec.urls)
    else
      _532_ = true
    end
    return (_532_ and match_sender_3f(sender_bundle_id, match_spec["sender-bundle-ids"]))
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
require("behaviors")
package.preload["subscriptions"] = package.preload["subscriptions"] or function(...)
  local _local_599_ = require("sheaf.subscription-registry")
  local make_subscription_registry = _local_599_["make-subscription-registry"]
  local define_subscription_21 = _local_599_["define-subscription!"]
  local _local_600_ = require("events")
  local event_registry = _local_600_["event-registry"]
  local _local_601_ = require("behaviors")
  local behavior_registry = _local_601_["behavior-registry"]
  local _local_602_ = require("components")
  local tag_registry = _local_602_["tag-registry"]
  local subscription_registry = make_subscription_registry({["event-registry"] = event_registry, ["behavior-registry"] = behavior_registry, ["tag-registry"] = tag_registry})
  define_subscription_21(subscription_registry, "sub/reload-on-config-change", {description = "Reload Hammerspoon when init.lua changes", behavior = "reload-hammerspoon.behaviors/reload-hammerspoon", ["source-tag"] = "tag/config-watcher", ["target-tag"] = "tag/reload-hammerspoon", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/compile-on-fnl-change", {description = "Recompile Fennel when .fnl files change", behavior = "compile-fennel.behaviors/compile-fennel", ["source-tag"] = "tag/config-watcher", ["target-tag"] = "tag/compile-fennel", ["event-selector"] = "event.kind.fs/file-change"})
  define_subscription_21(subscription_registry, "sub/toggle-expose-on-hotkey", {description = "Toggle Expose when ctrl+cmd+e is pressed", behavior = "expose.behaviors/toggle-expose", ["source-tag"] = "tag/expose-hotkey", ["target-tag"] = "tag/expose", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-space-change", {description = "Update space indicator when space changes", behavior = "space-indicator.behaviors/update-on-change", ["source-tag"] = "tag/space-watcher", ["target-tag"] = "tag/space-indicator", ["event-selector"] = "event.kind.space/changed"})
  define_subscription_21(subscription_registry, "sub/update-indicator-on-screen-change", {description = "Update space indicator when screen layout changes", behavior = "space-indicator.behaviors/update-on-change", ["source-tag"] = "tag/screen-watcher", ["target-tag"] = "tag/space-indicator", ["event-selector"] = "event.kind.screen/layout-changed"})
  define_subscription_21(subscription_registry, "sub/open-emacs-on-hotkey", {description = "Open emacsclient frame when cmd+alt+return is pressed", behavior = "emacs.behaviors/open-emacs", ["source-tag"] = "tag/emacs-hotkey", ["target-tag"] = "tag/emacs", ["event-selector"] = "event.kind.hotkey/pressed"})
  define_subscription_21(subscription_registry, "sub/border-on-focus", {description = "Show active border when a window gains focus", behavior = "window-border.behaviors/update-on-focus", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/focused"})
  define_subscription_21(subscription_registry, "sub/border-on-visible", {description = "Show active border when a window becomes visible", behavior = "window-border.behaviors/update-on-focus", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/visible"})
  define_subscription_21(subscription_registry, "sub/border-on-move", {description = "Reposition active border when a window moves or resizes", behavior = "window-border.behaviors/update-on-move", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/moved"})
  define_subscription_21(subscription_registry, "sub/border-on-disappear", {description = "Hide active border when the focused window disappears", behavior = "window-border.behaviors/hide-on-disappear", ["source-tag"] = "tag/window-watcher", ["target-tag"] = "tag/window-border", ["event-selector"] = "event.kind.window/not-visible"})
  define_subscription_21(subscription_registry, "sub/route-url-on-open", {description = "Route opened URLs to browsers based on rules", behavior = "url-dispatch.behaviors/route-url", ["source-tag"] = "tag/url-handler", ["target-tag"] = "tag/url-dispatch", ["input-tag"] = "tag/url-routing-rules", ["event-selector"] = "event.kind.url/opened"})
  return {["subscription-registry"] = subscription_registry}
end
package.preload["sheaf.subscription-registry"] = package.preload["sheaf.subscription-registry"] or function(...)
  local _local_573_ = require("lib.cljlib-shim")
  local hash_set = _local_573_["hash-set"]
  local conj = _local_573_.conj
  local disj = _local_573_.disj
  local into = _local_573_.into
  local seq = _local_573_.seq
  local _local_574_ = require("sheaf.event-registry")
  local valid_event_selector_3f = _local_574_["valid-event-selector?"]
  local _local_575_ = require("sheaf.behavior-registry")
  local behavior_defined_3f = _local_575_["behavior-defined?"]
  local _local_576_ = require("sheaf.tag-registry")
  local get_tags = _local_576_["get-tags"]
  local _local_577_ = require("lib.hierarchy")
  local ancestors = _local_577_.ancestors
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
      local t_583_ = registry.index
      if (nil ~= t_583_) then
        t_583_ = t_583_[tag]
      else
      end
      if (nil ~= t_583_) then
        t_583_ = t_583_[event]
      else
      end
      sub_set = t_583_
    end
    if sub_set then
      do
        local new_set = disj(sub_set, sub_name)
        local _586_
        if seq(new_set) then
          _586_ = new_set
        else
          _586_ = nil
        end
        registry.index[tag][event] = _586_
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
    local subscription = {name = name, description = opts.description, behavior = opts.behavior, ["event-selector"] = opts["event-selector"], ["source-tag"] = opts["source-tag"], ["target-tag"] = opts["target-tag"], ["input-tag"] = opts["input-tag"]}
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
            val_28_ = {behavior = sub.behavior, ["target-tag"] = sub["target-tag"], ["input-tag"] = sub["input-tag"]}
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
local _local_603_ = require("subscriptions")
local subscription_registry = _local_603_["subscription-registry"]
package.preload["sheaf.dispatcher"] = package.preload["sheaf.dispatcher"] or function(...)
  local _local_604_ = require("sheaf.event-registry")
  local add_event_handler_21 = _local_604_["add-event-handler!"]
  local _local_605_ = require("sheaf.behavior-registry")
  local behavior_responds_to_3f = _local_605_["behavior-responds-to?"]
  local get_behavior = _local_605_["get-behavior"]
  local _local_606_ = require("sheaf.subscription-registry")
  local get_matching_subscriptions = _local_606_["get-matching-subscriptions"]
  local _local_607_ = require("sheaf.command-registry")
  local get_command = _local_607_["get-command"]
  local _local_608_ = require("sheaf.tag-registry")
  local components_with_tag = _local_608_["components-with-tag"]
  local _local_609_ = require("sheaf.component-registry")
  local get_component_instance = _local_609_["get-component-instance"]
  local _local_610_ = require("sheaf.trait-registry")
  local satisfies_all_3f = _local_610_["satisfies-all?"]
  local _local_611_ = require("sheaf.shape-registry")
  local conforms_3f = _local_611_["conforms?"]
  local function build_candidates(behavior, command_registry, component_registry, trait_registry, tag_registry, target_tag)
    local candidates = {}
    local target_instances = components_with_tag(tag_registry, target_tag)
    for alias, cmd_name in pairs((behavior.commands or {})) do
      local command = get_command(command_registry, cmd_name)
      local required_traits
      local _613_
      do
        local t_612_ = command
        if (nil ~= t_612_) then
          t_612_ = t_612_["requires-traits"]
        else
        end
        _613_ = t_612_
      end
      required_traits = (_613_ or {})
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
    local function _616_(instance_name, cmd_alias, params)
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
    return _616_
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
  local function dispatch_to_behavior(subscription_registry, component_registry, _3fshape_registry, event, behavior_name, target_tag, input_tag)
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
    return behavior.fn(event, candidates, send_cmd, inputs)
  end
  local function start_dispatcher_21(subscription_registry, component_registry, _3fshape_registry)
    local event_registry = subscription_registry["event-registry"]
    local function _629_(event)
      local sub_matches = get_matching_subscriptions(subscription_registry, event["event-source"], event["event-name"])
      for _, sub_match in ipairs((sub_matches or {})) do
        dispatch_to_behavior(subscription_registry, component_registry, _3fshape_registry, event, sub_match.behavior, sub_match["target-tag"], sub_match["input-tag"])
      end
      return nil
    end
    add_event_handler_21(event_registry, "dispatcher/behavior-router", _629_)
    local function _630_(event)
      if _G["event-bus.debug-mode?"] then
        return print("got event", hs.inspect(event))
      else
        return nil
      end
    end
    return add_event_handler_21(event_registry, "dispatcher/debug-handler", _630_)
  end
  return {["start-dispatcher!"] = start_dispatcher_21}
end
local _local_632_ = require("sheaf.dispatcher")
local start_dispatcher_21 = _local_632_["start-dispatcher!"]
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
    local function _637_()
      while process_event_21(event_loop) do
      end
      return nil
    end
    timer = hs.timer.new(0.01, _637_)
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
local _local_639_ = require("sheaf.event-loop")
local make_event_loop = _local_639_["make-event-loop"]
local start_event_loop_21 = _local_639_["start-event-loop!"]
start_dispatcher_21(subscription_registry, component_registry, shape_registry)
local event_loop = make_event_loop(event_registry)
start_event_loop_21(event_loop)
notify.warn("Reload Succeeded")
return {}
