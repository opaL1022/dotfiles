-- LSP + nvim-cmp（補全鍵：<C-Space>）
return {
  -- 只用 mason 當安裝器（不使用 mason-lspconfig，以免重複啟動）
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({})
    end,
  },

  -- nvim-cmp 最小配置（含 snippets）
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      local cmp, luasnip = require("cmp"), require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fb)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fb() end
          end, { "i","s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fb)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fb() end
          end, { "i","s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" },
        }, { { name = "buffer" }, { name = "path" } }),
      })
    end,
  },

  -- 標準 nvim-lspconfig 寫法
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "hrsh7th/nvim-cmp" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- 避免重複執行
      if vim.g.__lsp_setup_done then return end
      vim.g.__lsp_setup_done = true

      -- 讓 .sv / .svh 正確成為 systemverilog
      vim.filetype.add({
        extension = { sv = "systemverilog", svh = "systemverilog" },
      })

      -- 診斷視覺設定
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- 共同 on_attach / capabilities
      local on_attach = function(_, bufnr)
        local o = { noremap = true, silent = true, buffer = bufnr }
        -- LSP 功能
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
        vim.keymap.set("n", "K",  vim.lsp.buf.hover, o)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
        -- 診斷快捷鍵
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, o)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, o)
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.offsetEncoding = { "utf-16" } -- 避免 encoding 警告（for clangd）

      -- 專案根：用內建 vim.fs 向上找標記
      local function find_root_by_markers(start_path, markers)
        local found = vim.fs.find(markers, { upward = true, path = start_path })[1]
        return found and vim.fs.dirname(found) or vim.fs.dirname(start_path)
      end

      local lspconfig = require("lspconfig")

      -- C/C++（clangd）
      lspconfig.clangd.setup({
        cmd = { "clangd", "--offset-encoding=utf-16" },
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          local start = (fname ~= "" and fname) or vim.api.nvim_buf_get_name(0)
          return find_root_by_markers(start, { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" })
        end,
      })

      -- Python（pyright）
      lspconfig.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          local start = (fname ~= "" and fname) or vim.api.nvim_buf_get_name(0)
          return find_root_by_markers(start, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
        end,
      })

      -- Lua（lua_ls）
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          local start = (fname ~= "" and fname) or vim.api.nvim_buf_get_name(0)
          return find_root_by_markers(start, { ".luarc.json", ".git" })
        end,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
          },
        },
      })

      -- ✅ Verilog/SystemVerilog：verible-verilog-ls
      lspconfig.verible.setup({
        name = "verible",
        cmd = { "verible-verilog-ls" },                 -- 確保此 binary 在 PATH（Mason 可安裝）
        filetypes = { "verilog", "systemverilog" },     -- .v / .sv / .svh
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          local start = (fname ~= "" and fname) or vim.api.nvim_buf_get_name(0)
          -- 以 .git 為專案根（你可改成搜 .rules.verible_lint 等）
          local dir = vim.fs.dirname(start)
          local git = vim.fs.find({ ".git" }, { upward = true, path = dir })[1]
          return git and vim.fs.dirname(git) or dir
        end,
        -- 若你有 verible 規則檔，可開啟自動搜尋：
        -- init_options = { rules_config_search = true },
        -- 或明確指定：
        -- cmd = { "verible-verilog-ls", "--rules_config_file", ".rules.verible_lint" },
      })

      -- （可選）hdl-checker：想改用可打開
      -- lspconfig.hdl_checker.setup({
      --   cmd = { "hdl_checker", "--lsp" },
      --   filetypes = { "vhdl", "verilog", "systemverilog" },
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   root_dir = function(fname)
      --     local start = (fname ~= "" and fname) or vim.api.nvim_buf_get_name(0)
      --     return find_root_by_markers(start, { "hdl_checker.config", ".git" })
      --   end,
      -- })
    end,
  },
}

