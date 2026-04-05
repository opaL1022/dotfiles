-- LSP + nvim-cmp（補全鍵：<C-Space>）
return {
  -- 只用 mason 當安裝器（不使用 mason-lspconfig）
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
      "kdheepak/cmp-latex-symbols",
      "hrsh7th/cmp-omni",
    },
    config = function()
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),

          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ select = false })
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<Tab>"] = cmp.mapping(function(fb)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fb()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fb)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fb()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "latex_symbols" },
          {
            name = "omni",
            option = {
              disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },
            },
          },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- 使用 Neovim 0.11 官方 LSP API（不再使用 lspconfig.setup）
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      if vim.g.__lsp_setup_done then
        return
      end
      vim.g.__lsp_setup_done = true

      --------------------------------------------------------------------
      -- 簡易版 :LspInfo（不依賴 nvim-lspconfig）
      --------------------------------------------------------------------
      vim.api.nvim_create_user_command("LspInfo", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })

        if vim.tbl_isempty(clients) then
          print("No LSP attached to current buffer")
          return
        end

        for _, c in ipairs(clients) do
          print(string.format("[%d] %s  (root: %s)", c.id, c.name, c.config.root_dir or "N/A"))
        end
      end, {})

      --------------------------------------------------------------------
      -- 診斷視覺設定
      --------------------------------------------------------------------
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      --------------------------------------------------------------------
      -- 共同 on_attach / capabilities
      --------------------------------------------------------------------
      local on_attach = function(_, bufnr)
        local o = { noremap = true, silent = true, buffer = bufnr }

        -- hover
        vim.keymap.set("n", "K", vim.lsp.buf.hover, o)

        -- Telescope-based LSP navigation
        vim.keymap.set("n", "gd", function()
          require("telescope.builtin").lsp_definitions()
        end, vim.tbl_extend("force", o, { desc = "Go to Definition" }))

        vim.keymap.set("n", "grr", function()
          require("telescope.builtin").lsp_references()
        end, vim.tbl_extend("force", o, { desc = "Go to References" }))

        vim.keymap.set("n", "gri", function()
          require("telescope.builtin").lsp_implementations()
        end, vim.tbl_extend("force", o, { desc = "Go to Implementation" }))

        vim.keymap.set("n", "grt", function()
          require("telescope.builtin").lsp_type_definitions()
        end, vim.tbl_extend("force", o, { desc = "Go to Type Definition" }))

        vim.keymap.set("n", "grn", vim.lsp.buf.rename, vim.tbl_extend("force", o, { desc = "Rename Symbol" }))
        vim.keymap.set("n", "gra", vim.lsp.buf.code_action, vim.tbl_extend("force", o, { desc = "Code Action" }))

        -- diagnostics
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, o)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, o)
      end
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.offsetEncoding = { "utf-16" } -- for clangd

      --------------------------------------------------------------------
      -- 根目錄解析：同時支援 bufnr（number）與路徑（string）
      --------------------------------------------------------------------
      local function normalize_path(arg)
        if type(arg) == "number" then
          return vim.api.nvim_buf_get_name(arg)
        elseif type(arg) == "string" and arg ~= "" then
          return arg
        else
          return vim.api.nvim_buf_get_name(0)
        end
      end

      local function root_by_markers(arg, markers)
        local start = normalize_path(arg)
        local dir = vim.fs.dirname(start)
        local found = vim.fs.find(markers, { upward = true, path = dir })[1]
        return (found and vim.fs.dirname(found)) or dir
      end

      local function make_workspace_name(root)
        local path = root or vim.loop.cwd() or "default"
        return path:gsub("[/\\:]", "_")
      end

      --------------------------------------------------------------------
      -- helper：註冊 server + 自動 FileType 啟動
      --------------------------------------------------------------------
      local function setup_server(name, config)
        vim.lsp.config[name] = config

        vim.api.nvim_create_autocmd("FileType", {
          pattern = config.filetypes or {},
          callback = function(args)
            local existing = vim.lsp.get_clients({
              bufnr = args.buf,
              name = name,
            })
            if not vim.tbl_isempty(existing) then
              return
            end

            local cfg = vim.tbl_deep_extend("force", {}, config)

            if type(cfg.root_dir) == "function" then
              cfg.root_dir = cfg.root_dir(args.buf)
            end

            cfg.name = cfg.name or name
            cfg.bufnr = args.buf

            vim.lsp.start(cfg)
          end,
        })
      end

      --------------------------------------------------------------------
      -- 定義各個 server
      --------------------------------------------------------------------

      -- C/C++（clangd）
      setup_server("clangd", {
        cmd = { "clangd", "--offset-encoding=utf-16" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_dir = function(arg)
          return root_by_markers(arg, {
            "compile_commands.json",
            "compile_flags.txt",
            ".clangd",
            ".git",
          })
        end,
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Python（pyright）
      setup_server("pyright", {
        cmd = { vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_dir = function(arg)
          local path = normalize_path(arg)
          local dir = vim.fs.dirname(path)

          local found = vim.fs.find({
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            ".git",
          }, { upward = true, path = dir })[1]

          return found and vim.fs.dirname(found) or dir
        end,
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          pyright = {
            disableLanguageServices = false,
          },
          python = {
            analysis = {
              diagnosticMode = "openFilesOnly",
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
              reportMissingImports = "none",
              typeCheckingMode = "off",
            },
          },
        },
      })

      -- Lua（lua_ls）
      setup_server("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_dir = function(arg)
          return root_by_markers(arg, {
            ".luarc.json",
            ".git",
          })
        end,
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
          },
        },
      })

      --------------------------------------------------------------------
      -- Java（jdtls + nvim-jdtls + DAP）
      --------------------------------------------------------------------
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function(args)
          local ok_jdtls, jdtls = pcall(require, "jdtls")
          if not ok_jdtls then
            vim.notify("nvim-jdtls not found", vim.log.levels.ERROR)
            return
          end

          local existing = vim.lsp.get_clients({ bufnr = args.buf, name = "jdtls" })
          if not vim.tbl_isempty(existing) then
            return
          end

          local root = root_by_markers(args.buf, {
            "build.gradle",
            "build.gradle.kts",
            "settings.gradle",
            "settings.gradle.kts",
            "pom.xml",
            ".git",
          })

          local workspace_name = make_workspace_name(root)
          local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. workspace_name

          local mason = vim.fn.stdpath("data") .. "/mason/packages"
          local bundles = {}

          local java_debug = vim.fn.glob(
            mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
            true,
            true
          )
          vim.list_extend(bundles, java_debug)

          local cfg = {
            cmd = { "jdtls", "-data", workspace_dir },
            root_dir = root,
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              on_attach(client, bufnr)
              jdtls.setup_dap({ hotcodereplace = "auto" })
            end,
            init_options = {
              bundles = bundles,
            },
          }

          jdtls.start_or_attach(cfg)

          --pcall(function()
          --  require("jdtls.dap").setup_dap_main_class_configs()
          --end)
        end,
      })

      --------------------------------------------------------------------
      -- Dart auto format on save
      --------------------------------------------------------------------
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.dart",
        callback = function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          for _, c in ipairs(clients) do
            if c.name == "dartls" then
              vim.lsp.buf.format({ async = false })
              return
            end
          end
        end,
      })
    end,
  },
}
