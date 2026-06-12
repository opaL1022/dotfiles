-- Look & feel (migrated from style.conf)

hl.config({
    general = {
        -- retroism (yorha): visible gaps show the wallpaper, like an old desktop
        gaps_in  = 5,
        gaps_out = 10,

        -- thin 1px window frame
        border_size = 1,

        col = {
            -- yorha palette: dark outline when focused, lighter shadow when not
            active_border   = "rgb(3d3d39)",
            inactive_border = "rgb(baafa1)",
        },

        resize_on_border = true,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        -- retro: hard square corners
        rounding = 0,

        -- no transparency; the crisp border carries the look
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- hard 80s/90s drop shadow (offset down-right, mostly opaque black)
        shadow = {
            enabled      = true,
            range        = 2,
            render_power = 5,
            sharp        = false,
            scale        = 1,
            offset       = { 2, 2 },
            color        = "rgba(000000d9)",
        },

        blur = {
            enabled  = false,
            size     = 1,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        -- retroism: animations fully off — windows just snap into place
        enabled = false,
    },
})

-- Bézier curves
hl.curve("winIn",     { type = "bezier", points = { {0.1, 1.0},  {0.1, 1}    } })
hl.curve("winOut",    { type = "bezier", points = { {0.1, 1.0},  {0.1, 1}    } })
hl.curve("smoothOut", { type = "bezier", points = { {0.5, 0},    {0.99, 0.99} } })
hl.curve("layerOut",  { type = "bezier", points = { {0.23, 1},   {0.32, 1}   } })

-- Animation leaves
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 5, bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 3, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 7, bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 8, bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "workspacesOut",enabled = true, speed = 8, bezier = "winOut",    style = "slide" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 7, bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "layersOut",    enabled = false })

hl.config({
    scrolling = {
        column_width             = 0.8,
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        follow_focus             = true,
        follow_min_visible       = 0.4,
        direction                = "right",
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- ============================================================
-- hyprbars: 每視窗 retro 標題列 (yorha palette)
-- plugin 由 pacman 套件 hyprland-plugin-hyprbars 提供 → /usr/lib/libhyprbars.so
-- ============================================================
hl.plugin.load("/usr/lib/libhyprbars.so")

hl.config({
    plugin = {
        hyprbars = {
            bar_height                 = 24,
            bar_color                  = "rgb(d9caba)",  -- yorha base
            ["col.text"]               = "rgb(3e3d38)",  -- yorha text
            bar_text_size              = 12,
            bar_part_of_window         = true,
            bar_precedence_over_border = true,
            -- NOTE: hyprbars-button 是 keyword handler，目前 lua config 無法設定，
            --       關閉鈕暫缺（用 SUPER+Q 關視窗）；待找到 lua 設 keyword 的方法再加。
        },
    },
})

-- Window rules
hl.window_rule({ match = { class = "firefox" },       opacity = "1" })
hl.window_rule({ match = { class = "discord" },       opacity = "1" })
hl.window_rule({ match = { class = "Brave-browser" }, opacity = "1" })
hl.window_rule({ match = { class = "librewolf" },     opacity = "1" })
hl.window_rule({ match = { class = "rofi" },          animation = "slide" })
