-- 自動括號 + 與 nvim-cmp 整合
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  dependencies = { "hrsh7th/nvim-cmp" }, -- 有 cmp 就會自動掛上事件；沒有也不會壞
  config = function()
    -- 基本設定（含 Treesitter 更聰明的語境判斷）
    require("nvim-autopairs").setup({
      check_ts = true,                      -- 需有 nvim-treesitter，沒有也能跑，只是少些判斷
      fast_wrap = {},                       -- 可用 <M-e> 快速包裹（預設開啟）
      disable_filetype = { "TelescopePrompt" },
      enable_check_bracket_line = true,
      ignored_next_char = "[%w%.]",         -- 例如數字或 . 後面不亂補
    })

    -- 與 nvim-cmp 整合：confirm 候選時自動補右括號/引號
    local ok_cmp, cmp = pcall(require, "cmp")
    if ok_cmp then
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end

    -- （可選）某些語言不想自動配對可在這裡關
    -- local npairs = require("nvim-autopairs")
    -- npairs.remove_rule('"', "lua")  -- 例：Lua 取消自動配對雙引號
  end,
}

