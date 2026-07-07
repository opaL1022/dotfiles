// 程序化天空 —「空 / The Empty Sky」的底層天空(取代桌布)
// 全螢幕,放到真正的 BACKGROUND 層(在一般視窗之下)。
//
// ★ 兩種模式(改 WALLPAPER 一行即可):
//   WALLPAPER = ""            → 程序化天空:漸層色隨真實時間內插(夜/晨/午/暮)
//   WALLPAPER = "/path/x.jpg" → 用你的桌布圖,並在上面疊一層半透明時段色調
//                               (照片也會隨白天/夜晚偏暖偏冷,保留《光之帝國》概念)
//
// ⚠ 宣告式 layer={} / setup prop 在此版無效,且 set_layer 必須在 map 之前呼叫。
//   作法:visible={false} 建立 → set_layer(BACKGROUND) → set_visible(true)。
import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"

// 桌布圖(留空 = 程序化天空);WALLPAPER_TINT=true 會在圖上疊半透明時段色調(晝夜漂移),
// 對本身已有強烈天空/光線的圖建議關掉,乾淨顯示原圖。
const WALLPAPER = GLib.get_home_dir() + "/Pictures/wallpapers/surrealism/moonlit-courtyard.png"
const WALLPAPER_TINT = false

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
const rgba = ([r, g, b]: RGB, a: number) => `rgba(${r},${g},${b},${a})`

// 當前時刻的三段天色
function timeColors(): [RGB, RGB, RGB] {
  const now = GLib.DateTime.new_now_local()
  const h = now.get_hour() + now.get_minute() / 60
  let i = 0
  while (i < ANCHORS.length - 1 && h >= ANCHORS[i + 1].h) i++
  const a = ANCHORS[i], b = ANCHORS[Math.min(i + 1, ANCHORS.length - 1)]
  const t = (h - a.h) / ((b.h - a.h) || 1)
  return [
    lerpRGB(a.sky[0], b.sky[0], t),
    lerpRGB(a.sky[1], b.sky[1], t),
    lerpRGB(a.sky[2], b.sky[2], t),
  ]
}

function skyCss(): string {
  const [top, mid, bot] = timeColors()
  // 桌布圖存在才用(圖在 repo 外 ~/Pictures,缺檔就 fallback 程序化天空,不會變黑)
  if (WALLPAPER && GLib.file_test(WALLPAPER, GLib.FileTest.EXISTS)) {
    const img = `url("file://${WALLPAPER}")`
    if (WALLPAPER_TINT) {
      // 照片 + 半透明時段色調(照片隨晝夜漂移)
      const tint = `linear-gradient(to bottom, ${rgba(top, 0.28)} 0%, ${rgba(mid, 0.12)} 55%, ${rgba(bot, 0.30)} 100%)`
      return `background-image: ${tint}, ${img}; background-size: cover; background-position: center;`
    }
    return `background-image: ${img}; background-size: cover; background-position: center;`
  }
  // 程序化天空(不透明漸層)
  return `background-image: linear-gradient(to bottom, ${rgb(top)} 0%, ${rgb(mid)} 55%, ${rgb(bot)} 100%);`
}

export default function SkyBackground(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  const css = createPoll(skyCss(), 60_000, () => skyCss())

  // 先建成隱藏 → 設 layer(必須在 map 之前)→ 再 show
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
