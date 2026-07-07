// 共用 Astal 服務層:電量 / 網路 / 媒體。給系統浮石、媒體掛畫、SkyBar 一起用。
// 較 fiddly 的 network/mpris 用 poll 包住(對物件身分變動較穩),battery 用 binding。
import { createBinding, createComputed } from "ags"
import { createPoll } from "ags/time"
import AstalBattery from "gi://AstalBattery"
import AstalNetwork from "gi://AstalNetwork"
import AstalMpris from "gi://AstalMpris"
import AstalWp from "gi://AstalWp"
import GLib from "gi://GLib"

const bat = AstalBattery.get_default()!
const net = AstalNetwork.get_default()!
const mpris = AstalMpris.get_default()!
const wp = AstalWp.get_default()!

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

// ── 音量(AstalWp 預設揚聲器,poll 防 speaker 為 null) ──
export const volumeLabel = createPoll("—", 500, () => {
  const s = wp.defaultSpeaker
  if (!s) return "—"
  return s.mute ? "靜音" : `${Math.round(s.volume * 100)}%`
})

// ── CPU / RAM(讀 /proc) ──
let prevIdle = 0, prevTotal = 0
function readProc(path: string): string {
  const [ok, bytes] = GLib.file_get_contents(path)
  return ok ? new TextDecoder().decode(bytes) : ""
}
function cpuUsage(): number {
  const line = readProc("/proc/stat").split("\n")[0]  // "cpu  user nice system idle iowait ..."
  const p = line.trim().split(/\s+/).slice(1).map(Number)
  if (p.length < 5) return 0
  const idle = p[3] + (p[4] || 0)
  const total = p.reduce((a, b) => a + b, 0)
  const dIdle = idle - prevIdle, dTotal = total - prevTotal
  prevIdle = idle; prevTotal = total
  return dTotal > 0 ? Math.round((1 - dIdle / dTotal) * 100) : 0
}
function ramUsage(): number {
  const t = readProc("/proc/meminfo")
  const total = Number(t.match(/MemTotal:\s+(\d+)/)?.[1] ?? 0)
  const avail = Number(t.match(/MemAvailable:\s+(\d+)/)?.[1] ?? 0)
  return total ? Math.round((1 - avail / total) * 100) : 0
}
export const cpuLabel = createPoll("0%", 2000, () => `${cpuUsage()}%`)
export const ramLabel = createPoll("RAM 0%", 5000, () => `RAM ${ramUsage()}%`)
