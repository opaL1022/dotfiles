-- Look & feel (migrated from style.conf)

hl.config({
    general = {
        gaps_in  = 1,
        gaps_out = 4,

        border_size = 2,

        col = {
            active_border   = "rgba(203,158,114,0.7)",
            -- old value had alpha 255 (out of the 0-1 decimal range); 1.0 = fully opaque
            inactive_border = { colors = { "rgba(203,158,114,0.7)", "rgba(42,41,47,1.0)" }, angle = 90 },
        },

        resize_on_border = false,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 5,

        active_opacity   = 1.0,
        inactive_opacity = 0.85,

        shadow = {
            enabled      = false,
            range        = 2,
            render_power = 2,
            color        = "rgba(00000000)",
        },

        blur = {
            enabled  = false,
            size     = 1,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
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

-- Window rules
hl.window_rule({ match = { class = "firefox" },       opacity = "1" })
hl.window_rule({ match = { class = "discord" },       opacity = "1" })
hl.window_rule({ match = { class = "Brave-browser" }, opacity = "1" })
hl.window_rule({ match = { class = "librewolf" },     opacity = "1" })
hl.window_rule({ match = { class = "rofi" },          animation = "slide" })
