// 媒體掛畫 — 放音樂才從天空降下的裱框物件(超 Magritte)。
// 只在「空桌面(idle) 且 有在播放」時出現;沒放時消失 → 強化空曠。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createComputed } from "ags"
import { idle } from "../lib/hypr"
import { mediaPlaying, mediaTitle, mediaCover } from "../lib/services"

export default function MediaPainting(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor
  const show = createComputed([idle, mediaPlaying], (i, p) => i && p)

  return (
    <window
      visible={show}
      name="media-painting"
      class="MediaPainting"
      namespace="empty-sky-media"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={TOP | RIGHT}
      marginTop={230}
      marginRight={170}
      application={app}
    >
      <box class="painting" orientation={Gtk.Orientation.VERTICAL} halign={Gtk.Align.CENTER}>
        <box class="frame">
          <image class="art" file={mediaCover} />
        </box>
        <label class="paint-title" label={mediaTitle} maxWidthChars={16} ellipsize={3} />
      </box>
    </window>
  )
}
