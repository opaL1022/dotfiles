-- Look & feel — surrealism theme「空 / The Empty Sky」
-- Magritte 懸空系:視窗=漂在天空裡的浮石(圓角 + 懸浮陰影 + near-frameless),
-- 版面用 Hyprland 0.55 內建 scrolling layout(PaperWM 式無限橫帶)=「可漫遊的連續天空」。
-- 設計索引: ~/Documents/notes/Arch/retro_env/hyprland_surrealism.md
-- ⚠ 配色為暫定 Magritte sky 值,之後 Phase 5 再細修。

hl.config({
    general = {
        -- 留白靠 scrolling 的 column_width 置中(兩側自動留天空),gaps 只需輕微
        gaps_in  = 6,
        gaps_out = 18,

        -- near-frameless:視窗是「物件」不是「面板」→ 細邊,不再是 retroism 的厚框
        border_size = 1,

        col = {
            -- 暫定 Magritte cloud 色:作用窗雲白邊(低調襯出物件),非作用窗更透
            active_border   = "rgba(f2f5f7cc)",
            inactive_border = "rgba(d7dfe655)",
        },

        resize_on_border = true,
        allow_tearing    = false,

        -- ★ 無限平鋪:內建 scrolling(非 plugin),tape 往右長,捲動=平移天空
        layout = "scrolling",
    },

    decoration = {
        -- 圓角物件感(石頭/蘋果),反轉 retroism 的方角
        rounding = 14,

        -- route A 浮石:預設不透明;route B 天空之窗(終端半透)之後 Phase 4 用 window_rule 開
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- ★ 懸浮陰影(招牌):大 offset 往下 + 柔化 range → 視窗像懸空的浮石,影子落在下方
        shadow = {
            enabled      = true,
            range        = 34,
            render_power = 3,
            sharp        = false,
            scale        = 1,
            offset       = { 0, 22 },       -- 往正下方脫開 → levitation
            color        = "rgba(1b233066)", -- 暫定 night 色柔影
        },

        blur = {
            -- route B 天空之窗會用到;先開好、size 保守(終端可讀性)
            enabled  = true,
            size     = 4,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Bézier — 平滑 ease-out,做「從天空緩緩降下 / 升回」的漂浮感(非 retroism 的瞬間)
hl.curve("float",   { type = "bezier", points = { {0.16, 1.0}, {0.3, 1.0} } })
hl.curve("drift",   { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })

-- 動畫葉子:視窗緩緩降下/升回(slide + 慢速 float)、工作區橫向 slide(=天空平移)
-- 用已知合法的 style,避免 reload 出 config error overlay;細緻的方向感 Phase 4 再調。
hl.animation({ leaf = "windows",     enabled = true, speed = 6, bezier = "float", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 7, bezier = "float" })
hl.animation({ leaf = "fade",        enabled = true, speed = 6, bezier = "float" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6, bezier = "drift", style = "slide" })
hl.animation({ leaf = "layers",      enabled = true, speed = 6, bezier = "float", style = "fade" })

hl.config({
    -- ★ scrolling layout 調校:column_width 半寬 + 置中 → 聚焦窗兩側自動留天空
    scrolling = {
        column_width             = 0.6,   -- 半寬偏多,浮物泡在天空裡(可再調)
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,     -- 置中聚焦
        follow_focus             = true,
        follow_min_visible       = 0.4,
        direction                = "right",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- ============================================================
-- hyprbars: 退役。
-- surrealism 走 near-frameless、無標題列(視窗是浮物不是有框面板),
-- 因此不再 hl.plugin.load hyprbars.so、不設 plugin.hyprbars。
-- (retroism 的 pinstripe fork 基建仍在 ~/.config/hypr/hyprbars-patch/,
--  切回 retroism 分支才會重新載入。)
-- ============================================================

-- Window rules — route A 一律不透明(浮石);route B 天空之窗留待 Phase 4
hl.window_rule({ match = { class = "firefox" },       opacity = "1" })
hl.window_rule({ match = { class = "discord" },       opacity = "1" })
hl.window_rule({ match = { class = "Brave-browser" }, opacity = "1" })
hl.window_rule({ match = { class = "librewolf" },     opacity = "1" })
