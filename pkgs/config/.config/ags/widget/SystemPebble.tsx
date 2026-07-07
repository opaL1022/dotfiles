// 系統浮石 —— 電量 + 網路(SSID),小霧面石。只在空桌面(idle)出現。
// 位置來自當前桌布(lib/wallpaper 的 wifi)。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { idle } from "../lib/hypr"
import { batLabel, netLabel } from "../lib/services"
import { current } from "../lib/wallpaper"

export default function SystemPebble(gdkmonitor: Gdk.Monitor) {
  const w = current.wifi

  return (
    <window
      visible={idle}
      name="system-pebble"
      class="SystemPebble"
      namespace="empty-sky-sys"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={w.anchor}
      marginTop={w.top ?? 0}
      marginBottom={w.bottom ?? 0}
      marginLeft={w.left ?? 0}
      marginRight={w.right ?? 0}
      application={app}
    >
      <centerbox class="pebble" orientation={Gtk.Orientation.VERTICAL}>
        <box $type="center" orientation={Gtk.Orientation.VERTICAL} halign={Gtk.Align.CENTER}>
          <label class="peb-bat" label={batLabel} halign={Gtk.Align.CENTER} />
          <label class="peb-net" label={netLabel} halign={Gtk.Align.CENTER} maxWidthChars={9} ellipsize={3} />
        </box>
      </centerbox>
    </window>
  )
}
