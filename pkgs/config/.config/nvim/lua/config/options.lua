-- ~/.config/nvim/lua/config/options.lua

-- 保存 undo/redo 歷史紀錄
vim.opt.undofile = true                           -- 啟用持久化 undo
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"  -- 設定存放目錄

-- 縮排與空格
vim.opt.tabstop = 4        -- 實際 tab 寬度
vim.opt.shiftwidth = 4     -- 自動縮排的空格數
vim.opt.expandtab = true   -- Tab → Space
vim.opt.smartindent = true -- 智能縮排

-- 行號、UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

-- 搜尋
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 分割視窗
vim.opt.splitbelow = true
vim.opt.splitright = true

-- 時間
vim.opt.updatetime = 200
vim.opt.timeoutlen = 400

-- 🔹 Makefile 特例：必須用 tab，不然 make 會報錯
vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function()
    vim.opt_local.expandtab = false  -- 保留實體 tab
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

--主題顏色
vim.cmd.colorscheme("sand")
