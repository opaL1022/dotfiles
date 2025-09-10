-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 快速存檔/離開
map("n", "<leader>w", "<cmd>w<cr>", opts)
map("n", "<leader>q", "<cmd>q<cr>", opts)

-- 視窗分割/移動
map("n", "<leader>sv", "<cmd>vsplit<cr>", opts)
map("n", "<leader>sh", "<cmd>split<cr>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- 搜尋游標置中
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- 診斷
map("n", "[d", vim.diagnostic.goto_prev, opts)
map("n", "]d", vim.diagnostic.goto_next, opts)
map("n", "<leader>e", vim.diagnostic.open_float, opts)
map("n", "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", opts)

-- nvim-tree Toggle
map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", opts)

vim.g.mapleader = " "

