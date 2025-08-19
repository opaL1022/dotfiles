-- ~/.config/nvim/lua/plugins/core.lua
return {
  -- lualine（UI 狀態列）
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = "",
          globalstatus = true,
        },
      })
    end,
  },
}

