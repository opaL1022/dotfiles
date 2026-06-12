return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.api.nvim_set_hl(0, "RainbowDelimiterRed",    { fg = "#E95678" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#FAB795" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterBlue",   { fg = "#26BBD9" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#B877DB" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterCyan",   { fg = "#59E1E3" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterGreen",  { fg = "#29D398" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#FAB28E" })

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
          "RainbowDelimiterGreen",
          "RainbowDelimiterOrange",
        },
      }
    end,
  },
}
