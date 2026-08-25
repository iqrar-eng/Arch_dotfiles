local prios = {
  ["lazyvim.plugins.extras.test.core"] = 1,
  ["lazyvim.plugins.extras.dap.core"] = 1,
  ["lazyvim.plugins.extras.coding.nvim-cmp"] = 2,
  ["lazyvim.plugins.extras.editor.neo-tree"] = 2,
  ["lazyvim.plugins.extras.ui.edgy"] = 3,
  ["lazyvim.plugins.extras.ai.copilot-native"] = 4,
  ["lazyvim.plugins.extras.coding.blink"] = 5,
  ["lazyvim.plugins.extras.lang.typescript"] = 5,
  ["lazyvim.plugins.extras.formatting.prettier"] = 10,
  ["lazyvim.plugins.extras.editor.aerial"] = 100,
  ["lazyvim.plugins.extras.editor.outline"] = 100,
  ["lazyvim.plugins.extras.ui.alpha"] = 19,
  ["lazyvim.plugins.extras.ui.dashboard-nvim"] = 19,
  ["lazyvim.plugins.extras.ui.mini-starter"] = 19,
}

local extras = {}

LazyVim.plugin.save_core()

local root = LazyVim.find_root("lazyvim.plugins.extras")
if root then
  LazyVim.walk(root, function(path, name, type)
    if (type == "file" or type == "link") and name:match("%.lua$") then
      local modname = "lazyvim.plugins.extras." .. path:sub(#root + 2, -5):gsub("/", ".")
      extras[#extras + 1] = modname
    end
  end)
end

extras = LazyVim.dedup(extras)

table.sort(extras, function(a, b)
  local pa = prios[a] or 50
  local pb = prios[b] or 50
  if pa == pb then
    return a < b
  end
  return pa < pb
end)

return vim.tbl_map(function(extra)
  return { import = extra }
end, extras)
