// surrealism「空 / The Empty Sky」— AGS 環境物件群 entry
// 靜止桌面 = 一片天空 + 少數散落的漂浮物件(每個是獨立 layer-shell window)。
// 目前:程序化天空(底) + 時間主物件。之後:系統浮石 / 媒體掛畫 / 通知 / launcher。
import app from "ags/gtk4/app"
import style from "./style.css"
import SkyBackground from "./widget/SkyBackground"
import TimeStone from "./widget/TimeStone"

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.map(SkyBackground)   // 底層天空
    monitors.map(TimeStone)       // 其上的懸空石
  },
})
