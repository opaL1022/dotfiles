// 時間主物件 —「空 / The Empty Sky」的招牌懸空石
// 一顆漂在天空左上、偏側不置中的石/月,上面刻著時間(尺度悖論:它是畫面最大的物件)。
// layer BOTTOM = 坐在桌布之上、一般視窗之下;Exclusivity.IGNORE = 不佔版面、純漂浮。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"
import { idle } from "../lib/hypr"

export default function TimeStone(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT } = Astal.WindowAnchor

  // 用 GLib 格式化,避免把格式字串丟給 shell 拆字(空格 / · 會爆)
  const clock = createPoll("", 1000, () =>
    GLib.DateTime.new_now_local().format("%H:%M") ?? "")
  const date = createPoll("", 30_000, () =>
    GLib.DateTime.new_now_local().format("%a · %d %b") ?? "")

  return (
    <window
      visible={idle}
      name="time-stone"
      class="TimeStone"
      namespace="empty-sky-time"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={TOP | LEFT}
      marginTop={150}
      marginLeft={340}
      application={app}
    >
      <centerbox class="stone" orientation={Gtk.Orientation.VERTICAL}>
        <box
          $type="center"
          orientation={Gtk.Orientation.VERTICAL}
          halign={Gtk.Align.CENTER}
        >
          <label class="clock" label={clock} halign={Gtk.Align.CENTER} />
          <label class="date" label={date} halign={Gtk.Align.CENTER} />
        </box>
      </centerbox>
    </window>
  )
}
