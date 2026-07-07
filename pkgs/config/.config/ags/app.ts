// surrealism「空 / The Empty Sky」— AGS 環境物件群 entry
// 自適應:空桌面(idle)散落大物件;有視窗(busy)收縮成 SkyBar 細條。
import app from "ags/gtk4/app"
import style from "./style.css"
import SkyBackground from "./widget/SkyBackground"
import TimeStone from "./widget/TimeStone"
import SystemPebble from "./widget/SystemPebble"
import MediaPainting from "./widget/MediaPainting"
import SkyBar from "./widget/SkyBar"

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.map(SkyBackground)    // 底層天空(兩種狀態都在)
    monitors.map(TimeStone)        // idle:時間主物件(左上)
    monitors.map(SystemPebble)     // idle:系統浮石(右下)
    monitors.map(MediaPainting)    // idle+播放:媒體掛畫(右中)
    monitors.map(SkyBar)           // busy:細長資訊條
  },
})
