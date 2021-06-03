-------------------------------------------------------------------------------
-- 
-- Personal Hammerspoon layout configuration.
--
-- Akermen https://EksiKalori.com
-- 17.04.2020
-- 
-------------------------------------------------------------------------------
prefix = require("prefix")
-------------------------------------------------------------------------------
config = hs.json.read("config.json")
-------------------------------------------------------------------------------
hs.window.animationDuration = 0
hs.application.enableSpotlightForNameSearches(true)
--hs.window.setShadows(false)
--hs.window.setFrameCorrectness = true
-------------------------------------------------------------------------------
hs.loadSpoon("ReloadConfiguration")
hs.loadSpoon("AClock")
hs.loadSpoon("WinWin")
spoon.ReloadConfiguration:start()
spoon.AClock:init()
spoon.WinWin.gridparts = 180
-------------------------------------------------------------------------------
function hs.screen.get(screen_name)
  local allScreens = hs.screen.allScreens()
  for i, screen in ipairs(allScreens) do
    if screen:name() == screen_name then
      return screen
    end
  end
end
-------------------------------------------------------------------------------
function grid(win, rows, cols, row, col, rs, cs)
  cs = cs or 1  -- row scale
  rs = rs or 1  -- column scale
  local win = win or hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  f.w = cs * max.w // cols
  f.h = rs * max.h // rows
  f.x = max.x + col * max.w // cols
  f.y = max.y + row * max.h // rows
  win:setFrame(f)
end
-------------------------------------------------------------------------------
function center()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  f.x = max.x + (max.w - f.w) // 2
  f.y = max.y + (max.h - f.h) // 2
  win:setFrame(f)
end
-------------------------------------------------------------------------------
function resize(ax, ay, x, y)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  f.w = f.w - max.w * 0.02 * x
  f.h = f.h - max.h * 0.02 * y
  win:setFrame(f)
end
-------------------------------------------------------------------------------
function open_apps(apps)
  for _, appName in ipairs(apps) do
    hs.application.launchOrFocus(appName)
    -- hs.application.open()
  end
end
-------------------------------------------------------------------------------
function close_apps(apps)
  for _, appName in ipairs(apps) do
    local app = hs.application(appName)
    if (app) then
      if (app:isRunning()) then
          app:kill()
      end
    end
  end
end
-------------------------------------------------------------------------------
function close_all_apps()
  for _, value in pairs(config.applications) do
    close_apps(value)
  end
end
-------------------------------------------------------------------------------
function next_screen()
  local win = hs.window.focusedWindow()
  local app = win:application()
  local appName = app:name()
  local screen = win:screen()
  local nextScreen = screen:next()
  local currentMode = get_screen_mode(nextScreen)
  win:moveToScreen(nextScreen)
  local layoutMode = get_app_layout(appName, app:bundleID(), currentMode)
  if (layoutMode) then
    set_win_layout(layoutMode, win)
  end
end
-------------------------------------------------------------------------------
function previous_screen()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  win:moveToScreen(screen:previous())
end
-------------------------------------------------------------------------------
function get_current_mode()
  local currentMode = ""
  for key, value in pairs(config.screens) do
    if hs.screen.findByName(value["name"]) ~= nil then
      currentMode = currentMode .. value["key"]
    end
  end

  return currentMode
end
-------------------------------------------------------------------------------
function get_screen_mode(screen)
  for key, value in pairs(config.screens) do
    if (screen:name() == value["name"]) then
      return value["key"]
    end
  end
  return nil
end
-------------------------------------------------------------------------------
function apply_layouts()
  local currentMode = get_current_mode()

  hs.alert.show("🖥  " .. currentMode)

  for _, layout in ipairs(config.layouts) do
    local layoutMode = layout.modes[currentMode]
    if layoutMode ~= nil then
      for _, name in ipairs(layout.names) do
        local app = hs.application.get(name)
        if (app) then
          set_app_layout(name, app, currentMode)
        end
      end
    end
  end

end
-------------------------------------------------------------------------------
function get_locale(appName, bundleID)
  local currentMode = get_current_mode()

  for _, layout in ipairs(config.layouts) do
    local layoutMode = layout.modes[currentMode]
    if layoutMode ~= nil then
      local locale = layoutMode[2]
      for _, name in ipairs(layout.names) do
        if (name == appName or name == bundleID) then
          return locale
        end
      end
    end
  end

  return nil
