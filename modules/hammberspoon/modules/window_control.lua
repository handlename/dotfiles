local WIN_HALF <const> = 1 / 2
local WIN_BIG <const> = 2 / 3
local WIN_SMALL <const> = 1 / 3
local WIN_TORELANCE = 0.02 -- rate
local WIN_SEQUENCE = {
    { from = WIN_HALF,  to = WIN_BIG },
    { from = WIN_BIG,   to = WIN_SMALL },
    { from = WIN_SMALL, to = WIN_HALF }
}

local log = hs.logger.new("init.lua", "debug")

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
                h = max.h
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
                x = 0,
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
        w = f.w / max.w,
        x = (f.x - max.x) / max.w,
    }
end

local function updateFrame(win, frame)
    local f = win:frame()
    f.x = frame.x
    f.w = frame.w
    f.y = frame.y
    f.h = frame.h

    local origDuration = hs.window.animationDuration
    hs.window.animationDuration = 0
    win:setFrame(f)
    hs.window.animationDuration = origDuration
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
