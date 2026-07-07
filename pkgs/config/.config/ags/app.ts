// surrealism「空 / The Empty Sky」— AGS 環境物件群 entry
// idle 散落物件(位置隨當前桌布,lib/wallpaper);waybar 當常駐 bar。
import app from "ags/gtk4/app"
import style from "./style.css"
import SkyBackground from "./widget/SkyBackground"
import TimeStone from "./widget/TimeStone"
import SystemPebble from "./widget/SystemPebble"
import MediaPainting from "./widget/MediaPainting"
import DecoStone from "./widget/DecoStone"
import PowerMenu from "./widget/PowerMenu"
import { execAsync } from "ags/process"
import { cpuLabel, ramLabel, volumeLabel } from "./lib/services"
import { current } from "./lib/wallpaper"

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    const cpu = current.cpu, vol = current.volume
    monitors.map(SkyBackground)    // 底層天空/桌布
    monitors.map(TimeStone)        // idle:時間主物件(月亮)
    monitors.map(SystemPebble)     // idle:系統浮石(電量/網路)
    monitors.map(MediaPainting)    // idle+播放:媒體掛畫
    // idle:對齊桌布建築的資訊球體(拱門=CPU/RAM→btop、圓池=音量→pavucontrol);位置隨桌布
    monitors.map((m) => DecoStone(m, { key: "arch", anchor: cpu.anchor, marginTop: cpu.top, marginBottom: cpu.bottom, marginLeft: cpu.left, marginRight: cpu.right, size: cpu.size ?? 140, label: cpuLabel, sublabel: ramLabel, onActivate: () => execAsync(["alacritty", "-e", "btop"]) }))
    monitors.map((m) => DecoStone(m, { key: "pool", anchor: vol.anchor, marginTop: vol.top, marginBottom: vol.bottom, marginLeft: vol.left, marginRight: vol.right, size: vol.size ?? 130, label: volumeLabel, onActivate: () => execAsync("pavucontrol") }))
    monitors.map(PowerMenu)        // 點擊月亮召喚電源選單
  },
})
