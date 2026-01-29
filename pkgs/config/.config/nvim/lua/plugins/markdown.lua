-- ~/.config/nvim/lua/plugins/markdown-preview.lua
return {
  "iamcco/markdown-preview.nvim",
  -- 安裝前端依賴
  build = "cd app && npm install",

  -- 先不要 ft 限制，確認 plugin 一定會載入
  lazy = false,

  config = function()
    -- 基本設定
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_theme = "dark"

    -- 指定瀏覽器（看你用哪個）
    vim.g.mkdp_browser = "firefox"  -- 或 "chromium" / "google-chrome"
  end,
}

