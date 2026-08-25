return {
  -- disable builtin snippet support
  { "garymjr/nvim-snippets", optional = true, enabled = false },

  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
        end,
      },
    },
    opts = function()
      local ls = require("luasnip")

      vim.snippet.expand = ls.lsp_expand
      vim.snippet.active = function(filter)
        filter = filter or {}
        filter.direction = filter.direction or 1
        if filter.direction == 1 then
          return ls.expand_or_jumpable()
        else
          return ls.jumpable(filter.direction)
        end
      end
      vim.snippet.jump = function(direction)
        if direction == 1 then
          if ls.expandable() then
            return ls.expand_or_jump()
          else
            return ls.jumpable(1) and ls.jump(1)
          end
        else
          return ls.jumpable(-1) and ls.jump(-1)
        end
      end

      vim.keymap.set({ "i", "s" }, "<M-C-D>", function()
        local bt = vim.bo.buftype
        if bt == "" then
          return vim.snippet.active({ direction = 1 }) and vim.snippet.jump(1)
        else
          vim.cmd("close!")
        end
      end)
      vim.keymap.set({ "i", "s" }, "<M-C-A>", function()
        return vim.snippet.active({ direction = -1 }) and vim.snippet.jump(-1)
      end, { silent = true })

      return {
        keep_roots = true,
        link_roots = true,
        exit_roots = false,
        link_children = true,
        update_events = { "TextChanged", "TextChangedI" },
        delete_check_events = "TextChanged",
        enable_autosnippets = true,
      }
    end,
  },
}
