local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Highlight on yank
-- ========================

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- close some filetypes with <q>
-- ========================
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "grug-far-history",
    "gitsigns-blame",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "noice",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      -- guard: buffer may have been closed/wiped before this scheduled
      -- callback runs, since vim.schedule defers to the next tick
      if not vim.api.nvim_buf_is_valid(event.buf) then
        return
      end
      vim.keymap.set({ "n", "x", "o" }, "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- go to last loc when opening a buffer
-- ========================

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
-- ========================

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Auto Format on file switching
-- ========================

local format_group = vim.api.nvim_create_augroup("AutoFormatOnLeave", { clear = true })
local needs_format = {}

local function is_excluded(bufnr)
  local bt = vim.bo[bufnr].buftype
  local ft = vim.bo[bufnr].filetype
  return bt ~= "" or ft == "help" or ft == "man"
end

local excluded_dirs = {
  vim.fn.expand("~/.src"),
  vim.fn.expand("~/.local"),
}

local function is_excluded_path(bufname)
  local full = vim.fn.fnamemodify(bufname, ":p")
  for _, dir in ipairs(excluded_dirs) do
    if vim.startswith(full, dir .. "/") then
      return true
    end
  end
  return false
end

local function should_format_buffer(bufnr)
  if not needs_format[bufnr] then
    return false
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if not vim.bo[bufnr].modifiable then
    return false
  end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return false
  end
  if is_excluded(bufnr) then
    return false
  end
  if is_excluded_path(bufname) then
    return false
  end
  return true
end

local function my_format(bufnr)
  if not should_format_buffer(bufnr) then
    return
  end
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    pcall(function()
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("undojoin")
        LazyVim.format({ force = true, buf = bufnr })
        needs_format[bufnr] = false
      end)
    end)
  end)
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = format_group,
  pattern = "*",
  callback = function(args)
    if is_excluded(args.buf) then
      return
    end
    needs_format[args.buf] = true
  end,
  desc = "Mark buffer as needing format on change",
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "VimLeavePre" }, {
  group = format_group,
  pattern = "*",
  callback = function(args)
    local mode = vim.api.nvim_get_mode().mode
    if mode == "i" or mode == "ic" or mode == "ix" then
      return
    end
    my_format(args.buf)
  end,
  desc = "Format and save modified buffer on leave",
})

-- Define highlight groups for different intervals
-- ========================
local themes = {
  light = {
    RelativeLineInterval_b = { bg = "#FFFCE2" },
    RelativeLineInterval_e = { bg = "#F2F2F2" },
    RelativeLineInterval_c = { bg = "#E4FFF6" },
    RelativeLineInterval_d = { bg = "#e6fce8" },
    RelativeLineInterval_f = { bg = "#F4EEFF" },
    RelativeLineInterval_g = { bg = "#FFF3EA" },
  },
  dark = {
    RelativeLineInterval_b = { bg = "#312F1D" },
    RelativeLineInterval_e = { bg = "#272932" },
    RelativeLineInterval_c = { bg = "#002A2D" },
    RelativeLineInterval_d = { bg = "#1D2B1F" },
    RelativeLineInterval_f = { bg = "#281F3D" },
    RelativeLineInterval_g = { bg = "#2D271F" },
  },
}
local distance_map = {
  [7] = "RelativeLineInterval_g",
  [14] = "RelativeLineInterval_c",
  [21] = "RelativeLineInterval_d",
  [28] = "RelativeLineInterval_f",
  [35] = "RelativeLineInterval_b",
  [42] = "RelativeLineInterval_e",
}
local ns = vim.api.nvim_create_namespace("relative_cursor_intervals")
local touched_bufs = {}
local redraw_pending = false
local generation = 0
local buf_active_win = {}

local function is_latte()
  return (vim.g.colors_name or ""):find("latte") ~= nil
end

