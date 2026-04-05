-- colors/daybreak.lua
-- Daybreak 主題（對齊 VSCode/WT 配色，數字/常數用深橘色）

local daybreak = {}

daybreak.setup = function()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
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

  -- ===== 基本介面 =====
  vim.api.nvim_set_hl(0, "Normal",       { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "LineNr",       { fg = bright_black, bg = bg })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = cursor, bold = true })
  vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#232530" })
  vim.api.nvim_set_hl(0, "Visual",       { bg = sel_bg })
  vim.api.nvim_set_hl(0, "NonText", { fg = "#FAC29A", bold = true })

  vim.api.nvim_set_hl(0, "StatusLine",   { fg = bg, bg = yellow, bold = true })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = bright_black, bg = "#232530" })
  vim.api.nvim_set_hl(0, "VertSplit",    { fg = "#2E303E" })

  -- ===== 語法高亮 =====
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

  -- ===== LSP / 診斷 =====
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = red })
  vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = yellow })
  vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = blue })
  vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = green })

  -- ===== 終端 ANSI 色 =====
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

  -- ===== Treesitter link =====
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
  vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#FAC29A", bold = true })

  -- ===== TabLine =====
  vim.api.nvim_set_hl(0, "TabLine",     { fg = deep_orange, bg = bg })
  vim.api.nvim_set_hl(0, "TabLineSel",  { fg = deep_orange, bg = sel_bg, bold = true })
  vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })

  -- ===== NvimTree =====
  vim.api.nvim_set_hl(0, "NvimTreeNormal",      { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NvimTreeNormalNC",    { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { fg = bg, bg = bg })
  vim.api.nvim_set_hl(0, "NvimTreeWinSeparator",{ fg = "#2E303E", bg = bg })
  vim.api.nvim_set_hl(0, "NvimTreeCursorLine",  { bg = "#232530" })

  vim.api.nvim_set_hl(0, "NvimTreeRootFolder",        { fg = "#FAC29A", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeFolderName",        { fg = "#FAB28E", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName",  { fg = "#FAC29A", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",   { fg = "#E95678" })
  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon",        { fg = "#FAB28E" })
  vim.api.nvim_set_hl(0, "NvimTreeIndentMarker",      { fg = "#333543" })

  vim.api.nvim_set_hl(0, "NvimTreeExecFile",   { fg = "#29D398", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeSpecialFile",{ fg = "#FAB795", italic = true })
  vim.api.nvim_set_hl(0, "NvimTreeSymlink",    { fg = "#59E1E3" })
  vim.api.nvim_set_hl(0, "NvimTreeImageFile",  { fg = "#D5D8DA" })
  vim.api.nvim_set_hl(0, "NvimTreeModified",   { fg = "#FAC29A" })

  vim.api.nvim_set_hl(0, "NvimTreeGitDirty",   { fg = "#FAB795" })
  vim.api.nvim_set_hl(0, "NvimTreeGitStaged",  { fg = "#29D398" })
  vim.api.nvim_set_hl(0, "NvimTreeGitNew",     { fg = "#3FDAA4" })
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#E95678" })
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", { fg = "#FAC29A" })
  vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", { fg = "#333543" })

  vim.api.nvim_set_hl(0, "NvimTreeLiveFilterPrefix", { fg = "#E95678", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeLiveFilterValue",  { fg = "#FAC29A", bold = true })

  -- ===== Lazy.nvim 面板（LazyVim 的面板 UI）=====
  vim.api.nvim_set_hl(0, "LazyNormal",       { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "LazyH1",           { fg = bg, bg = deep_orange, bold = true })
  vim.api.nvim_set_hl(0, "LazyButton",       { fg = deep_orange, bg = bg })
  vim.api.nvim_set_hl(0, "LazyButtonActive", { fg = bg, bg = deep_orange, bold = true })
  vim.api.nvim_set_hl(0, "LazyComment",      { fg = bright_black, italic = true })
  vim.api.nvim_set_hl(0, "LazySpecial",      { fg = purple, bold = true })
  vim.api.nvim_set_hl(0, "LazyReasonEvent",  { fg = yellow })
  vim.api.nvim_set_hl(0, "LazyReasonStart",  { fg = cyan })
  vim.api.nvim_set_hl(0, "LazyReasonPlugin", { fg = bright_purple })
  vim.api.nvim_set_hl(0, "LazyReasonCmd",    { fg = yellow })
  vim.api.nvim_set_hl(0, "LazyProgressDone", { fg = green })
  vim.api.nvim_set_hl(0, "LazyProgressTodo", { fg = bright_black })

  -- ===== nvim-notify（右上角通知）=====
  vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = red,        bg = bg })
  vim.api.nvim_set_hl(0, "NotifyWARNBorder",  { fg = yellow,     bg = bg })
  vim.api.nvim_set_hl(0, "NotifyINFOBorder",  { fg = blue,       bg = bg })
  vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = purple,     bg = bg })
  vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = cyan,       bg = bg })

  vim.api.nvim_set_hl(0, "NotifyERRORTitle",  { fg = red,        bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "NotifyWARNTitle",   { fg = yellow,     bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "NotifyINFOTitle",   { fg = blue,       bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "NotifyDEBUGTitle",  { fg = purple,     bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "NotifyTRACETitle",  { fg = cyan,       bg = bg, bold = true })

  vim.api.nvim_set_hl(0, "NotifyERRORIcon",   { fg = red,        bg = bg })
  vim.api.nvim_set_hl(0, "NotifyWARNIcon",    { fg = yellow,     bg = bg })
  vim.api.nvim_set_hl(0, "NotifyINFOIcon",    { fg = blue,       bg = bg })
  vim.api.nvim_set_hl(0, "NotifyDEBUGIcon",   { fg = purple,     bg = bg })
  vim.api.nvim_set_hl(0, "NotifyTRACEIcon",   { fg = cyan,       bg = bg })

  vim.api.nvim_set_hl(0, "NotifyERRORBody",   { fg = fg,         bg = bg })
  vim.api.nvim_set_hl(0, "NotifyWARNBody",    { fg = fg,         bg = bg })
  vim.api.nvim_set_hl(0, "NotifyINFOBody",    { fg = fg,         bg = bg })
  vim.api.nvim_set_hl(0, "NotifyDEBUGBody",   { fg = fg,         bg = bg })
  vim.api.nvim_set_hl(0, "NotifyTRACEBody",   { fg = fg,         bg = bg })

  -- （可選）Telescope 略帶 Daybreak 風格
  vim.api.nvim_set_hl(0, "TelescopeNormal",   { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "TelescopeBorder",   { fg = "#2E303E", bg = bg })
  vim.api.nvim_set_hl(0, "TelescopeSelection",{ fg = fg, bg = "#232530", bold = true })
  vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = deep_orange })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = cursor, bold = true })

  -- Noice Cmdline 視窗邊框（Daybreak 深橘）
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder",       { fg = "#FAB28E", bg = "#1C1E26" })
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = "#FAB28E", bg = "#1C1E26" })
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderLua",    { fg = "#FAB28E", bg = "#1C1E26" })
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderHelp",   { fg = "#FAB28E", bg = "#1C1E26" })

  -- Noice Cmdline Icon (開頭的 > 符號)
  vim.api.nvim_set_hl(0, "NoiceCmdlineIcon",       { fg = "#FAB28E", bg = "#1C1E26" }) -- 普通命令列
  vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { fg = "#FAB28E", bg = "#1C1E26" }) -- / 搜尋
  vim.api.nvim_set_hl(0, "NoiceCmdlineIconLua",    { fg = "#FAB28E", bg = "#1C1E26" }) -- :lua
  vim.api.nvim_set_hl(0, "NoiceCmdlineIconHelp",   { fg = "#FAB28E", bg = "#1C1E26" }) -- :help

end

daybreak.setup()
return daybreak

