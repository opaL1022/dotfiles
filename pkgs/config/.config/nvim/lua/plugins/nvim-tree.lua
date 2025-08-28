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
    vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                require("nvim-tree.api").tree.open()
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
      callback = function()
        local curwin = vim.api.nvim_get_current_win()
        local curbuf = vim.api.nvim_win_get_buf(curwin)
        if vim.bo[curbuf].filetype ~= "NvimTree" then return end

        -- 找到同 Tab 中的第一個非浮動、非 NvimTree 視窗並切過去
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local cfg = vim.api.nvim_win_get_config(w)
          local b = vim.api.nvim_win_get_buf(w)
          if cfg.relative == "" and vim.bo[b].filetype ~= "NvimTree" then
            vim.api.nvim_set_current_win(w)
            return
          end
        end
        -- 若整個 Tab 只有 NvimTree，就保持不動（也可選擇關掉 Tab）
      end,
    })
  end,
}
