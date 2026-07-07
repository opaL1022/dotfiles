// wifi 球 —— 網路(SSID)小霧面石,懸在右下角。
// 只在空桌面(idle)出現;點擊 → nm-connection-editor。(電量已移到月亮上。)
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { idle } from "../lib/hypr"
import { netLabel } from "../lib/services"

export default function SystemPebble(gdkmonitor: Gdk.Monitor) {
  const { BOTTOM, RIGHT } = Astal.WindowAnchor

  const content = (
    <centerbox class="pebble" orientation={Gtk.Orientation.VERTICAL}>
      <box $type="center" orientation={Gtk.Orientation.VERTICAL} halign={Gtk.Align.CENTER}>
        <label
          class="peb-net"
          label={netLabel}
          halign={Gtk.Align.CENTER}
          maxWidthChars={9}
          ellipsize={3}
        />
      </box>
    </centerbox>
  ) as unknown as Gtk.Widget

  const click = new Gtk.GestureClick()
  click.connect("pressed", () => execAsync("nm-connection-editor"))
  content.add_controller(click)

  return (
    <window
      visible={idle}
      name="system-pebble"
      class="SystemPebble"
      namespace="empty-sky-sys"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={BOTTOM | RIGHT}
      marginBottom={150}
      marginRight={230}
      application={app}
    >
      {content}
    </window>
  )
}
