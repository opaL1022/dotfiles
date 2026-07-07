// 共用 Astal 服務層:電量 / 網路 / 媒體。給系統浮石、媒體掛畫、SkyBar 一起用。
// 較 fiddly 的 network/mpris 用 poll 包住(對物件身分變動較穩),battery 用 binding。
import { createBinding, createComputed } from "ags"
import { createPoll } from "ags/time"
import AstalBattery from "gi://AstalBattery"
import AstalNetwork from "gi://AstalNetwork"
import AstalMpris from "gi://AstalMpris"

const bat = AstalBattery.get_default()!
const net = AstalNetwork.get_default()!
const mpris = AstalMpris.get_default()!

// ── 電量 ──
export const batPct = createBinding(bat, "percentage")
export const batCharging = createBinding(bat, "charging")
export const batLabel = createComputed([batPct], (p) => `${Math.round((p ?? 0) * 100)}%`)

// ── 網路(poll,防 wifi 為 null) ──
export const netLabel = createPoll("—", 3000, () => {
  const w = net.wifi
  if (w && w.ssid) return w.ssid
  if (net.wired) return "eth"
  return "—"
})

// ── 媒體(mpris,poll 第一個 player) ──
export const mediaPlaying = createPoll(false, 1000, () => mpris.players.length > 0)
export const mediaTitle = createPoll("", 1000, () => mpris.players[0]?.title ?? "")
export const mediaArtist = createPoll("", 1000, () => mpris.players[0]?.artist ?? "")
export const mediaCover = createPoll("", 2000, () =>
  (mpris.players[0]?.coverArt ?? "").replace("file://", ""))
