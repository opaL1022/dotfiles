# hyprbars pinstripe fork (retroism)

標準 hyprbars 無法在標題文字兩側畫橫條（Mac OS Platinum 風 pinstripe）。
這裡放的是讓它能畫的最小改動 + 重編腳本，讓整套 retroism 主題可重現。

- **`pinstripe.patch`** — 對 `hyprbars/barDeco.cpp` 的改動：在 `renderPass()` 畫完
  標題 texture 後，於文字左右各畫一組等距半透明水平線，**僅作用中視窗**
  （背景視窗保持素淨，符合 Platinum 行為）。
- **`rebuild-hyprbars.sh`** — 自動抓對應目前 Hyprland 版本的 plugin pin commit、
  套用 patch、重編、部署到 `~/.local/share/hyprbars/hyprbars.so`。

## 重現 / 升級流程

```sh
~/.config/hypr/hyprbars-patch/rebuild-hyprbars.sh
```

- 全新機器第一次跑會自動 `git clone` hyprland-plugins 到 `~/.local/src/`。
- `style.lua` 用 `hl.plugin.load("~/.local/share/hyprbars/hyprbars.so")` 載入此 .so，
  並設 `bar_text_align = "center"`（pinstripe 對稱所需）。

## ⚠️ 重要

- **Hyprland 升級後不要用 `hyprpm update`** —— 那會裝回原版 hyprbars、蓋掉 pinstripe。
  改跑上面的 `rebuild-hyprbars.sh`。
- 若上游大改 `barDeco.cpp` 的標題渲染段導致 patch 套不上，腳本會中止；
  需手動把 pinstripe 邏輯重 port 到新版，再更新 `pinstripe.patch`。
- 整窗的 Platinum 浮雕感另外靠 `general.col.active_border` 漸層邊框（見 `style.lua`）。
