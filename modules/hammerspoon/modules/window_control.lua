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
    if #hs.screen.allScreens() >= 2 then
        return "main_sub"
    end
    return "main_only"
end

local presets = {
    ["main_only"] = {
        { app = "1Password",   screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 2 / 3, h = 2 / 3 } },
        { app = "Alacritty",   screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 / 2 } },
        { app = "Claude",      screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.8, h = 0.8 } },
        { app = "Obsidian",    screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 / 2 } },
        { app = "Slack",       screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.6, h = 0.6 } },
        { app = "Toggl Track", screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_PX, w = 300, h = 500 } },
        { app = "Zed",         screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 } },
        { app = "Zen Browser", screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 2 / 3 } },
    },
    ["main_sub"] = {
        { app = "1Password",   screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 2 / 3, h = 2 / 3 } },
        { app = "Alacritty",   screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 / 2 } },
        { app = "Claude",      screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.8, h = 0.8 } },
        { app = "Obsidian",    screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 / 2 } },
        { app = "Slack",       screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_RATIO, w = 0.6, h = 0.6 } },
        { app = "Toggl Track", screen = SCREEN_MAIN, position = POS_CENTER, size = { unit = UNIT_PX, w = 300, h = 500 } },
        { app = "Zed",         screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 1 } },
        { app = "Zen Browser", screen = SCREEN_MAIN, position = POS_LEFT,   size = { unit = UNIT_RATIO, w = 2 / 3 } },
    },
}

local function applyPreset()
    local configName = detectDisplayConfig()
    local preset = presets[configName]
    if not preset then return end

    log.i("Applying preset: " .. configName)
    hs.alert.show("Preset: " .. configName)

    for _, entry in ipairs(preset) do
        local app = hs.application.get(entry.app)
        if not app then
            log.d("App not running: " .. entry.app)
        else
            local win = app:mainWindow()
            if not win then
                log.d("No main window: " .. entry.app)
            else
                local screen = getScreen(entry.screen)
                win:moveToScreen(screen)
                local frame = calcFrame(screen:frame(), entry.position, entry.size)
                updateFrame(win, frame)
            end
        end
    end
end

hs.hotkey.bind({ "cmd", "ctrl" }, "R", applyPreset)

-- simple key remap

local keyRemaps = {
    { from = { mod = "ctrl", key = "'" }, to = { mod = "cmd", key = "`" } },              -- Move focus to next window
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
