// SkyBar — 自適應資訊條:只在「有開視窗」時出現(busy)。
// 把散落的大物件收縮成一條細長 bar,glanceable 又不佔工作空間。
// 目前:時間。之後接上 battery/network/mpris 服務會擴充成完整 cluster。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"
import { busy } from "../lib/hypr"

export default function SkyBar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
  const clock = createPoll("", 1000, () =>
    GLib.DateTime.new_now_local().format("%H:%M") ?? "")

  return (
    <window
      visible={busy}
      name="sky-bar"
      class="SkyBar"
      namespace="empty-sky-bar"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox class="bar">
        <box $type="start" />
        <box $type="center" />
        <box $type="end" class="cluster">
          <label class="bar-time" label={clock} />
        </box>
      </centerbox>
    </window>
  )
}
