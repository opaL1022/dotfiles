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

    -- 預設關閉，而且同步 buffer 狀態
    vim.b.copilot_enabled = 0
    pcall(vim.cmd, "silent! Copilot disable")

    vim.api.nvim_create_user_command("CopilotToggle", copilot_toggle, {})
    vim.api.nvim_create_user_command("CopilotEnable", function() copilot_set(true) end, {})
    vim.api.nvim_create_user_command("CopilotDisable", function() copilot_set(false) end, {})
  end,
}
