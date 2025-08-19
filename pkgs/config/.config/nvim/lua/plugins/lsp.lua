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

      -- 停掉任何已啟動的 clangd（防重複）
      for _, c in ipairs(vim.lsp.get_clients()) do
        if c.name == "clangd" then c.stop(true) end
      end

      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      local on_attach = function(_, bufnr)
        local o = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
        vim.keymap.set("n", "K",  vim.lsp.buf.hover, o)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
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

      -- LspAttach：若有非 UTF-16 的 clangd 混入，保留正確者
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "clangd" then return end
          local keep
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if c.name == "clangd" and c.config and c.config.cmd then
              local cmd = table.concat(c.config.cmd, " ")
              if cmd:find("%-%-offset%-encoding=utf%-16") then keep = c.id end
            end
          end
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if c.name == "clangd" and c.id ~= keep then c.stop(true) end
          end
        end,
      })
    end,
  },
}

