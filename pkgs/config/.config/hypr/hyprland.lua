-- Hyprland configuration (Lua format, Hyprland >= 0.55)
-- Migrated from the old hyprlang (.conf) files. The original .conf files are
-- left untouched as a backup; Hyprland ignores them while this hyprland.lua
-- exists. To revert, delete hyprland.lua / keys.lua / input.lua / style.lua.

----------------
-- MONITORS ----
----------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1200@60",
    position = "0x0",
    scale    = 1,
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})


-----------------------------
-- ENVIRONMENT VARIABLES ----
-----------------------------

hl.env("XCURSOR_THEME", "Colloid-dark-cursors")
hl.env("XCURSOR_SIZE", "26")
hl.env("HYPRCURSOR_THEME", "Colloid-dark-cursors")
hl.env("HYPRCURSOR_SIZE", "26")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
-- surrealism: 強制 GTK app 走深色(prefer-dark 設定在 Wayland/XWayland 不可靠)
-- 搭配 ~/.config/gtk-3.0|4.0/gtk.css 的 Magritte 夜藍 tint
hl.env("GTK_THEME", "Adwaita:dark")


-----------------
-- AUTOSTART ----
-----------------

hl.on("hyprland.start", function()
    -- surrealism: AGS 取代 waybar;AGS 程序化天空取代 hyprpaper/retro-wall
    -- 開機先生成當前時段的天空鎖屏圖,再 hyprlock
    hl.exec_cmd("(" .. os.getenv("HOME") .. "/.config/hypr/scripts/sky-lock-bg; hyprlock) & blueman-applet & hypridle & ags run & waybar")
    -- surrealism 的 GTK/icon:dconf 會蓋過 settings.ini,開機設對(theme-switch 也會設)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark; gsettings set org.gnome.desktop.interface gtk-theme Adwaita; gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("fcitx5 & /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
    -- 拉起 graphical-session.target,否則 xdg-desktop-portal(Requisite=graphical-session.target)
    -- 起不來 → Vesktop/螢幕分享(ScreenCast portal)無反應。target 定義在
    -- ~/.config/systemd/user/hyprland-session.target(BindsTo graphical-session.target)
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)


-------------------
-- PERMISSIONS ----
-------------------

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


------------------------------
-- WINDOWS AND WORKSPACES ----
------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})


-------------
-- SOURCES --
-------------

require("keys")
require("input")
require("style")