end
-------------------------------------------------------------------------------
function set_app_locale(appName, app)
  local locale = get_locale(appName, app:bundleID())
  if locale ~= nil then
    hs.keycodes.setLayout(locale)
  end
end
-------------------------------------------------------------------------------
function get_app_layout(appName, bundleID, currentMode)
  currentMode = currentMode or get_current_mode()

  for _, layout in ipairs(config.layouts) do
    local layoutMode = layout.modes[currentMode]
    if layoutMode ~= nil then
      for _, name in ipairs(layout.names) do
        if (name == appName or name == bundleID) then
          return layoutMode
        end
      end
    end
  end

  return nil
end
-------------------------------------------------------------------------------
function set_win_layout(layoutMode, win)
  local rows   = layoutMode[3]
  local cols   = layoutMode[4]
  local row    = layoutMode[5]
  local col    = layoutMode[6]
  local rs     = layoutMode[7]
  local cs     = layoutMode[8]

  if (win:isVisible()) then
    grid(win, rows, cols, row, col, rs, cs)
  end

end
-------------------------------------------------------------------------------
function get_screen_name(key)
  for _, value in pairs(config.screens) do
    if (key == value["key"]) then
      return value["name"]
    end
  end
  return nil
end
-------------------------------------------------------------------------------
function set_app_layout(appName, app)

  local layoutMode = get_app_layout(appName, app:bundleID())
  if (layoutMode) then
    local pos = layoutMode[1]

    if (layoutMode) then
      if (app) then
        local wins = app:allWindows()
        for j, win in ipairs(wins) do
          if (#hs.screen.allScreens() > 1) then
            win:moveToScreen(hs.screen.get(get_screen_name(pos)))
          end
          set_win_layout(layoutMode, win)
        end
      end
    end
  end

end
-------------------------------------------------------------------------------
function hide_all()
  hs.fnutils.each(
  hs.application.runningApplications(),
    function(app)
      if (app:isRunning()) then
        app:hide()
      end
    end
  )
end
-------------------------------------------------------------------------------
function hide_all_except_focused()
  hs.fnutils.each(
  hs.application.runningApplications(),
    function(app)
      if (app:isRunning()) then
        if (app:isFrontmost() == false) then
          app:hide()
        end
      end
    end
  )
end
-------------------------------------------------------------------------------
global_border = nil
global_border_timer = nil
function redraw_border()
  win = hs.window.focusedWindow()
  if win ~= nil then
      top_left = win:topLeft()
      size = win:size()
      if global_border_timer then
        global_border_timer:stop()
      end
      if global_border ~= nil then
          global_border:delete()
      end
      global_border = hs.drawing.rectangle(hs.geometry.rect(top_left['x'], top_left['y'], size['w'], size['h']))
      global_border:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0.4,["alpha"]=0.5})
      global_border:setFill(false)
      global_border:setStrokeWidth(4)
      global_border:show()
      global_border_timer = hs.timer.doAfter(1, function() global_border:delete() global_border=nil end)
  end
end
-------------------------------------------------------------------------------
function on_created_window(win)
  local app = win:application()
  local appName = app:name()
  local layoutMode = get_app_layout(appName, app:bundleID())
  if (layoutMode) then
    if (#app:allWindows() == 1) then
      set_win_layout(layoutMode, win)
    end
  end
end
-------------------------------------------------------------------------------
allwindows = hs.window.filter.new(nil)
allwindows:subscribe(hs.window.filter.windowCreated, on_created_window)
-- allwindows:subscribe(hs.window.filter.windowFocused, function () redraw_border() end)
-- allwindows:subscribe(hs.window.filter.windowMoved, function () redraw_border() end)
-- allwindows:subscribe(hs.window.filter.windowUnfocused, function () redraw_border() end)
-------------------------------------------------------------------------------
mouseCircle = nil
mouseCircleTimer = nil
function mouse_highlight()
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    mousepoint = hs.mouse.getAbsolutePosition()
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0.4,["alpha"]=0.8})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:show()
    mouseCircleTimer = hs.timer.doAfter(1, function() mouseCircle:delete() mouseCircle=nil end)
