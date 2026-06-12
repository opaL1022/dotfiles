return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 0,
      expand = 1,
      notify = false,
      win = {
        border = "rounded",
        wo = {
          winblend = 12,
        },
      },
      plugins = {
        spelling = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      vim.api.nvim_set_hl(0, "WhichKeyNormal", {
        fg = "#D5D8DA",
        bg = "#1C1E26",
      })

      vim.api.nvim_set_hl(0, "WhichKeyBorder", {
        fg = "#2E303E",
        bg = "#1C1E26",
      })

      vim.api.nvim_set_hl(0, "WhichKeyTitle", {
        fg = "#FAB28E",
        bg = "#1C1E26",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "WhichKeyDesc", {
        fg = "#D5D8DA",
        bg = "#1C1E26",
      })

      vim.api.nvim_set_hl(0, "WhichKeyGroup", {
        fg = "#B877DB",
        bg = "#1C1E26",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "WhichKeySeparator", {
        fg = "#BBBBBB",
        bg = "#1C1E26",
      })

      vim.api.nvim_set_hl(0, "WhichKeyValue", {
        fg = "#BBBBBB",
        bg = "#1C1E26",
        italic = true,
      })

      vim.api.nvim_set_hl(0, "WhichKeyIcon", {
        fg = "#FAB28E",
        bg = "#1C1E26",
      })
    end,
  },
}
