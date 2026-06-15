#!/usr/bin/env bash
# 重編「自編 pinstripe 版」hyprbars，對應目前安裝的 Hyprland 版本。
#
# 為什麼需要這支：標準 hyprbars 無法在標題兩側畫橫條(pinstripe)，這版改了
# barDeco.cpp(標題左右畫等距水平線，僅作用視窗)。改動本體 = 同目錄的
# pinstripe.patch。
#
# ** Hyprland 升級後不能用 `hyprpm update`(會裝回原版、蓋掉 pinstripe)，**
# ** 改跑這支 ** —— 它會自動找對應新版 Hyprland 的 pin commit、套用 patch、
# 重編、部署到 ~/.local/share/hyprbars/hyprbars.so(style.lua 載入的路徑)。
#
# patch 套不上(上游改動到 barDeco.cpp 那段)時會中止並提示，需手動重 port。
# 全新機器第一次跑也可以：會自動 clone hyprland-plugins。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH="$SCRIPT_DIR/pinstripe.patch"
SRC="$HOME/.local/src/hyprland-plugins"
DEST="$HOME/.local/share/hyprbars/hyprbars.so"
REPO_URL="https://github.com/hyprwm/hyprland-plugins"

[ -f "$PATCH" ] || { echo "✗ 找不到 patch: $PATCH"; exit 1; }
mkdir -p "$(dirname "$DEST")" "$(dirname "$SRC")"

if [ ! -d "$SRC/.git" ]; then
    echo "==> 首次：clone hyprland-plugins → $SRC"
    git clone --filter=blob:none "$REPO_URL" "$SRC"
fi

cd "$SRC"
echo "==> fetch 最新 hyprland-plugins"
git fetch -q origin

# 目前 Hyprland 的 git commit(完整 40 hex)
HLCOMMIT=$(hyprctl version | grep -oE 'commit [0-9a-f]{8,}' | head -1 | awk '{print $2}')
[ -n "$HLCOMMIT" ] || { echo "✗ 抓不到 Hyprland commit(hyprctl 沒在跑?)"; exit 1; }
echo "==> 目前 Hyprland commit: $HLCOMMIT"

# 從 hyprpm.toml 的 pin 表找對應 plugin commit
# pin 行格式: ["<hyprland-commit>", "<plugin-commit>"]  # x.y.z
PINLINE=$(git show origin/main:hyprpm.toml | grep -F "$HLCOMMIT" || true)
PLUGINCOMMIT=$(printf '%s\n' "$PINLINE" | grep -oE '[0-9a-f]{40}' | tail -1 || true)
if [ -z "$PLUGINCOMMIT" ]; then
    echo "✗ hyprpm.toml 還沒有 $HLCOMMIT 的 pin。"
    echo "  上游可能還沒替這版 Hyprland 加 pin；晚點再試，或手動指定 plugin commit。"
    exit 1
fi
echo "==> 對應 hyprbars pin commit: $PLUGINCOMMIT"

echo "==> checkout pin commit 並套用 pinstripe.patch"
git reset --hard -q
git checkout -q "$PLUGINCOMMIT"
if ! git apply --3way "$PATCH"; then
    echo "✗ pinstripe.patch 套不上(上游動到 barDeco.cpp 標題渲染段)。"
    echo "  需手動把 pinstripe 邏輯重 port 到新版 barDeco.cpp，再更新 $PATCH。"
    exit 1
fi

echo "==> 重編"
make -C hyprbars CXX=g++ clean >/dev/null 2>&1 || true
make -C hyprbars CXX=g++

cp "$SRC/hyprbars/hyprbars.so" "$DEST"
echo "✔ 已部署到 $DEST"
echo
echo "套用到執行中的 Hyprland(live)："
echo "  hyprctl plugin unload \"\$HOME/.local/share/hyprbars/hyprbars.so\""
echo "  hyprctl plugin load   \"\$HOME/.local/share/hyprbars/hyprbars.so\"   # 註冊 config key"
echo "  hyprctl reload                                                       # 套用 yorha 設定"
echo "或直接重啟 Hyprland(下次登入 style.lua 會自動載入)。"
