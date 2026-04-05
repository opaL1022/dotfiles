return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local tree = require("nvim-tree")
    local api = require("nvim-tree.api")

    local function is_tree_buf(buf)
      return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "NvimTree"
    end

    local function is_floating_win(win)
      return vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_config(win).relative ~= ""
    end

    local function get_first_editor_win(tabpage)
      local wins = vim.api.nvim_tabpage_list_wins(tabpage or 0)
      for _, win in ipairs(wins) do
        if not is_floating_win(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          if not is_tree_buf(buf) then
            return win, buf
          end
        end
      end
      return nil, nil
    end

    local function reveal_file(buf)
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if is_tree_buf(buf) then
        return
      end
      if not api.tree.is_visible() then
        return
      end

      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then
        return
      end

      api.tree.find_file({
        buf = buf,
        open = true,
        focus = false,
        update_root = false,
      })
    end

    local function tab_only_has_tree(tabpage)
      local real = 0
      local tree_count = 0

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage or 0)) do
        if not is_floating_win(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          if is_tree_buf(buf) then
            tree_count = tree_count + 1
          else
            real = real + 1
          end
        end
      end

      return real == 0 and tree_count > 0
    end

    tree.setup({
      on_attach = function(bufnr)
        api.config.mappings.default_on_attach(bufnr)

        local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

        vim.keymap.set("n", "l", function()
          local node = api.tree.get_node_under_cursor()
          if not node then
            return
          end

          local should_move = node.type == "directory" and not node.open
          api.node.open.edit()

          if should_move then
            vim.schedule(function()
              if vim.api.nvim_win_is_valid(0) then
                local line = vim.api.nvim_win_get_cursor(0)[1]
                vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
              end
            end)
          end
        end, opts)

        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts)
        vim.keymap.set("n", "t", api.node.open.tab, opts)
        vim.keymap.set('n', 's', api.node.open.horizontal, opts)
        vim.keymap.set('n', 'v', api.node.open.vertical, opts)
      end,

      tab = {
        sync = {
          open = true,
          close = true,
          ignore = {},
        },
      },
    })

    local group = vim.api.nvim_create_augroup("NvimTreeCustom", { clear = true })

    -- 進入 nvim 時：開 tree 但不搶焦點，並 reveal 目前檔案
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      callback = function()
        local editor_win, editor_buf = get_first_editor_win(0)
        if not editor_win then
          return
        end

        if not api.tree.is_visible() then
          api.tree.open({ focus = false })
        end

        reveal_file(editor_buf)

        if vim.api.nvim_win_is_valid(editor_win) then
          vim.api.nvim_set_current_win(editor_win)
        end
      end,
    })

    -- 切換 buffer / 進入視窗時，自動同步 tree 到目前檔案
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      group = group,
      callback = function(args)
        reveal_file(args.buf)

        -- 若當前 tab 只剩 tree，直接關 tab
        if is_tree_buf(args.buf) and tab_only_has_tree(0) then
          pcall(vim.cmd, "tabclose")
        end
      end,
    })

    -- 離開 tab 時，避免焦點停在 tree 上
    vim.api.nvim_create_autocmd("TabLeave", {
      group = group,
      callback = function()
        local curwin = vim.api.nvim_get_current_win()
        if not vim.api.nvim_win_is_valid(curwin) then
          return
        end

        local curbuf = vim.api.nvim_win_get_buf(curwin)
        if not is_tree_buf(curbuf) then
          return
        end

        local editor_win = get_first_editor_win(0)
        if editor_win and vim.api.nvim_win_is_valid(editor_win) then
          vim.api.nvim_set_current_win(editor_win)
        end
      end,
    })

    -- 退出前：若只剩 tree 視窗，先把 tree 關掉
    vim.api.nvim_create_autocmd("QuitPre", {
      group = group,
      callback = function()
        local wins = vim.api.nvim_list_wins()
        local normal = 0
        local tree_wins = {}

        for _, win in ipairs(wins) do
          if not is_floating_win(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if is_tree_buf(buf) then
              table.insert(tree_wins, win)
            else
              normal = normal + 1
            end
          end
        end

        if normal == 1 then
          for _, win in ipairs(tree_wins) do
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end,
    })

    -- 關閉視窗後，若某 tab 只剩 tree，就把那個 tab 關掉
    vim.api.nvim_create_autocmd("WinClosed", {
      group = group,
      callback = function()
        vim.schedule(function()
          local current = vim.api.nvim_get_current_tabpage()
          for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            if vim.api.nvim_tabpage_is_valid(tab) and tab_only_has_tree(tab) then
              pcall(vim.api.nvim_set_current_tabpage, tab)
              pcall(vim.cmd, "tabclose")
            end
          end
          pcall(vim.api.nvim_set_current_tabpage, current)
        end)
      end,
    })
  end,
}
