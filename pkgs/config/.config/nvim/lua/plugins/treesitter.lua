-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
    opts = {
      -- 你常用的語言；需要再加就加入字串
      ensure_installed = { "c", "cpp", "lua", "python", "bash", "javascript", "typescript", "vim", "vimdoc", "query", "markdown", "markdown_inline", "verilog" },
      auto_install = true,      -- 開檔時若缺 parser 會自動安裝
      sync_install = false,     -- 背景安裝，避免卡住 UI
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false, -- 避免重複高亮
        -- 大檔自動關閉（> 500 KB）
        disable = function(lang, buf)
          local max = 500 * 1024
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max then
            return true
          end
          return false
        end,
      },
      indent = {
        enable = true,
        disable = { "dart" },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          node_decremental = "grm",
          scope_incremental = "grc",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}

