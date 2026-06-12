-- Keybindings (migrated from keys.conf)

local mainMod = "SUPER"

-- Programs (were $terminal / $fileManager / $menu in the old config).
-- In Lua each required file is its own scope, so these live here next to the
-- binds that use them.
local terminal    = "alacritty"
local fileManager = "thunar"
local menu        = "wofi --show drun"
local wall        = (os.getenv("HOME") or "") .. "/.config/hypr/scripts/retro-wall"

-- Apps / actions
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exit())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F",      hl.dsp.window.float())
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(wall .. " next"))   -- 下一張桌布
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(wall .. " menu"))   -- 桌布選單
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S",      hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + Z",      hl.dsp.window.fullscreen())
-- hl.bind(mainMod .. " + L",   hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + R",      hl.dsp.layout("swapsplit"))

-- Move focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces (mainMod + [0-9]) and move active window to a workspace
-- (mainMod + SHIFT + [0-9]). key 0 maps to workspace 10.
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize windows with mainMod + LMB and dragging
hl.bind(mainMod .. " + mouse:272",         hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Audio / brightness (repeat + work while locked)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { repeating = true, locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                   { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                   { repeating = true, locked = true })

-- Screenshots / misc keys
hl.bind("XF86SelectiveScreenshot",            hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + XF86SelectiveScreenshot", hl.dsp.exec_cmd("hyprshot -m output -m eDP-1"))
hl.bind("XF86Calculator",                     hl.dsp.exec_cmd("speedcrunch"))

-- Media keys (work while locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screenshot to clipboard
hl.bind("Print",              hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("SUPER + SHIFT + S",  hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
