// 時間主物件(月亮)—「空 / The Empty Sky」的招牌懸空石。
// 顯示時間 + 日期;點擊 → 電源選單。位置/大小來自當前桌布(lib/wallpaper 的 moon)。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"
import { idle } from "../lib/hypr"
import { current } from "../lib/wallpaper"

export default function TimeStone(gdkmonitor: Gdk.Monitor) {
  const m = current.moon

  const clock = createPoll("", 1000, () =>
    GLib.DateTime.new_now_local().format("%H:%M") ?? "")
  const date = createPoll("", 30_000, () =>
    GLib.DateTime.new_now_local().format("%a · %d %b") ?? "")

  const sz = m.size ?? 340
  const sizeCss = `min-width:${sz}px; min-height:${sz}px;`
  // 字級跟著球大小縮放 → 縮小 size 時文字不會撐爆變橢圓
  const fClock = Math.round(sz * 0.235)
  const fDate = Math.round(sz * 0.055)

  const content = (
    <centerbox class="stone" orientation={Gtk.Orientation.VERTICAL} css={sizeCss}>
      <box $type="center" orientation={Gtk.Orientation.VERTICAL} halign={Gtk.Align.CENTER}>
        <label class="clock" label={clock} halign={Gtk.Align.CENTER} css={`font-size:${fClock}px;`} />
        <label class="date" label={date} halign={Gtk.Align.CENTER} css={`font-size:${fDate}px; margin-top:${Math.round(sz * 0.03)}px;`} />
      </box>
    </centerbox>
  ) as unknown as Gtk.Widget

  // 點擊月亮 → 電源選單
  const click = new Gtk.GestureClick()
  click.connect("pressed", () => app.toggle_window("powermenu"))
  content.add_controller(click)

  return (
    <window
      visible={idle}
      name="time-stone"
      class="TimeStone"
      namespace="empty-sky-time"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={m.anchor}
      marginTop={m.top ?? 0}
      marginBottom={m.bottom ?? 0}
      marginLeft={m.left ?? 0}
      marginRight={m.right ?? 0}
      application={app}
    >
      {content}
    </window>
  )
}
