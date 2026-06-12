return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          use_treesitter = true,
          notify = false,
          delay = 0,
          duration = 0,
          style = {
            { fg = "#FAC29A" },
          },
        },

        indent = {
          enable = false,
        },

        line_num = {
          enable = false,
        },

        blank = {
          enable = false,
        },
      })
    end,
  },
}
