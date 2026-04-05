return {
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true

      vim.keymap.set(
        "i",
        "<C-J>",
        'copilot#Accept("<CR>")',
        { silent = true, expr = true, noremap = true }
      )

      local function notify(msg, level)
        pcall(vim.notify, msg, level or vim.log.levels.INFO)
      end

      local function copilot_set(enabled)
        vim.b.copilot_enabled = enabled and 1 or 0
        if enabled then
          pcall(vim.cmd, "silent! Copilot enable")
          notify("Copilot: ON", vim.log.levels.INFO)
        else
          pcall(vim.cmd, "silent! Copilot disable")
          notify("Copilot: OFF", vim.log.levels.WARN)
        end
      end

      local function copilot_toggle()
        local enabled_now = (vim.b.copilot_enabled == 1)
        copilot_set(not enabled_now)
      end

      vim.b.copilot_enabled = 0
      pcall(vim.cmd, "silent! Copilot disable")

      vim.api.nvim_create_user_command("CopilotToggle", copilot_toggle, {})
      vim.api.nvim_create_user_command("CopilotEnable", function() copilot_set(true) end, {})
      vim.api.nvim_create_user_command("CopilotDisable", function() copilot_set(false) end, {})
    end,
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
    },
    build = "make tiktoken",
    config = function()
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")

      chat.setup({
        system_prompt = [[
You are a coding assistant.
Always reply in English.
Be clear and concise.
When explaining code, describe:
1. its purpose
2. control flow
3. important variables and functions
4. possible issues or improvements
        ]],
      })

      vim.keymap.set("v", "<leader>ce", function()
        chat.ask("Explain this code.", {
          selection = select.visual,
        })
      end, { desc = "Copilot Explain Selection" })

      vim.keymap.set("v", "<leader>cr", function()
        chat.ask("Review this code.", {
          selection = select.visual,
        })
      end, { desc = "Copilot Review Selection" })

      vim.keymap.set("v", "<leader>cf", function()
        chat.ask("Fix this code and explain the changes.", {
          selection = select.visual,
        })
      end, { desc = "Copilot Fix Selection" })

      vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChat<cr>", { desc = "Open Copilot Chat" })
    end,
  },
}
