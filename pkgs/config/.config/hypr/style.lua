-- Look & feel (migrated from style.conf)

hl.config({
    general = {
        -- retroism (yorha): visible gaps show the wallpaper, like an old desktop
        gaps_in  = 5,
        gaps_out = 10,

        -- 2px frame so the Platinum bevel reads (1px is too thin to emboss)
        border_size = 2,

        col = {
            -- Platinum 浮雕邊：亮邊在上/左、暗邊在下/右(斜角漸層)，視窗(含 hyprbars
            -- 標題列，因 bar_part_of_window=true)整個看起來像凸起的舊系統視窗
            active_border   = { colors = { "rgb(f0e2d3)", "rgb(8a7c66)" }, angle = 135 },
            -- 非作用視窗：平淡退到背景(無浮雕)，做出 Platinum「前景視窗才立體」的效果
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
-- ** 自編 patch 版 **：原版 hyprbars 無法在標題兩側畫橫條(pinstripe)，
--    所以 fork 改了 barDeco.cpp(標題左右畫等距水平線，僅作用視窗)。
--    source: ~/.local/src/hyprland-plugins (對應 Hyprland 0.55.4 的 pin commit 3aa21f2)
--    重編: ~/.local/src/hyprland-plugins/rebuild-hyprbars.sh
-- ** Hyprland 升級後 .so 會 ABI 不符 → 必須重跑 rebuild 腳本(不是 hyprpm update) **
-- ============================================================
hl.plugin.load((os.getenv("HOME") or "") .. "/.local/share/hyprbars/hyprbars.so")

hl.config({
    plugin = {
        hyprbars = {
            bar_height                 = 32,
            bar_color                  = "rgb(d9caba)",  -- yorha base
            ["col.text"]               = "rgb(3e3d38)",  -- yorha text
            bar_text_size              = 14,
            bar_text_align             = "center",       -- pinstripe 對稱所需
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