end
-------------------------------------------------------------------------------
function tunnelblick()
  net = hs.wifi.currentNetwork()

  appName = 'Tunnelblick'

  connection = config.tunnelblick.connection
  username = config.tunnelblick.username
  password = config.tunnelblick.password

  local app = hs.application(appName)
  if (app == nil or app:isRunning() == false) then
    hs.application.launchOrFocus(appName)
    hs.alert.show("☎️")
  else
    if (app:isRunning()) then
      app:kill()
      return
    end
  end

  code, output, descriptor =
  hs.osascript.applescript(
    string.format(
        [[
    tell application "Tunnelblick"
        get configurations
        connect "%s"
    end tell

    tell application "System Events"
    tell process "Tunnelblick"
        set frontmost to true
        tell window 1
            set value of text field 1 to "%s"
            set value of text field 2 to "%s"
            click button "OK"
        end tell
    end tell
    end tell
    ]],
      connection,
      username,
      password
    )
  )
end
-------------------------------------------------------------------------------
function my_ip()
  status, data, headers = hs.http.get(config.myip)
  hs.alert.show("☁️  " .. data)
end
-------------------------------------------------------------------------------
-- NOTE: not trigerred for cmd-tab for hidden apps
-- hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(window, appName)
--   set_locale(appName)
-- end)
-------------------------------------------------------------------------------
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    set_app_locale(appName, appObject)
  end
  if (eventType == hs.application.watcher.launched) then
    hs.timer.doAfter(0.25, function() set_app_layout(appName, appObject) end)
  end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
-------------------------------------------------------------------------------
function clock()
  spoon.AClock.format = "%H:%M:%S"
  spoon.AClock.width = 420
  spoon.AClock.showDuration = 6
  spoon.AClock.textSize = 86
  spoon.AClock.textFont = "Impact"
  spoon.AClock.textColor = {hex="#1891C3"}
  spoon.AClock:toggleShow()