local function apply_highlights()
  local palette = is_latte() and themes.light or themes.dark
  for group, opts in pairs(palette) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- NEW: keep buf_active_win up to date whenever a window becomes current
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local ok_buf, buf = pcall(vim.api.nvim_win_get_buf, win)
    if ok_buf and vim.api.nvim_buf_is_valid(buf) then
      buf_active_win[buf] = win
    end
  end,
})

local function do_redraw()
  local new_touched = {}

  -- First pass: collect every (buf -> set of windows currently showing it)
  local buf_wins = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.api.nvim_tabpage_is_valid(tab) then
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        if vim.api.nvim_win_is_valid(win) then
          local ok_buf, buf = pcall(vim.api.nvim_win_get_buf, win)
          if ok_buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            buf_wins[buf] = buf_wins[buf] or {}
            table.insert(buf_wins[buf], win)
          end
        end
      end
    end
  end

  for buf, wins in pairs(buf_wins) do
    -- Prefer the last-active window for this buffer if it's still showing it;
    -- otherwise fall back to whichever window is currently showing it.
    local source_win = buf_active_win[buf]
    local source_valid = false
    if source_win and vim.api.nvim_win_is_valid(source_win) then
      local ok, wbuf = pcall(vim.api.nvim_win_get_buf, source_win)
      if ok and wbuf == buf then
        source_valid = true
      end
    end
    if not source_valid then
      source_win = wins[1]
      buf_active_win[buf] = source_win
    end

    local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, source_win)
    if ok_cursor then
      local total = vim.api.nvim_buf_line_count(buf)
      if total > 0 then
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        local cursor_line = cursor[1]
        for line = 1, total do
          local hl = distance_map[math.abs(line - cursor_line)]
          if hl then
            pcall(vim.api.nvim_buf_set_extmark, buf, ns, line - 1, 0, {
              end_line = line,
              hl_group = hl,
              hl_eol = true,
              priority = 90,
            })
          end
        end
        new_touched[buf] = true
      end
    end
  end

  for buf in pairs(touched_bufs) do
    if not new_touched[buf] and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end
  touched_bufs = new_touched
end

-- Coalesce bursts of events into a single redraw on the next tick.
local function redraw_all()
  if redraw_pending then
    return
  end
  redraw_pending = true
  local my_gen = generation
  vim.schedule(function()
    redraw_pending = false
    if my_gen ~= generation then
      return
    end
    do_redraw()
  end)
end

local function bump_and_redraw()
  generation = generation + 1
  redraw_all()
end

apply_highlights()

local function redraw_burst()
  bump_and_redraw()
  vim.schedule(function()
    bump_and_redraw()
  end)
  vim.defer_fn(function()
    bump_and_redraw()
  end, 30)
  vim.defer_fn(function()
    bump_and_redraw()
  end, 120)
end

vim.api.nvim_create_autocmd(
  { "BufEnter", "BufWinEnter", "WinEnter", "WinNew", "WinClosed", "TabEnter", "VimResized" },
  {
    callback = redraw_burst,
  }
)

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "CursorHold", "CursorHoldI" }, {
  callback = function()
    redraw_all()
  end,
})

vim.schedule(bump_and_redraw)

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    apply_highlights()
  end,
})

-- ========================

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      local ok, backends = pcall(require, "aerial.backends")
      if not ok or not backends.get(bufnr) then
        return
      end
      require("aerial").refetch_symbols(bufnr)
    end)
  end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--   group = augroup("man_unlisted"),
--   pattern = { "man", "help" },
--   callback = function(event)
--     local buf = vim.api.nvim_get_current_buf()
--     vim.bo[buf].buflisted = true
--     vim.bo[buf].buftype = ""
--     vim.bo[buf].bufhidden = "hide"
--
--     pcall(vim.keymap.del, "n", "j", { buffer = true })
--     pcall(vim.keymap.del, "n", "k", { buffer = true })
--   end,
-- })
