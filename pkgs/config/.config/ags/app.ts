// surrealism「空 / The Empty Sky」— AGS 環境物件群 entry
// 自適應:空桌面(idle)散落大物件;有視窗(busy)收縮成 SkyBar 細條。
// 目前:程序化天空(底)+ 時間主物件(idle)+ SkyBar(busy)。之後:系統/媒體/通知/launcher。
import app from "ags/gtk4/app"
import style from "./style.css"
import SkyBackground from "./widget/SkyBackground"
import TimeStone from "./widget/TimeStone"
import SkyBar from "./widget/SkyBar"

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.map(SkyBackground)   // 底層天空(兩種狀態都在)
    monitors.map(TimeStone)       // 空桌面:懸空石
    monitors.map(SkyBar)          // 有視窗:細長資訊條
  },
})
