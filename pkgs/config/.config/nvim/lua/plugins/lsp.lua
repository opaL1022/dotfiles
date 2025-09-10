-- LSP + nvim-cmp（補全鍵：<C-Space>）
return {
  -- 只用 mason 當安裝器（不使用 mason-lspconfig，以免重複啟動）
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup({}) end,
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

  -- 純 lspconfig（手動 setup，一次到位、避免重複）
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "hrsh7th/nvim-cmp" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- 只跑一次
      if vim.g.__lsp_setup_done then return end
      vim.g.__lsp_setup_done = true

      -- 診斷視覺設定（新增）
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- 讓 .sv / .svh 正確成為 systemverilog（新增）
      vim.filetype.add({
        extension = { sv = "systemverilog", svh = "systemverilog" },
      })

      -- 停掉任何已啟動的 clangd（防重複）
      for _, c in ipairs(vim.lsp.get_clients()) do
        if c.name == "clangd" then c.stop(true) end
      end

      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      local on_attach = function(_, bufnr)
        local o = { noremap = true, silent = true, buffer = bufnr }

        -- LSP 功能
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
        vim.keymap.set("n", "K",  vim.lsp.buf.hover, o)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)

        -- 🛠️ 診斷快捷鍵
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, o)   -- 看錯誤訊息浮窗
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)           -- 跳到上一個錯誤
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)           -- 跳到下一個錯誤
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, o)   -- 把錯誤丟到 loclist
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.offsetEncoding = { "utf-16" } -- 避免 encoding 警告

      local default = {
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return util.root_pattern(
            "compile_commands.json","compile_flags.txt",".clangd",".git"
          )(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
        end,
      }

      -- 你常用的幾個 LSP
      lspconfig.clangd.setup(vim.tbl_deep_extend("force", default, {
        cmd = { "clangd", "--offset-encoding=utf-16" },
      }))

      lspconfig.pyright.setup(default)

      lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", default, {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
          },
        },
      }))

      -- ✅ Verilog/SystemVerilog：verible-verilog-ls（新增）
      lspconfig.verible.setup(vim.tbl_deep_extend("force", default, {
        cmd = { "verible-verilog-ls" },                    -- Mason 安裝後就有
        filetypes = { "verilog", "systemverilog" },        -- .v / .sv / .svh
        root_dir = function(fname)
          return util.root_pattern(".git")(fname)
            or util.find_git_ancestor(fname)
            or util.path.dirname(fname)
        end,
      }))

      -- 如果你之後想用 hdl-checker（可選）：失敗就改用 verible
      -- lspconfig.hdl_checker.setup(vim.tbl_deep_extend("force", default, {
      --   cmd = { "hdl_checker", "--lsp" },
      --   filetypes = { "vhdl", "verilog", "systemverilog" },
      -- }))
      -- 提醒：hdl-checker 0.7.4 對 Python 3.12 不相容，Mason 安裝可能會失敗
    end,
  },
}

