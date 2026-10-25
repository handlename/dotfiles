local WIN_HALF <const> = 1 / 2
local WIN_BIG <const> = 2 / 3
local WIN_SMALL <const> = 1 / 3
local WIN_TORELANCE = 0.02 -- rate
local WIN_SEQUENCE = {
    { from = WIN_HALF,  to = WIN_BIG },
    { from = WIN_BIG,   to = WIN_SMALL },
    { from = WIN_SMALL, to = WIN_HALF }
}

-- screen
local SCREEN_MAIN <const> = "main"
local SCREEN_SUB <const> = "sub"

-- position
local POS_LEFT <const> = "left"
local POS_RIGHT <const> = "right"
local POS_CENTER <const> = "center"

-- size unit
local UNIT_RATIO <const> = "ratio"
local UNIT_PX <const> = "px"

local SUB_WINDOW_OFFSET_DEFAULT <const> = 28 -- titlebar height (px)

local log = hs.logger.new("init.lua", "info")

-- disable animation
hs.window.animationDuration = 0

-- utils

local function windowMaxFrame(win)
    local screen = win:screen()
    return screen:frame()
end

local function windowRatio(win)
    local max = windowMaxFrame(win)
    local f = win:frame()
    return {
        x = (f.x - max.x) / max.w,
        y = (f.y - max.y) / max.h,
        w = f.w / max.w,
        h = f.h / max.h
    }
end

local function updateFrame(win, frame)
    local f = win:frame()
    f.x = frame.x
    f.w = frame.w
    f.y = frame.y
    f.h = frame.h

    win:setFrame(f)
end

local function calcFrame(screenFrame, position, size)
    local w, h
    if size.unit == UNIT_PX then
        w = size.w
        h = size.h or screenFrame.h
    else
        w = screenFrame.w * size.w
        h = screenFrame.h * (size.h or 1)
    end

    local x
    if position == POS_LEFT then
        x = screenFrame.x
    elseif position == POS_RIGHT then
        x = screenFrame.x + screenFrame.w - w
    else -- POS_CENTER
        x = screenFrame.x + (screenFrame.w - w) / 2
    end
    local y = screenFrame.y + (screenFrame.h - h) / 2

    return { x = x, y = y, w = w, h = h }
end

local function calcSubWindowFrame(mainFrame, subWindows)
    local offset = subWindows.offset or SUB_WINDOW_OFFSET_DEFAULT
    return {
        x = mainFrame.x + offset,
        y = mainFrame.y + offset,
        w = subWindows.width,
        h = mainFrame.h - offset,
    }
end

-- Titles cannot tell main from sub (a channel opened in a new window looks
-- like the main one), so the oldest window, i.e. the smallest id, is the main.
-- A minimized main returns nil so that a sub is never mistaken for it.
local function partitionWindows(app)
    local main
    local windows = {}
    for _, w in ipairs(app:allWindows()) do
        if w:isStandard() then
            table.insert(windows, w)
            if not main or w:id() < main:id() then
                main = w
            end
        end
    end
    if not main or main:isMinimized() then
        return nil, {}
    end

    local subs = {}
    for _, w in ipairs(windows) do
        if w:id() ~= main:id() and not w:isMinimized() then
            table.insert(subs, w)
        end
    end
    return main, subs
end

local function getScreen(screenType)
    local primary = hs.screen.primaryScreen()
    if screenType == SCREEN_MAIN then
        return primary
    end
    for _, s in ipairs(hs.screen.allScreens()) do
        if s ~= primary then
            return s
        end
    end
    log.d("No sub screen found, falling back to primary")
    return primary
end

local function detectDisplayConfig()
    local screens = hs.screen.allScreens()
    if #screens < 2 then return "main_only" end

    local primary = hs.screen.primaryScreen()
    for _, s in ipairs(screens) do
        if s ~= primary then
            local _, y = s:position()
            if y ~= 0 then
                return "main_sub_vertical"
            else
                return "main_sub_horizontal"
            end
        end
    end

    return "main_only"
