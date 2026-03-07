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
          }, {
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },

    -- 使用 Neovim 0.11 官方 LSP API（不再使用 lspconfig.setup）
    {
        -- 這個條目只是個容器；不依賴 lspconfig
        "nvim-lua/plenary.nvim",
        lazy = false, -- 確保一啟動 Neovim 就載入並執行 config
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

                vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
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

            --------------------------------------------------------------------
            -- helper：註冊 server + 自動 FileType 啟動
            --------------------------------------------------------------------
            local function setup_server(name, config)
                -- 保存 config（給 :checkhealth / 其他工具看）
                vim.lsp.config[name] = config

                -- FileType 時手動 vim.lsp.start
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = config.filetypes or {},
                    callback = function(args)
                        -- 如果這個 buffer 已經有同名 client，就不要重複啟
                        local existing = vim.lsp.get_clients({
                            bufnr = args.buf,
                            name = name,
                        })
                        if not vim.tbl_isempty(existing) then
                            return
                        end

                        local cfg = vim.tbl_deep_extend("force", {}, config)

                        -- 算 root_dir（如果有 root_dir 函數）
                        if type(cfg.root_dir) == "function" then
                            local root = cfg.root_dir(args.buf)
                            cfg.root_dir = root
                        end

                        -- 確保有 name / bufnr
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
                cmd = { "pyright-langserver", "--stdio" },
                filetypes = { "python" },
                root_dir = function(arg)
                    return root_by_markers(arg, {
                        "pyproject.toml",
                        "setup.py",
                        "setup.cfg",
                        "requirements.txt",
                        ".git",
                    })
                end,
                capabilities = capabilities,
                on_attach = on_attach,
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

            -- Java（jdtls）
            setup_server("jdtls", {
                cmd = { "jdtls" }, -- 你已用 Mason 裝了，且 PATH 有 mason/bin
                filetypes = { "java" },
                root_dir = function(arg)
                    return root_by_markers(arg, {
                        "build.gradle",
                        "build.gradle.kts",
                        "settings.gradle",
                        "settings.gradle.kts",
                        "pom.xml",
                        ".git",
                    })
                end,
                capabilities = capabilities,
                on_attach = on_attach,

                -- jdtls 很需要每個專案一個 workspace，避免跨專案互相污染
                -- Neovim 0.11 的 vim.lsp.start 會把 config 共享，所以我們在啟動時動態塞 -data
                on_init = function(client)
                    -- no-op; keep here if you later want to tweak init behavior
                end,
            })

            --------------------------------------------------------------------
            -- 針對 jdtls：每次進到 java buffer 時，重建 cmd 加上 -data workspace
            -- （因為 jdtls 沒給 -data 會用預設 workspace，常常出事）
            --------------------------------------------------------------------
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function(args)
                    -- 若已經有 jdtls client attach，就不做任何事
                    local existing = vim.lsp.get_clients({ bufnr = args.buf, name = "jdtls" })
                    if not vim.tbl_isempty(existing) then
                        return
                    end

                    -- 基底 config（拿我們剛剛存的）
                    local base = vim.lsp.config["jdtls"]
                    if not base then
                        return
                    end

                    -- 算 root
                    local root = base.root_dir
                    if type(root) == "function" then
                        root = root(args.buf)
                    end

                    local project_name = vim.fn.fnamemodify(root or vim.fn.getcwd(), ":t")
                    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

                    local cfg = vim.tbl_deep_extend("force", {}, base)
                    cfg.root_dir = root
                    cfg.name = "jdtls"
                    cfg.bufnr = args.buf

                    -- 重要：把 -data workspace 加進去
                    cfg.cmd = { "jdtls", "-data", workspace_dir }

                    vim.lsp.start(cfg)
                end,
            })
            --------------------------------------------------------------------
            -- Dart auto format on save
            --------------------------------------------------------------------
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.dart",
                callback = function()
                    -- 確保有 dart LSP attach 才 format
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
