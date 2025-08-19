-- colors/sand.lua
-- 冷灰沙色主題（更灰、更柔和）

local sand = {}

sand.setup = function()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "sand"

  -- 冷灰沙色調
  local bg     = "#1a1a18" -- 深灰黑帶棕
  local fg     = "#c8c2ac" -- 冷沙灰字
  local accent = "#9d9278" -- 冷沙棕
  local orange = "#b89b72" -- 柔和淺沙橘
  local red    = "#a97c7c" -- 冷紅
  local green  = "#7f9473" -- 灰綠
  local blue   = "#7c8f9d" -- 灰藍
  local gray   = "#6b6558" -- 灰沙色

  -- 基本介面
  vim.api.nvim_set_hl(0, "Normal",       { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "LineNr",       { fg = gray, bg = bg })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = orange, bold = true })
  vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#22221f" })
  vim.api.nvim_set_hl(0, "Visual",       { bg = "#2d2d29" })

  -- 狀態列 / 視窗
  vim.api.nvim_set_hl(0, "StatusLine",   { fg = fg, bg = accent, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = gray, bg = "#22221f" })
  vim.api.nvim_set_hl(0, "VertSplit",    { fg = "#33332e" })

  -- 語法高亮
  vim.api.nvim_set_hl(0, "Comment",      { fg = gray, italic = true })
  vim.api.nvim_set_hl(0, "Keyword",      { fg = orange, bold = true })
  vim.api.nvim_set_hl(0, "Identifier",   { fg = fg })
  vim.api.nvim_set_hl(0, "Function",     { fg = orange })
  vim.api.nvim_set_hl(0, "String",       { fg = green })
  vim.api.nvim_set_hl(0, "Number",       { fg = red })
  vim.api.nvim_set_hl(0, "Boolean",      { fg = red, bold = true })
  vim.api.nvim_set_hl(0, "Type",         { fg = blue, bold = true })

  -- LSP / 診斷
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = red })
  vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = orange })
  vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = blue })
  vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = green })
end

sand.setup()
return sand

