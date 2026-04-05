-- ~/.config/nvim/lua/config/autocmds.lua
-- 高亮 yank 區塊
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
})
