// 系統浮石 — 電量/網路,一顆低調的小霧面石,懸在右下角(散落佈局)。
// 只在空桌面(idle)出現;有視窗時資訊改由 SkyBar 顯示。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { idle } from "../lib/hypr"
import { batLabel, netLabel } from "../lib/services"

export default function SystemPebble(gdkmonitor: Gdk.Monitor) {
  const { BOTTOM, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible={idle}
      name="system-pebble"
      class="SystemPebble"
      namespace="empty-sky-sys"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={BOTTOM | RIGHT}
      marginBottom={150}
      marginRight={230}
      application={app}
    >
      <box
        class="pebble"
        orientation={Gtk.Orientation.VERTICAL}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
      >
        <label class="peb-bat" label={batLabel} />
        <label class="peb-net" label={netLabel} />
      </box>
    </window>
  )
}
