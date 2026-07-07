// surrealism「空 / The Empty Sky」— AGS 環境物件群 entry
// 自適應:空桌面(idle)散落大物件;有視窗(busy)收縮成 SkyBar 細條。
import app from "ags/gtk4/app"
import { Astal } from "ags/gtk4"
import style from "./style.css"
import SkyBackground from "./widget/SkyBackground"
import TimeStone from "./widget/TimeStone"
import SystemPebble from "./widget/SystemPebble"
import MediaPainting from "./widget/MediaPainting"
import DecoStone from "./widget/DecoStone"
import SkyBar from "./widget/SkyBar"
import { cpuLabel, ramLabel, volumeLabel } from "./lib/services"

app.start({
  css: style,
  main() {
    const A = Astal.WindowAnchor
    const monitors = app.get_monitors()
    monitors.map(SkyBackground)    // 底層天空/桌布
    monitors.map(TimeStone)        // idle:時間主物件(左上)
    monitors.map(SystemPebble)     // idle:系統浮石(右下)
    monitors.map(MediaPainting)    // idle+播放:媒體掛畫(右中)
    // idle:對齊桌布建築的資訊球體(拱門=CPU/RAM、圓池=音量)
    monitors.map((m) => DecoStone(m, { key: "arch", anchor: A.TOP | A.RIGHT, marginTop: 597, marginRight: 454, size: 150, label: cpuLabel, sublabel: ramLabel }))
    monitors.map((m) => DecoStone(m, { key: "pool", anchor: A.BOTTOM | A.LEFT, marginBottom: 235, marginLeft: 630, size: 130, label: volumeLabel }))
    monitors.map(SkyBar)           // busy:細長資訊條
  },
})