end

local presets = {
    ["main_only"] = {
        { app = "1Password",   screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_PX, w = 1200, h = 1000 } },
        { app = "Claude",      screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.8, h = 0.8 } },
        { app = "Obsidian",    screen = SCREEN_MAIN, position = POS_RIGHT,  size = { unit = UNIT_RATIO, w = 1 } },
        { app = "Slack",       screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_PX, w = 1400, h = 1000 }, subWindows = { width = 600 } },
        { app = "Toggl Track", screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_PX, w = 300, h = 600 } },
        { app = "Zed",         screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 } },
        { app = "Zen",         screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 2 / 3 } },
    },
    ["main_sub_horizontal"] = {
        { app = "1Password",   screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_PX, w = 1200, h = 1000 } },
        { app = "Claude",      screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.9, h = 0.9 } },
        { app = "Obsidian",    screen = SCREEN_MAIN, position = POS_RIGHT,  size = { unit = UNIT_RATIO, w = 2 / 3 } },
        { app = "Slack",       screen = SCREEN_SUB,  position = POS_CENTER, size = { unit = UNIT_PX, w = 1580, h = 950 }, subWindows = { width = 600 } },
        { app = "Toggl Track", screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_PX, w = 300, h = 600 } },
        { app = "Zed",         screen = SCREEN_MAIN, position = POS_LEFT,  size = { unit = UNIT_RATIO, w = 2 / 3 } },
        { app = "Zen",         screen = SCREEN_MAIN, position = POS_RIGHT,   size = { unit = UNIT_RATIO, w = 1 / 2 } },
    },
    ["main_sub_vertical"] = {
        { app = "1Password",   screen = SCREEN_SUB,  position = POS_CENTER, size = { unit = UNIT_PX, w = 1200, h = 1000 } },
        { app = "Claude",      screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.9, h = 0.9 } },
        { app = "Obsidian",    screen = SCREEN_SUB,  position = POS_RIGHT,  size = { unit = UNIT_RATIO, w = 1 } },
        { app = "Slack",       screen = SCREEN_SUB,  position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.8, h = 0.8 }, subWindows = { width = 600 } },
        { app = "Toggl Track", screen = SCREEN_SUB,  position = POS_CENTER, size = { unit = UNIT_PX, w = 300, h = 600 } },
        { app = "Zed",         screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 } },
        { app = "Zen",         screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 2 / 3 } },
    },
}

local function applyPreset()
    local configName = detectDisplayConfig()
    local preset = presets[configName]
    if not preset then return end

    log.i("Applying preset: " .. configName)
    hs.alert.show("Preset: " .. configName)

    for _, entry in ipairs(preset) do
        -- hs.application.get() falls back to a window title search when no app
        -- name matches, and can return an hs.window. find() with exact=true
        -- stays on app names only.
        local app = (hs.application.find(entry.app, true))
        if not app then
            log.d("App not running: " .. entry.app)
        else
            -- mainWindow() returns the focused window, so apps with sub windows
            -- identify the main one by window id instead.
            local win, subs
            if entry.subWindows then
                win, subs = partitionWindows(app)
            else
                win = app:mainWindow()
            end

            if not win then
                if entry.subWindows then
                    log.i("Main window not identified: " .. entry.app)
                else
                    log.d("No main window: " .. entry.app)
                end
            else
                local screen = getScreen(entry.screen)
                win:moveToScreen(screen)
                local frame = calcFrame(screen:frame(), entry.position, entry.size)
                updateFrame(win, frame)

                if subs then
                    local mainFrame = win:frame()
                    for _, w in ipairs(subs) do
                        updateFrame(w, calcSubWindowFrame(mainFrame, entry.subWindows))
                    end
                end
            end
        end
    end
end

hs.hotkey.bind({ "cmd", "ctrl" }, "R", applyPreset)

-- simple key remap

