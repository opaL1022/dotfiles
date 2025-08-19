return {
  -- DAP 本體
  { "mfussenegger/nvim-dap" },

  -- 用 Mason 安裝/管理 DAP adapter（codelldb、debugpy）
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy" },
        automatic_installation = true,
      })

      local dap = require("dap")

      -- Python：debugpy（自動 by mason-nvim-dap）
      -- C/C++：codelldb（自動 by mason-nvim-dap）

      -- 極簡快捷鍵
      local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { silent = true }) end
      map("<F5>",  dap.continue)
      map("<F10>", dap.step_over)
      map("<F11>", dap.step_into)
      map("<F12>", dap.step_out)
      map("<leader>db", dap.toggle_breakpoint)
      map("<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end)
      map("<leader>dr", dap.repl.open)
      map("<leader>dl", dap.run_last)
    end,
  },
}

