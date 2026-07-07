// 多桌布 + 每桌布的球體位置。切桌布時球體跟著換位(靠重啟 AGS 套用)。
// 當前桌布 index 存在 ~/.cache/sky-wallpaper-idx;scripts/sky-wall 循環切換。
// ⚠ 位置是對齊各桌布建築估算的,微調改這裡的數字即可。
import { Astal } from "ags/gtk4"
import GLib from "gi://GLib"

const A = Astal.WindowAnchor
const HOME = GLib.get_home_dir()
const WP = HOME + "/Pictures/wallpapers/surrealism/"

export type Pos = {
  anchor: number
  top?: number; bottom?: number; left?: number; right?: number
  size?: number
}
export type Wallpaper = {
  name: string
  image: string       // "" = 程序化天空
  moon: Pos           // TimeStone(時間主物件)
  cpu: Pos            // 拱門球(CPU/RAM)
  volume: Pos         // 圓池球(音量)
  wifi: Pos           // 系統球(電量/網路)
}

export const WALLPAPERS: Wallpaper[] = [
  {
    name: "courtyard",
    image: WP + "moonlit-courtyard.png",
    moon:   { anchor: A.TOP | A.LEFT,     top: 150, left: 340, size: 340 },
    cpu:    { anchor: A.TOP | A.RIGHT,    top: 597, right: 454, size: 150 },   // 拱門
    volume: { anchor: A.BOTTOM | A.LEFT,  bottom: 235, left: 575, size: 130 }, // 圓池
    wifi:   { anchor: A.BOTTOM | A.RIGHT, bottom: 150, right: 230 },
  },
  {
    name: "pavilion",
    image: WP + "pavilion.png",
    moon:   { anchor: A.TOP | A.LEFT,     top: 130, left: 150, size: 320 },    // 左上開闊夜空
    cpu:    { anchor: A.TOP | A.LEFT,     top: 430, left: 1090, size: 140 },   // 柱子旁
    volume: { anchor: A.BOTTOM | A.LEFT,  bottom: 264, left: 419, size: 130 }, // 涼亭下陰影地面
    wifi:   { anchor: A.BOTTOM | A.RIGHT, bottom: 124, right: 420 },           // 右下亮面地板
  },
  {
    name: "oculus",
    image: WP + "oculus-pool.png",
    moon:   { anchor: A.TOP | A.LEFT,     top: 454, left: 833, size: 230 },    // 圓洞內(月亮框在圓窗)
    cpu:    { anchor: A.TOP | A.RIGHT,    top: 170, right: 260, size: 130 },   // 右上夜空
    volume: { anchor: A.BOTTOM | A.LEFT,  bottom: 191, left: 883, size: 130 }, // 反射池末端
    wifi:   { anchor: A.BOTTOM | A.LEFT,  bottom: 220, left: 200 },            // 左下
  },
]

const CACHE = HOME + "/.cache/sky-wallpaper-idx"
function readIdx(): number {
  try {
    const [ok, bytes] = GLib.file_get_contents(CACHE)
    if (ok) {
      const n = parseInt(new TextDecoder().decode(bytes).trim(), 10)
      if (!isNaN(n)) return ((n % WALLPAPERS.length) + WALLPAPERS.length) % WALLPAPERS.length
    }
  } catch (_e) { /* 用預設 */ }
  return 0
}

// 啟動時讀一次(切桌布 = 寫 cache + 重啟 AGS)
export const current: Wallpaper = WALLPAPERS[readIdx()]
