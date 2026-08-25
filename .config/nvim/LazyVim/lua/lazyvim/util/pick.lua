---@class lazyvim.util.pick
---@overload fun(command:string, opts?:lazyvim.util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

---@class lazyvim.util.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean

---@class LazyPicker
---@field name string
---@field open fun(command:string, opts?:lazyvim.util.pick.Opts)
---@field commands table<string, string>

---@type LazyPicker?
M.picker = nil

---@param picker LazyPicker
function M.register(picker)
  -- this only happens when using :LazyExtras
  -- so allow to get the full spec
  if vim.v.vim_did_enter == 1 then
    return true
  end

  if M.picker and M.picker.name ~= picker.name then
    LazyVim.warn(
      "`LazyVim.pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`"
    )
    return false
  end
  M.picker = picker
  return true
end

---@param command? string
---@param opts? lazyvim.util.pick.Opts
function M.open(command, opts)
  if not M.picker then
    return LazyVim.error("LazyVim.pick: picker not set")
  end

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == "boolean" then
    LazyVim.warn("LazyVim.pick: opts.cwd should be a string or nil")
    opts.cwd = nil
  end

  if not opts.cwd and opts.root == false then
    opts.cwd = vim.uv.cwd()
  elseif not opts.cwd then
    local root = LazyVim.root({ buf = opts.buf })
    local cwd = vim.uv.cwd()
    local buf_dir = vim.fn.expand("%:p:h")
    opts.cwd = (root ~= cwd) and root or buf_dir
  end

  command = M.picker.commands[command] or command
  M.picker.open(command, opts)
end

local ignore_commands = { "grep", "grep_word", "live_grep", "grep_buffers", "undo", "notifications" }
local function is_ignored(command)
  if type(command) ~= "string" then
    return false
  end
  for _, name in ipairs(ignore_commands) do
    if command == name then
      return true
    end
  end
  return false
end

function M.wrap(command, opts)
  opts = opts or {}
  return function()
    local final_opts = vim.deepcopy(opts)
    local final_command = command
    local mode = vim.fn.mode()
    local in_visual = mode == "v" or mode == "V" or mode == "\22"
    local ignored = is_ignored(final_command)
    local pattern

    if in_visual then
      if final_command == "grep" then
        -- visual selection + grep: let grep_word handle it itself
        final_command = "grep_word"
      elseif final_command ~= "grep_word" then
        local visual = Snacks.picker.util.visual()
        local visual_pattern = visual and visual.text
        if visual_pattern then
          final_opts.pattern = visual_pattern
        end
      end
    elseif not ignored then
      pattern = vim.fn.expand("<cword>")
    end

    if pattern and pattern ~= "" then
      final_opts.pattern = pattern
      local user_on_show = final_opts.on_show
      final_opts.on_show = function(picker)
        if user_on_show then
          user_on_show(picker)
        end
        vim.cmd("stopinsert")
        vim.cmd("normal! v$gH")
      end
    end
    if type(final_command) == "function" then
      final_command(final_opts)
    else
      LazyVim.pick.open(final_command, final_opts)
    end
  end
end

function M.config_files()
  return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
