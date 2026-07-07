// PowerMenu —— 點擊月亮召喚的電源選單(從天空降下,置中浮動)。
// Lock / Logout / Reboot / Shutdown;Esc 關。Nerd Font 圖示用 \u escape。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"

const ACTIONS = [
  { icon: "", label: "Lock",     cmd: "loginctl lock-session" }, // fa-lock
  { icon: "", label: "Logout",   cmd: "hyprctl dispatch exit" }, // fa-sign-out
  { icon: "", label: "Reboot",   cmd: "systemctl reboot" },      // fa-refresh
  { icon: "", label: "Shutdown", cmd: "systemctl poweroff" },    // fa-power-off
]

export default function PowerMenu(gdkmonitor: Gdk.Monitor) {
  function hide() {
    app.get_window("powermenu")?.set_visible(false)
  }

  const win = (
    <window
      visible={false}
      name="powermenu"
      class="PowerMenu"
      namespace="empty-sky-power"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.EXCLUSIVE}
      application={app}
    >
      <box class="power-box" orientation={Gtk.Orientation.HORIZONTAL} spacing={14}>
        {ACTIONS.map((a) => (
          <button class="power-btn" onClicked={() => { execAsync(a.cmd); hide() }}>
            <box orientation={Gtk.Orientation.VERTICAL} spacing={8} halign={Gtk.Align.CENTER}>
              <label class="power-icon" label={a.icon} />
              <label class="power-label" label={a.label} />
            </box>
          </button>
        ))}
      </box>
    </window>
  ) as Astal.Window

  const kc = new Gtk.EventControllerKey()
  kc.connect("key-pressed", (_c, kv: number) => {
    if (kv === Gdk.KEY_Escape) { hide(); return true }
    return false
  })
  win.add_controller(kc)

  return win
}
