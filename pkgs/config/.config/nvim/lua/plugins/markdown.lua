-- ~/.config/nvim/lua/plugins/markdown-preview.lua
return {
  "iamcco/markdown-preview.nvim",
  -- 安裝前端依賴，並把內建的 mermaid 10.2.3 換成 11（修 "Syntax error in text"）
  -- npm install 完還原 yarn.lock，避免 lazy 之後抱怨 local changes
  -- skip-worktree 讓 git 假裝 mermaid.min.js 沒被改，lazy 按 U 才不會跳 local changes
  build = "cd app && npm install && git checkout -- yarn.lock && rm -f package-lock.json"
    .. " && curl -fsSL -o _static/mermaid.min.js https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"
    .. " && git update-index --skip-worktree _static/mermaid.min.js",

  -- 上游 2023 年後幾乎沒更新；pin 住避免 lazy update 因為上面替換的 mermaid 卡 local changes
  -- 想更新時：拿掉 pin，刪掉外掛重裝（build hook 會自動重新換 mermaid）
  pin = true,

  -- 先不要 ft 限制，確認 plugin 一定會載入
  lazy = false,

  config = function()
    -- 基本設定
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_theme = "dark"

    -- 指定瀏覽器（看你用哪個）
    vim.g.mkdp_browser = "zen-browser"  -- 或 "chromium" / "google-chrome"
  end,
}

