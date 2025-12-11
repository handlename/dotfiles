local WIN_HALF <const> = 1 / 2
local WIN_BIG <const> = 2 / 3
local WIN_SMALL <const> = 1 / 3
local WIN_TORELANCE = 0.02 -- rate
local WIN_SEQUENCE = {
    { from = WIN_HALF,  to = WIN_BIG },
    { from = WIN_BIG,   to = WIN_SMALL },
    { from = WIN_SMALL, to = WIN_HALF }
}

local log = hs.logger.new("init.lua", "info")

-- disable animation
hs.window.animationDuration = 0

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
