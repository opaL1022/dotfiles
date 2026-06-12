local compat = require("config.treesitter_compat")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      compat.apply_shared_queries()

      local ok, nts = pcall(require, "nvim-treesitter")
      if ok and nts.setup and nts.install then
        compat.modern_setup()
        return
      end

      require("nvim-treesitter.configs").setup(compat.legacy_opts())
    end,
  },
}
