return {
  -- 通知視窗（右上角）
  {
    "rcarriga/nvim-notify",
    lazy = false,             -- 讓它在啟動期也可用
    priority = 1000,
    opts = {
      stages = "fade_in_slide_out",
      timeout = 2000,         -- 停留時間
      top_down = true,       -- 右上由下往上疊
      render = "compact",
      fps = 60,
      background_colour = "#000000",
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
      -- 啟動早期錯誤回放（搭配下面的 startup shim）
      if vim.g.__startup_errs then
        for _, m in ipairs(vim.g.__startup_errs) do
          notify(m, vim.log.levels.ERROR, { title = "Startup Error" })
        end
        vim.g.__startup_errs = nil
      end
    end,
  },

  -- 把 Neovim 的訊息導向通知
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "rcarriga/nvim-notify", "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        message  = { enabled = true, view = "notify" }, -- LSP 訊息 -> notify
        progress = { enabled = false }, -- LSP 進度
        hover    = { enabled = false },                 -- 不改 hover 視圖
        signature= { enabled = false },
      },
      views = {
        notify = { replace = false }, -- 不覆蓋同 key，避免洗掉上條訊息
      },
      routes = {
        -- Error / Warning 類訊息 -> 右上通知
        { filter = { error = true },               view = "notify" },
        { filter = { warning = true },             view = "notify" },
        { filter = { event = "msg_show", kind = "emsg" }, view = "notify" }, -- "Error executing lua" 等
        { filter = { event = "msg_show", kind = "wmsg" }, view = "notify" },

        -- 一般 notify() 也走右上
        { filter = { event = "notify" },           view = "notify" },

        -- 噪音降低：像 "written", yank 訊息走 mini 或略過
        { filter = { event = "msg_show", kind = "echo" , find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", kind = "echo" , find = "yanked"  }, opts = { skip = true } },
        { filter = { event = "msg_showmode" }, view = "mini" }, -- -- INSERT -- 之類
        { filter = { event = "msg_history_show" }, opts = { skip = true } },
      },
      presets = {
        bottom_search = true,   -- / 搜尋輸入在底部（習慣）
        command_palette = false,
        long_message_to_split = false,
        lsp_doc_border = true,
      },
    },
  },
}

