vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("config.lazy")      -- 初始化 lazy.nvim 和插件匯入
require("config.options")   -- 編輯器選項（要早於大多數插件）
require("config.keymaps")   -- 快捷鍵（含 mapleader）
require("config.autocmds")  -- 自動命令

