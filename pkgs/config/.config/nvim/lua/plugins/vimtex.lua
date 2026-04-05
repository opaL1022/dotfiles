return {
  "lervag/vimtex",
  ft = { "tex", "plaintex" },
  init = function()
    -- localleader
    vim.g.maplocalleader = "\\"

    -- 使用 latexmk
    vim.g.vimtex_compiler_method = "latexmk"

    -- 強制 latexmk 使用 xelatex
    vim.g.vimtex_compiler_latexmk_engines = {
      ["_"] = "-xelatex",
    }

    -- latexmk 其他參數
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }

    -- PDF viewer
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_view_forward_search_on_start = 1
  end,
}
