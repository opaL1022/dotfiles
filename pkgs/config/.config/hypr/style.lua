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
        -- 保持開啟(全關會讓 GTK popup 選單閃爍)；下方葉子設成極快≈瞬間，保留 retro 感
        enabled = true,
    },
})

-- Bézier curves
hl.curve("snappy", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })

-- Animation leaves — 全部極快(≈瞬間)，動畫系統仍運作以避免 popup 閃爍
hl.animation({ leaf = "windows",     enabled = true, speed = 2, bezier = "snappy", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "snappy" })
hl.animation({ leaf = "fade",        enabled = true, speed = 2, bezier = "snappy" })
hl.animation({ leaf = "workspaces",  enabled = false })   -- 切工作區瞬間,不要動畫
hl.animation({ leaf = "layers",      enabled = true, speed = 2, bezier = "snappy", style = "fade" })

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
-- plugin 改由 hyprpm 管理(不鎖 pacman 更新)：hyprpm add hyprland-plugins
-- hyprland 升級後需跑 `hyprpm update` 重編，否則 .so 版本不符不會載入
-- ============================================================
hl.plugin.load("/var/cache/hyprpm/" .. (os.getenv("USER") or "") .. "/hyprland-plugins/hyprbars.so")

hl.config({
    plugin = {
        hyprbars = {
            bar_height                 = 32,
            bar_color                  = "rgb(d9caba)",  -- yorha base
            ["col.text"]               = "rgb(3e3d38)",  -- yorha text
            bar_text_size              = 14,
            bar_part_of_window         = true,
            bar_precedence_over_border = true,
        },
    },
})

-- Window rules
hl.window_rule({ match = { class = "firefox" },       opacity = "1" })
hl.window_rule({ match = { class = "discord" },       opacity = "1" })
hl.window_rule({ match = { class = "Brave-browser" }, opacity = "1" })
hl.window_rule({ match = { class = "librewolf" },     opacity = "1" })
hl.window_rule({ match = { class = "rofi" },          animation = "slide" })
