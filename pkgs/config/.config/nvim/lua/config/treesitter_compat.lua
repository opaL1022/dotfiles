local M = {}

local ensure_installed = {
  "c",
  "cpp",
  "lua",
  "python",
  "bash",
  "javascript",
  "typescript",
  "vim",
  "vimdoc",
  "query",
  "markdown",
  "markdown_inline",
  "latex",
  "bibtex",
  "json",
  "html",
  "css",
}

local MAX_HIGHLIGHT_FILESIZE = 500 * 1024
local selection_history = {}

local function is_large_file(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end

  local ok, stats = pcall(vim.loop.fs_stat, name)
  return ok and stats and stats.size > MAX_HIGHLIGHT_FILESIZE or false
end

local function get_lang(bufnr)
  local ft = vim.bo[bufnr].filetype
  if ft == "" then
    return nil
  end

  return vim.treesitter.language.get_lang(ft) or ft
end

local function has_parser(lang)
  if not lang then
    return false
  end

  return pcall(vim.treesitter.language.add, lang)
end

local function maybe_install_parser(lang)
  if has_parser(lang) then
    return true
  end

  local ok, nts = pcall(require, "nvim-treesitter")
  if ok and nts.install then
    pcall(nts.install, { lang })
  end

  return false
end

local function set_markdown_injections()
  vim.treesitter.query.set(
    "markdown",
    "injections",
    [[
(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
]]
  )
end

local function maybe_enable_treesitter(bufnr)
  local lang = get_lang(bufnr)
  if not lang then
    return
  end

  local parser_ready = maybe_install_parser(lang)
  if not parser_ready then
    return
  end

  if not is_large_file(bufnr) then
    pcall(vim.treesitter.start, bufnr, lang)
  else
    pcall(vim.treesitter.stop, bufnr)
  end

end

local function get_vim_range(range, bufnr)
  local srow, scol, erow, ecol = unpack(range)
  srow = srow + 1
  scol = scol + 1
  erow = erow + 1

  if ecol == 0 then
    erow = erow - 1
    if bufnr == 0 then
      ecol = vim.fn.col({ erow, "$" }) - 1
    else
      local line = vim.api.nvim_buf_get_lines(bufnr, erow - 1, erow, false)[1] or ""
      ecol = math.max(#line, 1)
    end
  end

  return srow, scol, erow, ecol
end

local function update_selection(bufnr, node)
  if not node then
    return
  end

  local start_row, start_col, end_row, end_col = get_vim_range({ vim.treesitter.get_node_range(node) }, bufnr)
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "v" then
    vim.api.nvim_cmd({ cmd = "normal", bang = true, args = { "v" } }, {})
  end

  vim.api.nvim_win_set_cursor(0, { start_row, start_col - 1 })
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
end

local function visual_selection_range()
  local _, csrow, cscol = unpack(vim.fn.getpos("v"))
  local _, cerow, cecol = unpack(vim.fn.getpos("."))

  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow, cscol, cerow, cecol
  end

  return cerow, cecol, csrow, cscol
end

local function range_matches(node)
  local csrow, cscol, cerow, cecol = visual_selection_range()
  local srow, scol, erow, ecol = get_vim_range({ vim.treesitter.get_node_range(node) }, 0)
  return srow == csrow and scol == cscol and erow == cerow and ecol == cecol
end

local function parse_current_buffer(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok then
    return nil
  end

  parser:parse(true)
  return parser
end

local function get_current_node(bufnr)
  local ok, node = pcall(vim.treesitter.get_node, {
    bufnr = bufnr,
    ignore_injections = false,
  })
  if ok then
    return node
  end
end

local function get_root_for_position(root_parser, row, col)
  local lang_tree = root_parser:language_for_range({ row, col, row, col })
  while lang_tree do
    for _, tree in pairs(lang_tree:trees()) do
      local root = tree:root()
      if root and vim.treesitter.is_in_node_range(root, row, col) then
        return root, lang_tree
      end
    end

    if lang_tree == root_parser then
      break
    end

    local ok, parent = pcall(function()
      return lang_tree:parent()
    end)
    if not ok then
      break
    end
    lang_tree = parent
  end
end

local function get_scope_parent(node, bufnr, root_parser)
  local start_row, start_col = vim.treesitter.get_node_range(node)
  local root, lang_tree = get_root_for_position(root_parser, start_row, start_col)
  if not root or not lang_tree then
    return node
  end

  local ok, query = pcall(vim.treesitter.query.get, lang_tree:lang(), "locals")
  if not ok or not query then
    return node
  end

  local root_start_row, _, root_end_row, _ = root:range()
  local scopes = {}
  for id, captured_node in query:iter_captures(root, bufnr, root_start_row, root_end_row + 1) do
    if query.captures[id] == "local.scope" then
      scopes[captured_node] = true
    end
  end

  local iter_node = node:parent() or node
  while iter_node and not scopes[iter_node] do
    iter_node = iter_node:parent()
  end

  return iter_node or node
end

local function get_range_node(bufnr, root_parser)
  local csrow, cscol, cerow, cecol = visual_selection_range()
  return root_parser:named_node_for_range(
    { csrow - 1, cscol - 1, cerow - 1, cecol },
    { ignore_injections = false }
  )
end

function M.init_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = parse_current_buffer(bufnr)
  if not parser then
    return
  end

  local node = get_current_node(bufnr)
  if not node then
    return
  end

  selection_history[bufnr] = { node }
  update_selection(bufnr, node)
end

local function select_incremental(parent_fn)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    local parser = parse_current_buffer(bufnr)
    if not parser then
      return
    end

    local history = selection_history[bufnr]
    if not history or #history == 0 or not range_matches(history[#history]) then
      local node = get_range_node(bufnr, parser)
      if not node then
        return
      end

      selection_history[bufnr] = { node }
      update_selection(bufnr, node)
      return
    end

    local current = history[#history]
    while current do
      local parent = parent_fn(current, bufnr, parser)
      if not parent or parent == current then
        local replacement = get_range_node(bufnr, parser)
        if replacement and replacement ~= current then
          table.insert(history, replacement)
          update_selection(bufnr, replacement)
        end
        return
      end

      current = parent
      if not range_matches(current) then
        table.insert(history, current)
        update_selection(bufnr, current)
        return
      end
    end
  end
end

function M.node_incremental()
  return select_incremental(function(node)
    return node:parent() or node
  end)()
end

function M.scope_incremental()
  return select_incremental(function(node, bufnr, parser)
    return get_scope_parent(node, bufnr, parser)
  end)()
end

function M.node_decremental()
  local bufnr = vim.api.nvim_get_current_buf()
  local history = selection_history[bufnr]
  if not history or #history < 2 then
    return
  end

  table.remove(history)
  update_selection(bufnr, history[#history])
end

local function set_incremental_selection_keymaps()
  vim.keymap.set("n", "gnn", M.init_selection, { silent = true, desc = "Start treesitter selection" })
  vim.keymap.set("x", "grn", M.node_incremental, { silent = true, desc = "Expand selection to parent node" })
  vim.keymap.set("x", "grc", M.scope_incremental, { silent = true, desc = "Expand selection to scope" })
  vim.keymap.set("x", "grm", M.node_decremental, { silent = true, desc = "Shrink selection" })
end

function M.modern_setup()
  local nts = require("nvim-treesitter")
  nts.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })
  nts.install(ensure_installed)

  set_markdown_injections()
  set_incremental_selection_keymaps()

  local group = vim.api.nvim_create_augroup("treesitter-main-compat", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      maybe_enable_treesitter(args.buf)
    end,
  })
end

function M.legacy_opts()
  return {
    ensure_installed = ensure_installed,
    auto_install = true,
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = function(_, buf)
        return is_large_file(buf)
      end,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        node_decremental = "grm",
        scope_incremental = "grc",
      },
    },
  }
end

function M.apply_shared_queries()
  set_markdown_injections()
end

return M
