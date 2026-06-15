-- Look & feel (migrated from style.conf)

hl.config({
    general = {
        -- retroism (yorha): visible gaps show the wallpaper, like an old desktop
        gaps_in  = 5,
        gaps_out = 10,

        -- 厚漸層框：把邊框往外加粗,作用視窗變成有厚度的 3D 浮雕框(視覺上接近內距)
        -- 想要多厚改這個數字即可(2=細浮雕, 8≈厚框)
        border_size = 8,

        col = {
            -- 邊框 = hyprbars bar_color (yorha base #d9caba)：厚框 + 標題列連成一片，
            -- 整個視窗外圍是均勻 yorha 色帶 → 看起來像每個視窗都有一圈內距框
            active_border   = "rgb(d9caba)",
            inactive_border = "rgb(d9caba)",
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
--    patch + 重編腳本納入 dotfiles: ~/.config/hypr/hyprbars-patch/
--    重編: ~/.config/hypr/hyprbars-patch/rebuild-hyprbars.sh
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
            -- true：邊框繞在 bar 外側(上方)。因邊框=bar 同色 #d9caba,上方邊框會跟 bar
            -- 融成一片(看不出線),且邊框不在 bar 與內容之間 → 下方不會有橫線。
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
