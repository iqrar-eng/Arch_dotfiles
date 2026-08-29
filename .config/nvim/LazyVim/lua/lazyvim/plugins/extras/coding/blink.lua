---@diagnostic disable: missing-fields
if lazyvim_docs then
  -- set to `true` to follow the main branch
  -- you need to have a working rust toolchain to build the plugin
  -- in this case.
  vim.g.lazyvim_blink_main = false
end

return {
  {
    "saghen/blink.cmp",
    version = not vim.g.lazyvim_blink_main and "*",
    build = vim.g.lazyvim_blink_main and "cargo build --release",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
    dependencies = {
      "rafamadriz/friendly-snippets",
      -- add blink.compat to dependencies
      {
        "saghen/blink.compat",
        optional = true, -- make optional so it's only enabled if any extras need it
        opts = {},
        version = not vim.g.lazyvim_blink_main and "*",
      },
    },
    event = { "InsertEnter", "CmdlineEnter" },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      cmdline = {
        enabled = true,
        -- stylua: ignore
        keymap = {
          preset = "none",
          ["<Tab>"] = { "show_and_insert_or_accept_single", "select_next" },
          ["<S-Tab>"] = { "show_and_insert_or_accept_single", "select_prev" },

          ["<C-w>"] = { "hide", "show" },
          ["<C-p>"] = { "cancel", "show" },

          ["<M-CR>"] = { "show_and_insert_or_accept_single", "select_and_accept" },
          ["<S-CR>"] = { "accept_and_enter", "fallback" },

          ["<A-q>"] = { function(cmp) cmp.accept({ index = 6 }) end, },
          ["<A-w>"] = { function(cmp) cmp.accept({ index = 2 }) end, },
          ["<A-y>"] = { function(cmp) cmp.accept({ index = 3 }) end, },
          ["<A-r>"] = { function(cmp) cmp.accept({ index = 4 }) end, },
          ["<A-t>"] = { function(cmp) cmp.accept({ index = 5 }) end, },
          ["<A-u>"] = { function(cmp) cmp.accept({ index = 7 }) end, },
          ["<A-z>"] = { function(cmp) cmp.accept({ index = 8 }) end, },
          ["<A-o>"] = { function(cmp) cmp.accept({ index = 9 }) end, },
          ["<A-p>"] = { function(cmp) cmp.accept({ index = 10 }) end, },
        },
        completion = { menu = { auto_show = true } },
      },

      -- stylua: ignore
      keymap = {
        preset = "none",
        ["<Tab>"] = { "select_next", "fallback_to_mappings" },
        ["<S-Tab>"] = { "select_prev", "fallback_to_mappings" },

        ["<C-w>"] = { "hide", "show" },
        ["<C-p>"] = { "cancel", "show" },

        ["<M-CR>"] = { "show_and_insert_or_accept_single", "select_and_accept" },
        ["<C-S>"] = { "snippet_backward", "fallback" },

        ["<C-S-H>"] = { "scroll_documentation_down" },
        ["<C-S-S>"] = { "scroll_documentation_up" },

        ["<A-q>"] = { function(cmp) cmp.accept({ index = 6 }) end, },
        ["<A-w>"] = { function(cmp) cmp.accept({ index = 2 }) end, },
        ["<A-y>"] = { function(cmp) cmp.accept({ index = 3 }) end, },
        ["<A-r>"] = { function(cmp) cmp.accept({ index = 4 }) end, },
        ["<A-t>"] = { function(cmp) cmp.accept({ index = 5 }) end, },
        ["<A-u>"] = { function(cmp) cmp.accept({ index = 7 }) end, },
        ["<A-z>"] = { function(cmp) cmp.accept({ index = 8 }) end, },
        ["<A-o>"] = { function(cmp) cmp.accept({ index = 9 }) end, },
        ["<A-p>"] = { function(cmp) cmp.accept({ index = 10 }) end, },
      },
      completion = {
        menu = {
          max_height = 47,
          draw = {
            columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
            components = {
              item_idx = {
                text = function(ctx)
                  return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
                end,
                highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
              },
            },
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show_delay_ms = 200,
          window = {
            max_width = 120,
            max_height = 50,
          },
        },
        ghost_text = {
          enabled = true,
          show_without_selection = true,
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          path = {
            opts = {
              show_hidden_files_by_default = true,
            },
          },
        },
      },
    },
    ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
    config = function(_, opts)
      if opts.snippets and opts.snippets.preset == "default" then
        opts.snippets.expand = LazyVim.cmp.expand
      end
      -- setup compat sources
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- add ai_accept to <Tab> key
      if not opts.keymap["<Tab>"] then
        if opts.keymap.preset == "super-tab" then -- super-tab
          opts.keymap["<Tab>"] = {
            require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
            LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
            "fallback",
          }
        else -- other presets
          opts.keymap["<Tab>"] = {
            LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
            "fallback",
          }
        end
      end

      -- Unset custom prop to pass blink.cmp validation
      opts.sources.compat = nil

      -- check if we need to override symbol kinds
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          ---@diagnostic disable-next-line: no-unknown
          CompletionItemKind[provider.kind] = kind_idx

          ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
          local transform_items = provider.transform_items
          ---@param ctx blink.cmp.Context
          ---@param items blink.cmp.CompletionItem[]
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
              item.kind_icon = LazyVim.config.icons.kinds[item.kind_name] or item.kind_icon or nil
            end
            return items
          end

          -- Unset custom prop to pass blink.cmp validation
          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },

  -- add icons
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend("force", opts.appearance.kind_icons or {}, LazyVim.config.icons.kinds)
    end,
  },
}
