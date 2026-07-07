// 程序化天空 —「空 / The Empty Sky」的底層天空(取代桌布)
// 全螢幕,放到真正的 BACKGROUND 層(在一般視窗之下),漸層色依「真實時間」平滑內插:
//   夜 → 晨 → 午 → 暮 → 夜。所有工作區同一片天空;天色隨時鐘走(《光之帝國》命題)。
// ⚠ 宣告式 layer={} prop 在此版被無視(gtk4-layer-shell 預設 TOP → 蓋住視窗);
//   也沒有 setup prop。作法:接住 JSX 回傳的 AstalWindow 實例,呼叫 set_layer()。
import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"

type RGB = [number, number, number]

// 時段錨點:小時 → [天頂, 中段, 地平] 三色。暫定 Magritte sky 值,Phase 5 再細修。
const ANCHORS: { h: number; sky: [RGB, RGB, RGB] }[] = [
  { h: 0,  sky: [[18, 26, 40],    [27, 35, 48],    [40, 52, 66]] },     // 夜
  { h: 6,  sky: [[92, 110, 150],  [180, 150, 150], [232, 220, 200]] },  // 晨
  { h: 12, sky: [[110, 160, 205], [150, 190, 225], [214, 225, 220]] },  // 午
  { h: 18, sky: [[60, 70, 110],   [150, 90, 90],   [232, 150, 110]] },  // 暮
  { h: 24, sky: [[18, 26, 40],    [27, 35, 48],    [40, 52, 66]] },     // 夜(接回)
]

const lerp = (a: number, b: number, t: number) => a + (b - a) * t
const lerpRGB = (a: RGB, b: RGB, t: number): RGB =>
  [Math.round(lerp(a[0], b[0], t)), Math.round(lerp(a[1], b[1], t)), Math.round(lerp(a[2], b[2], t))]
const rgb = ([r, g, b]: RGB) => `rgb(${r},${g},${b})`

function skyGradient(): string {
  const now = GLib.DateTime.new_now_local()
  const h = now.get_hour() + now.get_minute() / 60
  let i = 0
  while (i < ANCHORS.length - 1 && h >= ANCHORS[i + 1].h) i++
  const a = ANCHORS[i], b = ANCHORS[Math.min(i + 1, ANCHORS.length - 1)]
  const t = (h - a.h) / ((b.h - a.h) || 1)
  const top = lerpRGB(a.sky[0], b.sky[0], t)
  const mid = lerpRGB(a.sky[1], b.sky[1], t)
  const bot = lerpRGB(a.sky[2], b.sky[2], t)
  return `background-image: linear-gradient(to bottom, ${rgb(top)} 0%, ${rgb(mid)} 55%, ${rgb(bot)} 100%);`
}

export default function SkyBackground(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  const css = createPoll(skyGradient(), 60_000, () => skyGradient())

  // 先建成隱藏 → 設 layer(必須在 map 之前)→ 再 show,否則 gtk4-layer-shell 已 map 就改不動
  const win = (
    <window
      visible={false}
      name="sky"
      class="Sky"
      namespace="empty-sky-bg"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      application={app}
    >
      <box class="sky-fill" hexpand vexpand css={css} />
    </window>
  ) as Astal.Window

  win.set_layer(Astal.Layer.BACKGROUND)   // 墊到桌布層(在所有視窗之下)
  win.set_visible(true)
  return win
}
