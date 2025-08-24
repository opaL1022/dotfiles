-- colors/daybreak.lua
-- Daybreak 主題（對齊 VSCode/WT 配色，數字/常數用深橘色）

local daybreak = {}

daybreak.setup = function()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "daybreak"

  -- Daybreak 色票
  local bg        = "#1C1E26"
  local fg        = "#D5D8DA"
  local cursor    = "#FAC29A"
  local sel_bg    = "#333543"

  local black     = "#1A1C23"
  local red       = "#E95678"
  local green     = "#29D398"
  local yellow    = "#FAB795"
  local blue      = "#26BBD9"
  local purple    = "#B877DB"
  local cyan      = "#59E1E3"
  local white     = "#D5D8DA"

  local bright_black  = "#333543"
  local bright_red    = "#EC6A88"
  local bright_green  = "#3FDAA4"
  local bright_yellow = "#FBC3A7"
  local bright_blue   = "#3FC4DE"
  local bright_purple = "#F075B5"
  local bright_cyan   = "#6BE4E6"
  local bright_white  = "#FDF0ED"

  -- 深橘色（數字/常數專用）
  local deep_orange = "#FAB28E"

  -- 基本介面
  vim.api.nvim_set_hl(0, "Normal",       { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "LineNr",       { fg = bright_black, bg = bg })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = cursor, bold = true })
  vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#232530" })
  vim.api.nvim_set_hl(0, "Visual",       { bg = sel_bg })

  vim.api.nvim_set_hl(0, "StatusLine",   { fg = bg, bg = yellow, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = bright_black, bg = "#232530" })
  vim.api.nvim_set_hl(0, "VertSplit",    { fg = "#2E303E" })

  -- 語法高亮
  vim.api.nvim_set_hl(0, "Comment",    { fg = "#BBBBBB", italic = true })
  vim.api.nvim_set_hl(0, "Constant",   { fg = deep_orange })   -- 常數 → 深橘
  vim.api.nvim_set_hl(0, "String",     { fg = green })
  vim.api.nvim_set_hl(0, "Character",  { fg = deep_orange })
  vim.api.nvim_set_hl(0, "Number",     { fg = deep_orange })   -- 數字 → 深橘
  vim.api.nvim_set_hl(0, "Boolean",    { fg = deep_orange, bold = true }) -- 布林 → 深橘
  vim.api.nvim_set_hl(0, "Float",      { fg = deep_orange })   -- 浮點 → 深橘

  vim.api.nvim_set_hl(0, "Identifier", { fg = fg })
  vim.api.nvim_set_hl(0, "Function",   { fg = blue })
  vim.api.nvim_set_hl(0, "Statement",  { fg = purple, bold = true })
  vim.api.nvim_set_hl(0, "Keyword",    { fg = purple, bold = true })
  vim.api.nvim_set_hl(0, "Operator",   { fg = "#BBBBBB" })
  vim.api.nvim_set_hl(0, "Type",       { fg = cursor, bold = true })
  vim.api.nvim_set_hl(0, "Structure",  { fg = yellow })
  vim.api.nvim_set_hl(0, "Tag",        { fg = red })

  -- LSP / 診斷
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = red })
  vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = yellow })
  vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = blue })
  vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = green })

  -- 終端 ANSI 色
  vim.g.terminal_color_0  = black
  vim.g.terminal_color_1  = red
  vim.g.terminal_color_2  = green
  vim.g.terminal_color_3  = yellow
  vim.g.terminal_color_4  = blue
  vim.g.terminal_color_5  = purple
  vim.g.terminal_color_6  = cyan
  vim.g.terminal_color_7  = white
  vim.g.terminal_color_8  = bright_black
  vim.g.terminal_color_9  = bright_red
  vim.g.terminal_color_10 = bright_green
  vim.g.terminal_color_11 = bright_yellow
  vim.g.terminal_color_12 = bright_blue
  vim.g.terminal_color_13 = bright_purple
  vim.g.terminal_color_14 = bright_cyan
  vim.g.terminal_color_15 = bright_white
  -- Treesitter highlight links
  vim.api.nvim_set_hl(0, "@comment",      { link = "Comment" })
  vim.api.nvim_set_hl(0, "@constant",     { link = "Constant" })
  vim.api.nvim_set_hl(0, "@string",       { link = "String" })
  vim.api.nvim_set_hl(0, "@number",       { link = "Number" })
  vim.api.nvim_set_hl(0, "@boolean",      { link = "Boolean" })
  vim.api.nvim_set_hl(0, "@type",         { link = "Type" })
  vim.api.nvim_set_hl(0, "@type.builtin", { link = "Type" })
  vim.api.nvim_set_hl(0, "@keyword",      { link = "Keyword" })
  vim.api.nvim_set_hl(0, "@keyword.function", { link = "Keyword" })
  vim.api.nvim_set_hl(0, "@function",     { link = "Function" })
  vim.api.nvim_set_hl(0, "@variable",     { link = "Identifier" })
  vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#FAC29A", bold = true }) -- 比如 true/false/null

  -- 調整 TabLine 顏色
  vim.api.nvim_set_hl(0, "TabLine", { fg = deep_orange, bg = bg })      -- 非當前 tab
  vim.api.nvim_set_hl(0, "TabLineSel", { fg = deep_orange, bg = sel_bg, bold = true }) -- 當前 tab
  vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" }) -- 空白填充

  -- === NvimTree 主題 ===
  -- 面板 / 分隔線 / 游標行
  vim.api.nvim_set_hl(0, "NvimTreeNormal",      { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NvimTreeNormalNC",    { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { fg = bg, bg = bg }) -- 隱藏 ~
  vim.api.nvim_set_hl(0, "NvimTreeWinSeparator",{ fg = "#2E303E", bg = bg }) -- 與 VertSplit 一致
  vim.api.nvim_set_hl(0, "NvimTreeCursorLine",  { bg = "#232530" })

  -- 資料夾 / 路徑 / 縮排（改成橘色系）
  vim.api.nvim_set_hl(0, "NvimTreeRootFolder",        { fg = "#FAC29A", bold = true }) -- Root → 淺橘
  vim.api.nvim_set_hl(0, "NvimTreeFolderName",        { fg = "#FAB28E", bold = true }) -- 資料夾 → 深橘
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName",  { fg = "#FAC29A", bold = true }) -- 開啟 → 淺橘
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",   { fg = "#E95678" })              -- 空資料夾 → 深紅橘
  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon",        { fg = "#FAB28E" })              -- 資料夾圖示 → 深橘
  vim.api.nvim_set_hl(0, "NvimTreeIndentMarker",      { fg = "#333543" })              -- 導引線 → 亮黑

  -- 檔案狀態 / 類型
  vim.api.nvim_set_hl(0, "NvimTreeExecFile",   { fg = "#29D398", bold = true })   -- 可執行：綠
  vim.api.nvim_set_hl(0, "NvimTreeSpecialFile",{ fg = "#FAB795", italic = true }) -- 特殊：黃
  vim.api.nvim_set_hl(0, "NvimTreeSymlink",    { fg = "#59E1E3" })                -- 符號連結：青
  vim.api.nvim_set_hl(0, "NvimTreeImageFile",  { fg = "#D5D8DA" })                -- 圖片：白
  vim.api.nvim_set_hl(0, "NvimTreeModified",   { fg = "#FAC29A" })                -- 已修改：淺橘

  -- Git 狀態（保持原本 daybreak 配色）
  vim.api.nvim_set_hl(0, "NvimTreeGitDirty",   { fg = "#FAB795" }) -- 修改：黃
  vim.api.nvim_set_hl(0, "NvimTreeGitStaged",  { fg = "#29D398" }) -- 已暫存：綠
  vim.api.nvim_set_hl(0, "NvimTreeGitNew",     { fg = "#3FDAA4" }) -- 新檔：亮綠
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#E95678" }) -- 刪除：紅
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", { fg = "#FAC29A" }) -- 重新命名：橘
  vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", { fg = "#333543" }) -- 忽略：亮黑

  -- Live Filter / 替代方案
  vim.api.nvim_set_hl(0, "NvimTreeLiveFilterPrefix", { fg = "#E95678", bold = true }) -- 紅橘
  vim.api.nvim_set_hl(0, "NvimTreeLiveFilterValue",  { fg = "#FAC29A", bold = true }) -- 淺橘

end

daybreak.setup()
return daybreak

