return {
  {
    "andersevenrud/nvim_context_vt",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim_context_vt").setup({
        prefix = "// ",
        highlight = "Comment",
      })
    end,
  },
}
