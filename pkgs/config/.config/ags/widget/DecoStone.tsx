// 裝飾球體 —— 純霧面石(無文字),擺在桌布的建築特徵上(拱門內、圓池上)。
// 只在空桌面(idle)出現,跟其他環境物件一起消失。位置/大小由 app.ts 傳入。
// ⚠ 位置是針對目前這張 moonlit-courtyard 桌布對齊的;換桌布要重調。
import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import { idle } from "../lib/hypr"

export type DecoOpts = {
  key: string
  anchor: number
  size: number
  marginTop?: number
  marginBottom?: number
  marginLeft?: number
  marginRight?: number
}

export default function DecoStone(gdkmonitor: Gdk.Monitor, o: DecoOpts) {
  return (
    <window
      visible={idle}
      name={`deco-${o.key}`}
      class="DecoStone"
      namespace={`empty-sky-deco-${o.key}`}
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={o.anchor}
      marginTop={o.marginTop ?? 0}
      marginBottom={o.marginBottom ?? 0}
      marginLeft={o.marginLeft ?? 0}
      marginRight={o.marginRight ?? 0}
      application={app}
    >
      <box class="deco-stone" css={`min-width:${o.size}px; min-height:${o.size}px;`} />
    </window>
  )
}
