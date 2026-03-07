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

        vim.keymap.set('n', 'l', function()
          local node = api.tree.get_node_under_cursor()
          if not node then
            return
          end

          local should_move = node.type == "directory" and not node.open
          api.node.open.edit()

          if should_move then
            vim.schedule(function()
              local line = vim.api.nvim_win_get_cursor(0)[1]
              vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
            end)
          end
        end, opts)
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
      if not require("nvim-tree.api").tree.is_visible() then return end
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then return end
      require("nvim-tree.api").tree.find_file({
        buf = buf,
        open = true,      -- 展開節點
        focus = false,    -- 不搶焦點
        update_root = false,
      })
    end

    -- 進入 Neovim：開樹但不搶焦點，並展開到目前檔案
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local api = require("nvim-tree.api")

        -- 找此分頁第一個非浮動、非 NvimTree 的編輯器
        local editor_win, editor_buf
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local cfg = vim.api.nvim_win_get_config(w)
          local b = vim.api.nvim_win_get_buf(w)
          if cfg.relative == "" and vim.bo[b].filetype ~= "NvimTree" then
            editor_win, editor_buf = w, b
            break
          end
        end
        if not editor_win then return end

        if not api.tree.is_visible() then
          api.tree.open({ focus = false })
        end

        local name = vim.api.nvim_buf_get_name(editor_buf)
        if name ~= "" then
          api.tree.find_file({
            buf = editor_buf,
            open = true,
            focus = false,
            update_root = false,
          })
        end

        if vim.api.nvim_win_is_valid(editor_win) then
          vim.api.nvim_set_current_win(editor_win)
        end
      end,
    })

    -- 退出前：若只剩 NvimTree 視窗就直接關掉樹視窗
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
        if 1 == #wins - #floating_wins - #tree_wins then
          for _, w in ipairs(tree_wins) do
            vim.api.nvim_win_close(w, true)
          end
        end
      end,
    })

    -- 若當前 tab 只剩 NvimTree，直接退出此 tab
    vim.api.nvim_create_autocmd("BufEnter", {
      nested = true,
      callback = function()
        if vim.bo.filetype ~= "NvimTree" then return end
        local wins = vim.api.nvim_tabpage_list_wins(0)
        if #wins == 1 then
          vim.cmd("quit")
        end
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
      end,
    })

    -------------------------------------------------------------------
    -- 新增：多 tab 情境下，若某 tab 只剩樹就自動收掉該 tab
    -------------------------------------------------------------------
    local auto_grp = vim.api.nvim_create_augroup("NvimTreeAutoCloseTabs", { clear = true })

    local function tab_only_has_tree(tabpage)
      local real, trees = 0, 0
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tabpage == 0 and 0 or tabpage)) do
        local cfg = vim.api.nvim_win_get_config(w)
        if cfg.relative == "" then
          local b = vim.api.nvim_win_get_buf(w)
          if vim.bo[b].filetype == "NvimTree" then trees = trees + 1 else real = real + 1 end
        end
      end
      return (real == 0 and trees > 0)
    end

    -- 進入任一 tab 時，如果該 tab 只剩 NvimTree，直接關掉這個 tab
    vim.api.nvim_create_autocmd("TabEnter", {
      group = auto_grp,
      callback = function()
        if tab_only_has_tree(0) then
          pcall(vim.cmd, "tabclose")
        end
      end,
    })

    -- 關掉某個視窗後，掃描所有 tab，把只剩樹的 tab 關掉（避免殘留）
    vim.api.nvim_create_autocmd("WinClosed", {
      group = auto_grp,
      callback = function()
        vim.defer_fn(function()
          for _, t in ipairs(vim.api.nvim_list_tabpages()) do
            if tab_only_has_tree(t) then
              pcall(vim.api.nvim_set_current_tabpage, t)
              pcall(vim.cmd, "tabclose")
            end
          end
        end, 0)
      end,
    })
  end,
}