local keyRemaps = {
    -- Move focus to next window:
    -- Must change system default shortcut "Cmd+@" to "Ctrl+`", because connflict with shottr's one.
    { from = { mod = "ctrl", key = "'" }, to = { mod = "ctrl", key = "`" } },
    { from = { mod = "ctrl", key = "," }, to = { mod = { "cmd", "shift" }, key = "[" } }, -- Next tab
    { from = { mod = "ctrl", key = "." }, to = { mod = { "cmd", "shift" }, key = "]" } }, -- Previous tab
}

for _, map in ipairs(keyRemaps) do
    hs.hotkey.bind(map.from.mod, map.from.key, function()
        hs.eventtap.keyStroke(map.to.mod, map.to.key)
    end)
end

local keyConfigs = {
    {
        bind = { mod = { "cmd", "shift", "ctrl" }, key = "Up" },
        action = function()
            local win = hs.window.focusedWindow()
            win:maximize()
        end
    },
    {
        bind = { mod = { "cmd", "shift", "ctrl" }, key = "Down" },
        action = function()
            local win = hs.window.focusedWindow()
            win:centerOnScreen()
        end
    },
    {
        bind = { mod = { "shift", "ctrl" }, key = "Right" },
        action = function()
            local win = hs.window.focusedWindow()
            win:moveToScreen(win:screen():next())
        end
    },
    {
        bind = { mod = { "shift", "ctrl" }, key = "Left" },
        action = function()
            local win = hs.window.focusedWindow()
            win:moveToScreen(win:screen():previous())
        end
    },
    {
        bind = { mod = { "cmd", "shift", "ctrl" }, key = "f12" },
        action = function()
            local win = hs.window.focusedWindow()
            local max = windowMaxFrame(win)
            updateFrame(win, calcFrame(max, POS_CENTER, { unit = UNIT_RATIO, w = 0.8, h = 0.8 }))
        end
    },
    {
        bind = { mod = { "cmd", "shift", "ctrl" }, key = "f11" },
        action = function()
            local win = hs.window.focusedWindow()
            local max = windowMaxFrame(win)
            updateFrame(win, calcFrame(max, POS_CENTER, { unit = UNIT_RATIO, w = 0.6, h = 0.6 }))
        end
    },
}

for _, config in pairs(keyConfigs) do
    hs.hotkey.bind(config.bind.mod, config.bind.key, config.action)
end

-- window resize (Right/Left)

local windowConfigs = {
    {
        key = "Right",
        conditions = {
            function(state, ratio) return math.abs(ratio.w - state.from) <= WIN_TORELANCE end,
            function(state, ratio) return math.abs(ratio.x - (1 - state.from)) <= WIN_TORELANCE end,
        },
        result = function(state, max)
            return {
                x = max.x + (max.w * (1 - state.to)),
                y = max.y,
                w = max.w * state.to,
                h = max.h,
            }
        end,
    },
    {
        key = "Left",
        conditions = {
            function(state, ratio) return math.abs(ratio.w - state.from) < WIN_TORELANCE end,
            function(_, ratio) return math.abs(ratio.x) < WIN_TORELANCE end,
        },
        result = function(state, max)
            return {
                x = max.x,
                y = max.y,
                w = max.w * state.to,
                h = max.h,
            }
        end,
    },
}

local function satisfiesAll(state, max, conditions)
    for _, cond in ipairs(conditions) do
        if not cond(state, max) then
            return false
        end
    end

    return true
end

for _, config in ipairs(windowConfigs) do
    hs.hotkey.bind({ "cmd", "shift", "ctrl" }, config.key, function()
        local win = hs.window.focusedWindow()
        local max = windowMaxFrame(win)
        local ratio = windowRatio(win)

        local after = config.result({ from = WIN_HALF, to = WIN_HALF }, max)

        for _, state in ipairs(WIN_SEQUENCE) do
            log.d("state: " .. hs.inspect(state))
            if satisfiesAll(state, ratio, config.conditions) then
                log.d("matched")
                after = config.result(state, max)
                break
            end
        end

        log.d("after: " .. hs.inspect(after))
        updateFrame(win, after)
    end)
end
