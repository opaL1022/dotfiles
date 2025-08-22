#!/usr/bin/env python3
import argparse, json, shutil, subprocess, sys, time

def sh(*args, text=True, timeout=2):
    try:
        return subprocess.check_output(args, text=text, timeout=timeout).strip()
    except subprocess.CalledProcessError:
        return ""
    except Exception:
        return ""

def has_playerctl():
    return shutil.which("playerctl") is not None

def truncate(s, n):
    if n <= 0 or len(s) <= n:
        return s
    return s[: max(0, n - 1)] + "…"

def status_icon(s):
    s = s.lower()
    if s == "playing":
        return "▶"
    if s == "paused":
        return "⏸"
    return "■"

def loop_icon(loop):
    loop = (loop or "").lower()
    if loop == "track":
        return "🔂 "
    if loop == "playlist":
        return "🔁 "
    return ""

def shuffle_icon(shuffle):
    return "🔀 " if (shuffle or "").lower() == "on" else ""

def get_player_arg(player):
    # player 可以是 "spotify,mpd,vlc" 或 "%any"
    if player:
        return ["-p", player]
    return ["-a"]

def get_volume(player):
    v = sh("playerctl", *get_player_arg(player), "volume")
    try:
        if v:
            return f"{round(float(v)*100):d}%"
    except:
        pass
    return ""

def get_loop(player):
    return sh("playerctl", *get_player_arg(player), "loop")

def get_shuffle(player):
    return sh("playerctl", *get_player_arg(player), "shuffle")

def current_snapshot(player, max_len):
    fmt = "{{status}}|{{playerName}}|{{artist}}|{{title}}|{{album}}"
    meta = sh("playerctl", *get_player_arg(player), "metadata", "--format", fmt)
    if not meta:
        return None

    status, pname, artist, title, album = (meta.split("|") + ["", "", "", "", ""])[:5]
    vol = get_volume(player)
    lp = get_loop(player)
    shuf = get_shuffle(player)

    base = f"{artist} - {title}".strip(" -")
    if not base:
        base = title or artist or "No media"

    text = f"{status_icon(status)} {shuffle_icon(shuf)}{loop_icon(lp)}{truncate(base, max_len)}"
    tooltip = f"{pname}\n{artist} — {title}"
    if album:
        tooltip += f"\n《{album}》"
    if vol:
        tooltip += f"\nVol: {vol}"

    classes = ["media", status.lower() if status else "unknown"]
    return {
        "text": text,
        "alt": base,
        "tooltip": tooltip,
        "class": " ".join(classes)
    }

def follow_stream(player, max_len):
    # 監聽 metadata 變更；format 內含 status/player/artist/title/album
    fmt = "{{status}}|{{playerName}}|{{artist}}|{{title}}|{{album}}"
    proc = subprocess.Popen(
        ["playerctl", *get_player_arg(player), "metadata", "--format", fmt, "--follow"],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1
    )
    return proc

def main():
    ap = argparse.ArgumentParser(description="Waybar custom media (playerctl follower)")
    ap.add_argument("--player", default="", help="playerctl -p 列表，如: 'spotify,mpd,%any'；留空等同 -a")
    ap.add_argument("--max-length", type=int, default=60, help="顯示文字最大長度（自動省略）")
    ap.add_argument("--poll-volume", action="store_true", help="每次事件時查詢音量/loop/shuffle")
    args = ap.parse_args()

    if not has_playerctl():
        print(json.dumps({"text":"No playerctl","class":"media error"}))
        sys.exit(0)

    # 先輸出一次快照（避免剛啟動時空白）
    snap = current_snapshot(args.player, args.max_length)
    if snap:
        print(json.dumps(snap), flush=True)
    else:
        print(json.dumps({"text":"No player","class":"media idle"}), flush=True)

    # 進入跟隨模式
    while True:
        proc = follow_stream(args.player, args.max_length)
        if not proc or not proc.stdout:
            time.sleep(1)
            continue
        try:
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    status, pname, artist, title, album = (line.split("|") + ["", "", "", "", ""])[:5]
                except ValueError:
                    continue

                vol = get_volume(args.player) if args.poll_volume else ""
                lp  = get_loop(args.player)   if args.poll_volume else ""
                shf = get_shuffle(args.player) if args.poll_volume else ""

                base = f"{artist} - {title}".strip(" -")
                if not base:
                    base = title or artist or "No media"

                text = f"{status_icon(status)} {shuffle_icon(shf)}{loop_icon(lp)}{truncate(base, args.max_length)}"
                tooltip = f"{pname}\n{artist} — {title}"
                if album:
                    tooltip += f"\n《{album}》"
                if vol:
                    tooltip += f"\nVol: {vol}"

                out = {
                    "text": text,
                    "alt": base,
                    "tooltip": tooltip,
                    "class": " ".join(["media", status.lower() if status else "unknown"])
                }
                print(json.dumps(out), flush=True)
        except Exception:
            # 異常時稍等後重連
            time.sleep(1)
        finally:
            try:
                proc.kill()
            except Exception:
                pass

if __name__ == "__main__":
    main()

