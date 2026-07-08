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
import { busy } from "./lib/hypr"
import GLib from "gi://GLib"

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

    // waybar 反邏輯:空桌面(idle)隱去 bar → 只剩漂浮球體;有視窗(busy)時 bar 現身。
    // AGS 已事件驅動算 busy;用 waybar SIGUSR1(toggle)同步,追蹤 intended 狀態只在切換時發訊號。
    let barVisible = true          // waybar 啟動預設可見
    const setBar = (want: boolean) => {
      if (want !== barVisible) {
        execAsync(["pkill", "-USR1", "-x", "waybar"]).catch(() => {})
        barVisible = want
      }
    }
    // 啟動對齊(延遲確保 waybar 已起);之後每次 idle/busy 切換
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1500, () => { setBar(busy.get()); return GLib.SOURCE_REMOVE })
    busy.subscribe(() => setBar(busy.get()))
  },
})
