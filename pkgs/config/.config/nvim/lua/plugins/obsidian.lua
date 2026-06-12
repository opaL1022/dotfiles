return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "notes",
          path = "~/Documents/notes",
        },
      },

      daily_notes = {
        folder = "daily",
      },

      templates = {
        folder = "templates",
      },
    },
  },
}
