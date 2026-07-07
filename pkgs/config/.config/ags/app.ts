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
import Launcher from "./widget/Launcher"
import PowerMenu from "./widget/PowerMenu"
import { execAsync } from "ags/process"
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
    // idle:對齊桌布建築的資訊球體(拱門=CPU/RAM→btop、圓池=音量→pavucontrol)
    monitors.map((m) => DecoStone(m, { key: "arch", anchor: A.TOP | A.RIGHT, marginTop: 597, marginRight: 454, size: 150, label: cpuLabel, sublabel: ramLabel, onActivate: () => execAsync(["alacritty", "-e", "btop"]) }))
    monitors.map((m) => DecoStone(m, { key: "pool", anchor: A.BOTTOM | A.LEFT, marginBottom: 235, marginLeft: 575, size: 130, label: volumeLabel, onActivate: () => execAsync("pavucontrol") }))
    monitors.map(Launcher)         // Super+D 召喚(ags toggle launcher)
    monitors.map(PowerMenu)        // 點擊月亮召喚電源選單
  },
})
