local apps = {
    { key = "G", id = "md.obsidian" },
    { key = "K", id = "com.toggl.daneel" },
    { key = "R", id = "com.kapeli.dashdoc" },

    { key = "H", id = "dev.zed.Zed" },
    { key = "T", id = "org.alacritty" },
    { key = "N", id = "app.zen-browser.zen" },

    { key = "M", id = "com.anthropic.claudefordesktop" },
    { key = "W", id = "com.1password.1password" },
    { key = "V", id = "com.tinyspeck.slackmacgap" },
}

for _, item in ipairs(apps) do
    hs.hotkey.bind({ "ctrl", "shift", "cmd" }, item.key, function()
        hs.application.launchOrFocusByBundleID(item.id)
    end)
end
