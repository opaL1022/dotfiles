return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {
        on_attach = function(bufnr)
            local api = require('nvim-tree.api')

            api.config.mappings.default_on_attach(bufnr)

            local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

            vim.keymap.set('n', 'l', api.node.open.edit, opts)
            vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts)
            vim.keymap.set('n', 't', api.node.open.tab, opts)
        end,
        tab = {
            sync = {
            open = true,
            close = true,
            ignore = {},
            },
        },
    }

    local api = require("nvim-tree.api")
    local grp = vim.api.nvim_create_augroup("NvimTreeRevealOnEnter", { clear = true })

    local function reveal_current(buf)
      if not buf or vim.bo[buf].filetype == "NvimTree" then return end
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then return end            -- 無名 buffer 就略過
      if not api.tree.is_visible() then
        api.tree.open({ focus = false })       -- 開樹但不搶焦點
      end
      api.tree.find_file({
        buf = buf,
        open = true,                           -- 確保展開節點
        focus = false,                         -- 不切焦點到樹
        update_root = false,                   -- 若想跟著換根，改成 true
      })
    end

    -- 取代原本的 VimEnter：先展開到當前檔案，再把焦點留在編輯器
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local api = require("nvim-tree.api")

    -- 先找這個分頁中第一個「非浮動、非 NvimTree」的編輯器視窗與 buffer
    local editor_win, editor_buf
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local cfg = vim.api.nvim_win_get_config(w)
      local b = vim.api.nvim_win_get_buf(w)
      if cfg.relative == "" and vim.bo[b].filetype ~= "NvimTree" then
        editor_win, editor_buf = w, b
        break
      end
    end

    -- 若整個 tab 都沒有編輯器視窗，就不處理（避免強行聚焦失敗）
    if not editor_win then return end

    -- 確保樹已開，但不要搶焦點
    if not api.tree.is_visible() then
      api.tree.open({ focus = false })
    end

    -- 先「展開」到當前檔案（以編輯器的 buffer 為準），不切焦點到樹
    local name = vim.api.nvim_buf_get_name(editor_buf)
    if name ~= "" then
      api.tree.find_file({
        buf = editor_buf,
        open = true,
        focus = false,
        update_root = false,  -- 要跟著換根就改 true
      })
    end

    -- 最後一步：把焦點切回編輯器視窗
    if vim.api.nvim_win_is_valid(editor_win) then
      vim.api.nvim_set_current_win(editor_win)
    end
  end,
})

    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        local tree_wins = {}
        local floating_wins = {}
        local wins = vim.api.nvim_list_wins()
        for _, w in ipairs(wins) do
          local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
          if bufname:match("NvimTree_") ~= nil then
            table.insert(tree_wins, w)
          end
          if vim.api.nvim_win_get_config(w).relative ~= "" then
            table.insert(floating_wins, w)
          end
        end
        -- 如果除了 nvim-tree 沒有別的 window，就直接退出
        if 1 == #wins - #floating_wins - #tree_wins then
          for _, w in ipairs(tree_wins) do
            vim.api.nvim_win_close(w, true)
          end
        end
      end,
    })
    vim.api.nvim_create_autocmd("BufEnter", {
      nested = true,
      callback = function()
        -- 如果不是 NvimTree buffer，直接 return
        if vim.bo.filetype ~= "NvimTree" then return end

        local wins = vim.api.nvim_tabpage_list_wins(0)
        if #wins == 1 then
          vim.cmd("tabclose")
        end
      end,
    })
    vim.api.nvim_create_autocmd("TabEnter", {
  group = grp,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == "NvimTree" then
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local cfg = vim.api.nvim_win_get_config(w)
        local b = vim.api.nvim_win_get_buf(w)
        if cfg.relative == "" and vim.bo[b].filetype ~= "NvimTree" then
          buf = b; break
        end
      end
    end
    reveal_current(buf)
  end,
})
    -- 離開某個 Tab 時，若焦點在 NvimTree，就切回到編輯器視窗
    vim.api.nvim_create_autocmd("TabLeave", {
      callback = function()
        local curwin = vim.api.nvim_get_current_win()
        local curbuf = vim.api.nvim_win_get_buf(curwin)
        if vim.bo[curbuf].filetype ~= "NvimTree" then return end

        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local cfg = vim.api.nvim_win_get_config(w)
          local b = vim.api.nvim_win_get_buf(w)
          if cfg.relative == "" and vim.bo[b].filetype ~= "NvimTree" then
            vim.api.nvim_set_current_win(w)
            return
          end
        end
        -- 若整個 tab 真的只有 NvimTree，就不動作
      end,
    })

  end,
}
