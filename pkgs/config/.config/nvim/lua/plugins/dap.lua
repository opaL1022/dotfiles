return {
  { "mfussenegger/nvim-dap" },

  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy" },
        automatic_installation = true,
      })

      local dap = require("dap")

      local map = function(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { silent = true })
      end

      map("<F5>", dap.continue)
      map("<F10>", dap.step_over)
      map("<F11>", dap.step_into)
      map("<F12>", dap.step_out)
      map("<leader>db", dap.toggle_breakpoint)
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end)
      map("<leader>dr", dap.repl.open)
      map("<leader>dl", dap.run_last)
    end,
  },
}
