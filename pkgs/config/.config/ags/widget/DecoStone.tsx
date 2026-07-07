// 裝飾/資訊球體 —— 霧面石,擺在桌布的建築特徵上(拱門內、圓池上)。
// 只在空桌面(idle)出現;可傳 label/sublabel 顯示資訊(置中),不傳就是純裝飾球。
// ⚠ 位置是針對目前這張 moonlit-courtyard 桌布對齊的;換桌布要重調。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { idle } from "../lib/hypr"

export type DecoOpts = {
  key: string
  anchor: number
  size: number
  marginTop?: number
  marginBottom?: number
  marginLeft?: number
  marginRight?: number
  label?: unknown     // 主文字 accessor(可選)
  sublabel?: unknown  // 次文字 accessor(可選)
}

export default function DecoStone(gdkmonitor: Gdk.Monitor, o: DecoOpts) {
  const sizeCss = `min-width:${o.size}px; min-height:${o.size}px;`

  const content = o.label ? (
    <centerbox class="deco-stone" orientation={Gtk.Orientation.VERTICAL} css={sizeCss}>
      <box $type="center" orientation={Gtk.Orientation.VERTICAL} halign={Gtk.Align.CENTER}>
        <label class="deco-main" label={o.label as any} halign={Gtk.Align.CENTER} />
        {o.sublabel ? (
          <label class="deco-sub" label={o.sublabel as any} halign={Gtk.Align.CENTER} />
        ) : (
          <box />
        )}
      </box>
    </centerbox>
  ) : (
    <box class="deco-stone" css={sizeCss} />
  )

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
      {content}
    </window>
  )
}
