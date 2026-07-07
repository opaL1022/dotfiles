// surrealism「空 / The Empty Sky」— AGS 環境物件群 entry
// 靜止桌面 = 一片天空 + 少數散落的漂浮物件(每個是獨立 layer-shell window)。
// 目前:時間主物件(垂直切片)。之後陸續加:系統浮石 / 媒體掛畫 / 通知 / launcher / 程序化天空。
import app from "ags/gtk4/app"
import style from "./style.css"
import TimeStone from "./widget/TimeStone"

app.start({
  css: style,
  main() {
    app.get_monitors().map(TimeStone)
  },
})
