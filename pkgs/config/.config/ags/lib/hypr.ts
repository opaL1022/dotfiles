// 自適應佈局的核心訊號:當前工作區「有沒有視窗」。
// idle(空)→ 環境物件散落放大;busy(有視窗)→ 收縮成 SkyBar 細條。
import AstalHyprland from "gi://AstalHyprland"
import { createBinding, createComputed } from "ags"

const hypr = AstalHyprland.get_default()!

const clients = createBinding(hypr, "clients")
const focused = createBinding(hypr, "focusedWorkspace")

// 聚焦工作區上是否有任何 client
export const busy = createComputed(
  [clients, focused],
  (cs, ws) => !!ws && cs.some((c) => c.workspace?.id === ws.id),
)

export const idle = createComputed([busy], (b) => !b)
