local function setup_aerial_highlights()
  for i = 1, 12 do
    vim.api.nvim_set_hl(0, "AerialIndent" .. i, { link = "SnacksIndent" .. i })
  end
end
setup_aerial_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_aerial_highlights,
})

local function aerial_with_indent_highlights()
  local aerial = require("aerial")
  aerial.sync_load()
  local data = require("aerial.data")
  local window = require("aerial.window")
  local config = require("aerial.config")
  if not data.has_symbols(0) then
    return ""
  end
  local winid = vim.api.nvim_get_current_win()
  local bufdata = data.get_or_create(0)
  local cur = vim.api.nvim_win_get_cursor(winid)
  local pos = window.get_symbol_position(bufdata, cur[1], cur[2], true)
  if not pos then
    return ""
  end
  -- fall back to closest_symbol when there's no exact match
  -- (common in help/vimdoc/markdown-style symbol ranges)
  local item = pos.exact_symbol or pos.closest_symbol
  if not item then
    return ""
  end
  local cur_line = cur[1]
  local chain = {}
  while item do
    table.insert(chain, 1, item)
    item = item.parent
  end
  local parts = {}
  for i, sym in ipairs(chain) do
    local hl_group = "AerialIndent" .. (sym.level % 12 + 1)
    local icon = config.get_icon(0, sym.kind)
    local name = (sym.name or ""):gsub("`([^`]+)`", "%1")
    local is_last = i == #chain
    if is_last then
      if #name > 40 then
        name = name:sub(1, 40) .. "…"
      end
    elseif #name > 28 then
      name = name:sub(1, 28) .. "…"
    end
    local rel = math.abs((sym.lnum or cur_line) - cur_line)
    table.insert(parts, string.format("%%#%s#%s %s %d", hl_group, icon, name, rel))
  end
  return table.concat(parts, "%## ")
end

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require
      local icons = LazyVim.config.icons

      -- Define statusline configuration (will appear at top via tabline)
      local statusline_config = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { aerial_with_indent_highlights, padding = { left = 0, right = 0 } } },
        lualine_x = {
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = function()
              return { fg = Snacks.util.color("Statement") }
            end,
            padding = { left = 0, right = 0 },
          },
          {
            function()
              return require("noice").api.status.mode.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
            color = function()
              return { fg = Snacks.util.color("Constant") }
            end,
            padding = { left = 0, right = 0 },
          },
          {
            function()
              return "  " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = function()
              return { fg = Snacks.util.color("Debug") }
            end,
            padding = { left = 0, right = 0 },
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
            padding = { left = 0, right = 0 },
          },
          {
            function(self)
              local total = vim.fn.line("$")
              local root_path = LazyVim.root.get({ normalize = true })
              local root = vim.fs.basename(root_path)
              local path = LazyVim.lualine.pretty_path()(self)
              return string.format(
                "%s%s%s%s%s%d",
                "%*%#SnacksPickerDirectory#",
                root,
                "%*%#NeogitGraphBoldGreen#/",
                path,
                "%*%#Dimmed#:%#CursorLineNr#",
                total
              )
            end,
            color = function()
              return { fg = Snacks.util.color("Special") }
            end,
            padding = { left = 0, right = 0 },
          },
        },
        lualine_y = {},
        lualine_z = {},
      }
      local opts = {
        options = {
          globalstatus = true,
          component_separators = { left = "┃", right = "┃" },
          section_separators = { left = "", right = "" },
          ignore_focus = {},
          always_divide_middle = true,
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter", "ministarter", "snacks_dashboard" },
          },
        },
        -- Disable bottom statusline
        sections = {},
        inactive_sections = {},
        -- Use tabline for top statusline
        tabline = statusline_config,
        -- Disable winbar completely
        winbar = {},
        inactive_winbar = {},
      }
      return opts
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = false,
        lsp_doc_border = true,
      },
      cmdline = {
        enabled = true,
        view = "cmdline",
        format = {
          cmdline = false,
          search_down = false,
          search_up = false,
          filter = false,
          lua = false,
          help = false,
          input = { view = "cmdline" }, -- Used by input()
        },
      },
      views = {
        hover = {
          size = {
            max_height = 50,
          },
          border = {
            padding = { 0, 0 },
          },
          position = { row = 0, col = 0 },
        },
        cmdline = { position = { row = 0 } },
      },
    },
    -- stylua: ignore
    keys = {
      { "<C-J>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>hy", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<C-S-H>", function() if not require("noice.lsp").scroll(8) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      { "<C-S-S>", function() if not require("noice.lsp").scroll(-8) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
    },
    config = function(_, opts)
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },

  -- icons
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
        [".blerc"] = { glyph = "󰒓", hl = "MiniIconsBlue" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        ["markdown.mdx"] = { glyph = "󰍔", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
