-- 例：~/.config/nvim/lua/plugins/copilot.lua  (路徑依你專案而定)
return {
  "github/copilot.vim",
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.api.nvim_set_keymap(
      "i",
      "<C-J>",
      'copilot#Accept("<CR>")',
      { silent = true, expr = true, noremap = true }
    )

    -- ========= Copilot toggle logic =========
    local function notify(msg, level)
      pcall(vim.notify, msg, level or vim.log.levels.INFO)
    end

    local function copilot_set(enabled)
      vim.b.copilot_enabled = enabled and 1 or 0
      if enabled then
        pcall(vim.cmd, "Copilot enable")
        notify("Copilot: ON", vim.log.levels.INFO)
      else
        pcall(vim.cmd, "Copilot disable")
        notify("Copilot: OFF", vim.log.levels.WARN)
      end
    end

    local function copilot_toggle()
      local cur = vim.b.copilot_enabled
      local enabled_now = (cur == nil) and true or (cur == 1)
      copilot_set(not enabled_now)
    end

    -- 提供 :CopilotToggle / :CopilotEnable / :CopilotDisable
    vim.api.nvim_create_user_command("CopilotToggle", copilot_toggle, {})
    vim.api.nvim_create_user_command("CopilotEnable", function() copilot_set(true) end, {})
    vim.api.nvim_create_user_command("CopilotDisable", function() copilot_set(false) end, {})
  end,
}