end
-------------------------------------------------------------------------------
function full_screen() grid(nil, 1, 1, 0, 0) end
function center_big() grid(nil, 1, 10, 0, 1, 1, 8) end
function top_right_3_4_small() grid(nil, 3, 4, 0, 3) end
function top_right_3_4_large() grid(nil, 2, 3, 0, 2) end
function bottom_right_3_4_small() grid(nil, 3, 4, 2, 3) end
function bottom_right_3_4_large() grid(nil, 2, 3, 1, 2) end
function top_center_3_4_large() grid(nil, 2, 3, 0, 1) end
function bottom_center_3_4_large() grid(nil, 2, 3, 1, 1) end
function top_left_3_4_small() grid(nil, 3, 4, 0, 0) end
function top_left_3_4_large() grid(nil, 2, 3, 0, 0) end
function bottom_left_3_4_small() grid(nil, 3, 4, 2, 0) end
function bottom_left_3_4_large() grid(nil, 2, 3, 1, 0) end
function left_1_3_mall() grid(nil, 1, 3, 0, 0) end
function left_1_3_large() grid(nil, 1, 3, 0, 0, 1, 2) end
function middle_1_3_small() grid(nil, 1, 3, 0, 1) end
function middle_1_3_large() grid(nil, 1, 6, 0, 1, 1, 4) end
function right_1_3_small() grid(nil, 1, 3, 0, 2) end
function right_1_3_large() grid(nil, 1, 6, 0, 2, 1, 4) end
function left_half() grid(nil, 1, 2, 0, 0) end
function right_half() grid(nil, 1, 2, 0, 1) end
function top_left_2_2() grid(nil, 2, 2, 0, 0) end
function top_right_2_2() grid(nil, 2, 2, 0, 1) end
function bottom_left_2_2() grid(nil, 2, 2, 1, 0) end
function bottom_right_2_2() grid(nil, 2, 2, 1, 1) end
function resize_from_bottom(d) resize(0, 0, 0, d) end
function resize_from_right(d) resize(0, 0, d, 0) end
-------------------------------------------------------------------------------
local function istable(t) return type(t) == 'table' end
-------------------------------------------------------------------------------
local key_maps = {
  [''] = {
    ["return"]  = full_screen,
    ["delete"]  = center_big,
    ["e"]       = top_right_3_4_small,
    ["c"]       = bottom_right_3_4_small,
    ["q"]       = top_left_3_4_small,
    ["z"]       = bottom_left_3_4_small,
    ["a"]       = left_1_3_mall,
    ["s"]       = middle_1_3_small,
    ["d"]       = right_1_3_small,
    [","]       = left_half,
    [";"]       = left_half,
    ["."]       = right_half,
    ["["]       = top_left_2_2,
    ["]"]       = top_right_2_2,
    [";"]       = bottom_left_2_2,
    ["\\"]      = bottom_right_2_2,
    ["o"]       = center,
    ["n"]       = next_screen,
    ["h"]       = hide_all_except_focused,
    ["l"]       = apply_layouts,
    ["y"]       = function() grid(nil, 20, 20,  3, 5,  14, 10) end,
    ["Up"]      = {function() resize_from_bottom(1) end, function() resize_from_bottom(1) end},
    ["Down"]    = {function() resize_from_bottom(-1) end, function() resize_from_bottom(-1) end},
    ["Left"]    = {function() resize_from_right(1) end, function() resize_from_right(1) end},
    ["Right"]   = {function() resize_from_right(-1) end, function() resize_from_right(-1) end},
  },
  ['shift'] = {
    ["e"]       = top_right_3_4_large,
    ["c"]       = bottom_right_3_4_large,
    ["w"]       = top_center_3_4_large,
    ["x"]       = bottom_center_3_4_large,
    ["q"]       = top_left_3_4_large,
    ["z"]       = bottom_left_3_4_large,
    ["a"]       = left_1_3_large,
    ["s"]       = middle_1_3_large,
    ["d"]       = right_1_3_large,
    ["1"]       = function() open_apps(config.applications["web"]) apply_layouts() end,
    ["2"]       = function() open_apps(config.applications["c++"]) apply_layouts() end,
    ["r"]       = close_all_apps,
    ["m"]       = mouse_highlight,
    ["h"]       = hide_all,
    ["t"]       = tunnelblick,
    ["i"]       = my_ip,
    ["o"]       = clock,
    ["Up"]    = {function() spoon.WinWin:stepMove("up") end, function() spoon.WinWin:stepMove("up") end},
    ["Down"]   = {function() spoon.WinWin:stepMove("down") end, function() spoon.WinWin:stepMove("down") end},
    ["Left"]    = {function() spoon.WinWin:stepMove("left") end, function() spoon.WinWin:stepMove("left") end},
    ["Right"]   = {function() spoon.WinWin:stepMove("right") end, function() spoon.WinWin:stepMove("right") end},
  },
}
-------------------------------------------------------------------------------
for ext, maps in pairs(key_maps) do
  for key, func in pairs(maps) do
      if istable(func) then
        hs.hotkey.bind({"cmd", "alt", ext}, key, func[1], nil, func[2])
        prefix.bindMultiple(ext, key, func[1], nil, func[2])
      else
        hs.hotkey.bind({"cmd", "alt", ext}, key, func)
        prefix.bind(ext, key, func)
      end
    end
end
-------------------------------------------------------------------------------
function handl_screen_layout_change()
  apply_layouts()
end
screenWatcher = hs.screen.watcher.new(handl_screen_layout_change)
screenWatcher:start()
-------------------------------------------------------------------------------
local wf = hs.window.filter.new(function(win)
  local fw = hs.window.focusedWindow()
  return (
    win:isStandard() and
    win:application() == fw:application() and
    win:screen() == fw:screen()
  )
end)
-------------------------------------------------------------------------------
window_switcher = hs.window.switcher.new(wf)
window_switcher.ui.textColor = {0.9,0.9,0.9}
window_switcher.ui.fontName = 'Lucida Console'
window_switcher.ui.textSize = 16
window_switcher.ui.highlightColor = {0.8,0.5,0,0.8}
window_switcher.ui.backgroundColor = {0.3,0.3,0.3,1}
window_switcher.ui.onlyActiveApplication = false
window_switcher.ui.showTitles = true
window_switcher.ui.titleBackgroundColor = {0,0,0}
window_switcher.ui.showThumbnails = true
window_switcher.ui.thumbnailSize = 128
window_switcher.ui.showSelectedThumbnail = false
window_switcher.ui.selectedThumbnailSize = 384
window_switcher.ui.showSelectedTitle = true
-------------------------------------------------------------------------------
hs.hotkey.bind('alt','tab',nil,function()window_switcher:next()end)
-------------------------------------------------------------------------------
