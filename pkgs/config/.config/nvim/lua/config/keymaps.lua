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

-- Terminal sends Shift+Enter as CSI-u from Alacritty; keep it as a distinct key
-- and make it behave like Enter in insert/cmdline instead of leaving insert mode.
map("i", "<Esc>[13;2u", "<CR>", opts)
map("c", "<Esc>[13;2u", "<CR>", opts)
map("i", "<S-CR>", "<CR>", opts)
map("c", "<S-CR>", "<CR>", opts)

-- 診斷
map("n", "[d", vim.diagnostic.goto_prev, opts)
map("n", "]d", vim.diagnostic.goto_next, opts)
map("n", "<leader>e", vim.diagnostic.open_float, opts)
map("n", "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", opts)

-- nvim-tree Toggle
map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", opts)

map("n", "<leader>cc", "<cmd>CopilotToggle<cr>", opts)
map("n", "<leader>cE", "<cmd>CopilotEnable<cr>", opts)
map("n", "<leader>cD", "<cmd>CopilotDisable<cr>", opts)

-- LSP code action = refactor / quick fix
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Rename symbol
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
