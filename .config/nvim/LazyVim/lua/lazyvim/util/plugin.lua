local Meta = require("lazy.core.meta")
local Plugin = require("lazy.core.plugin")

---@class lazyvim.util.plugin
local M = {}

---@type string[]
M.core_imports = {}
M.handle_defaults = true

M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

function M.save_core()
  if vim.v.vim_did_enter == 1 then
    return
  end
  M.core_imports = vim.deepcopy(require("lazy.core.config").spec.modules)
end

function M.setup()
  M.lazy_file()
  table.insert(package.loaders, function(module)
    if M.deprecated_modules[module] then
      LazyVim.warn(
        ("`%s` is no longer included by default in **LazyVim**.\nPlease install the `%s` extra if you still want to use it."):format(
          module,
          M.deprecated_modules[module]
        ),
        { title = "LazyVim" }
      )
      return function() end
    end
  end)
end

function M.extra_idx(name)
  local Config = require("lazy.core.config")
  for i, extra in ipairs(Config.spec.modules) do
    if extra == "lazyvim.plugins.extras." .. name then
      return i
    end
  end
end

function M.lazy_file()
  -- Add support for the LazyFile event
  local Event = require("lazy.core.handler.event")

  Event.mappings.LazyFile = { id = "LazyFile", event = M.lazy_file_events }
  Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end

return M
