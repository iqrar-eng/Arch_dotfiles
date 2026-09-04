return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false, -- last release is way too old and doesn't work on Windows
    build = function()
      local TS = require("nvim-treesitter")
      if not TS.get_installed then
        LazyVim.error("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.")
        return
      end
      -- make sure we're using the latest treesitter util
      package.loaded["lazyvim.util.treesitter"] = nil
      LazyVim.treesitter.build(function()
        TS.update(nil, { summary = true })
      end)
    end,
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    ---@alias lazyvim.TSFeat { enable?: boolean, disable?: string[] }
    ---@class lazyvim.TSConfig: TSConfig
    opts = {
      -- LazyVim config for treesitter
      indent = { enable = true }, ---@type lazyvim.TSFeat
      highlight = { enable = true }, ---@type lazyvim.TSFeat
      folds = { enable = true }, ---@type lazyvim.TSFeat
      ensure_installed = {
        "cpp",

        "html",
        "http",

        "lua",
        "luadoc",
        "luap",

        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "typescript",
        "tsx",

        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "toml",
        "regex",
        "diff",
        "vim",
        "vimdoc",
      },
    },
    ---@param opts lazyvim.TSConfig
    config = function(_, opts)
      local TS = require("nvim-treesitter")

      setmetatable(require("nvim-treesitter.install"), {
        __newindex = function(_, k)
          if k == "compilers" then
            vim.schedule(function()
              LazyVim.error({
                "Setting custom compilers for `nvim-treesitter` is no longer supported.",
                "",
                "For more info, see:",
                "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
              })
            end)
          end
        end,
      })

      -- some quick sanity checks
      if not TS.get_installed then
        return LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
      elseif type(opts.ensure_installed) ~= "table" then
        return LazyVim.error("`nvim-treesitter` opts.ensure_installed must be a table")
      end

      -- setup treesitter
      TS.setup(opts)
      LazyVim.treesitter.get_installed(true) -- initialize the installed langs

      -- install missing parsers
      local install = vim.tbl_filter(function(lang)
        return not LazyVim.treesitter.have(lang)
      end, opts.ensure_installed or {})
      if #install > 0 then
        LazyVim.treesitter.build(function()
          TS.install(install, { summary = true }):await(function()
            LazyVim.treesitter.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
          if not LazyVim.treesitter.have(ft) then
            return
          end

          ---@param feat string
          ---@param query string
          local function enabled(feat, query)
            local f = opts[feat] or {} ---@type lazyvim.TSFeat
            return f.enable ~= false
              and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
              and LazyVim.treesitter.have(ft, query)
          end

          -- highlighting
          if enabled("highlight", "highlights") then
            pcall(vim.treesitter.start, ev.buf)
          end

          -- indents
          if enabled("indent", "indents") then
            LazyVim.set_default("indentexpr", "v:lua.LazyVim.treesitter.indentexpr()")
          end

          -- folds
          if enabled("folds", "folds") then
            if LazyVim.set_default("foldmethod", "expr") then
              LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()")
            end
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      select = { enable = true, lookahead = true },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        keys = {
          goto_next_start = {
            ["<Right><Home>"] = "@function.inner",
            ["<Right><End>"] = "@function.outer",
            ["<Right><PageUp>"] = "@attribute.inner",
            ["<Right><PageDown>"] = "@attribute.outer",
            ["<Right>("] = "@class.inner",
            ["<Right>)"] = "@class.outer",
            ["<Right>9"] = "@comment.inner",
            ["<Right>0"] = "@comment.outer",
            ["<Right>7"] = "@regex.inner",
            ["<Right>8"] = "@regex.outer",
            ["<Right>+"] = "@number.inner",
            ["]a"] = "@assignment.inner",
            ["]^"] = "@assignment.outer",
            ["]n"] = "@assignment.lhs",
            ["],"] = "@assignment.rhs",
            ["]h"] = "@parameter.inner",
            ["]n"] = "@parameter.outer",
            ["]k"] = "@call.inner",
            ["]f"] = "@call.outer",
            ["]i"] = "@conditional.inner",
            ["]o"] = "@conditional.outer",
            ["]{"] = "@return.inner",
            ["]_"] = "@return.outer",
            ["]<CR>"] = "@loop.inner",
            ["]u"] = "@loop.outer",
            ["]b"] = "@block.inner",
            ["]g"] = "@block.outer",
          },

          goto_previous_start = {
            ["<Down><Home>"] = "@function.inner",
            ["<Down><End>"] = "@function.outer",
            ["<Down><PageUp>"] = "@attribute.inner",
            ["<Down><PageDown>"] = "@attribute.outer",
            ["<Down>("] = "@class.inner",
            ["<Down>)"] = "@class.outer",
            ["<Down>9"] = "@comment.inner",
            ["<Down>0"] = "@comment.outer",
            ["<Down>7"] = "@regex.inner",
            ["<Down>8"] = "@regex.outer",
            ["<Down>+"] = "@number.inner",
            ["[a"] = "@assignment.inner",
            ["[^"] = "@assignment.outer",
            ["[n"] = "@assignment.lhs",
            ["[,"] = "@assignment.rhs",
            ["[h"] = "@parameter.inner",
            ["[n"] = "@parameter.outer",
            ["[k"] = "@call.inner",
            ["[f"] = "@call.outer",
            ["[i"] = "@conditional.inner",
            ["[o"] = "@conditional.outer",
            ["[}"] = "@return.inner",
            ["[_"] = "@return.outer",
            ["[<CR>"] = "@loop.inner",
            ["[u"] = "@loop.outer",
            ["[b"] = "@block.inner",
            ["[g"] = "@block.outer",
          },

          goto_next_end = {
            ["<Up><Home>"] = "@function.inner",
            ["<Up><End>"] = "@function.outer",
            ["<Up><PageUp>"] = "@attribute.inner",
            ["<Up><PageDown>"] = "@attribute.outer",
            ["<Up>("] = "@class.inner",
            ["<Up>)"] = "@class.outer",
            ["<Up>9"] = "@comment.inner",
            ["<Up>0"] = "@comment.outer",
            ["<Up>7"] = "@regex.inner",
            ["<Up>8"] = "@regex.outer",
            ["<Up>+"] = "@number.inner",
            [">."] = "@assignment.inner",
            [">)"] = "@assignment.outer",
            [">*"] = "@assignment.lhs",
            [">#"] = "@assignment.rhs",
            ["><Home>"] = "@parameter.inner",
            ["><End>"] = "@parameter.outer",
            ["><PageUp>"] = "@call.inner",
            ["><PageDown>"] = "@call.outer",
            [">8"] = "@conditional.inner",
            [">9"] = "@conditional.outer",
            [">("] = "@return.inner",
            [">+"] = "@return.outer",
            [">6"] = "@loop.inner",
            [">7"] = "@loop.outer",
            [">?"] = "@block.inner",
            [">0"] = "@block.outer",
          },

          goto_previous_end = {
            ["<Left><Home>"] = "@function.inner",
            ["<Left><End>"] = "@function.outer",
            ["<Left><PageUp>"] = "@attribute.inner",
            ["<Left><PageDown>"] = "@attribute.outer",
            ["<Left>("] = "@class.inner",
            ["<Left>)"] = "@class.outer",
            ["<Left>9"] = "@comment.inner",
            ["<Left>0"] = "@comment.outer",
            ["<Left>7"] = "@regex.inner",
            ["<Left>8"] = "@regex.outer",
            ["<Left>+"] = "@number.inner",
            ["<."] = "@assignment.inner",
            ["<)"] = "@assignment.outer",
            ["<*"] = "@assignment.lhs",
            ["<#"] = "@assignment.rhs",
            ["<<Home>"] = "@parameter.inner",
            ["<<End>"] = "@parameter.outer",
            ["<<PageUp>"] = "@call.inner",
            ["<<PageDown>"] = "@call.outer",
            ["<8"] = "@conditional.inner",
            ["<9"] = "@conditional.outer",
            ["<("] = "@return.inner",
            ["<+"] = "@return.outer",
            ["<6"] = "@loop.inner",
            ["<7"] = "@loop.outer",
            ["<?"] = "@block.inner",
            ["<0"] = "@block.outer",
          },
        },
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter-textobjects")
      if not TS.setup then
        LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
        return
      end
      TS.setup(opts)

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if not (vim.tbl_get(opts, "move", "enable") and LazyVim.treesitter.have(ft, "textobjects")) then
          return
        end
        local moves = vim.tbl_get(opts, "move", "keys") or {}
        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local node, suffix = query:match("^@([^.]+)%.?(.*)$")
            local label = node and (node:sub(1, 1):upper() .. node:sub(2)) or query
            if suffix and suffix ~= "" then
              label = label .. " " .. suffix
            end
            local desc = method .. " " .. label
            vim.keymap.set({ "n", "x", "o" }, key, function()
              if vim.wo.diff and key:find("[cC]") then
                return vim.cmd("normal! " .. key)
              end
              require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
            end, {
              buffer = buf,
              desc = desc,
              silent = true,
            })
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())

      local diagnostic_goto = function(next, severity)
        return function()
          local current_buf = vim.api.nvim_get_current_buf()
          local current_line = vim.api.nvim_win_get_cursor(0)[1]
          for _ = 1, vim.v.count1 do
            vim.diagnostic.jump({
              count = next and 1 or -1,
              severity = severity and vim.diagnostic.severity[severity] or nil,
            })
            -- Keep jumping if we're still on the same line
            local new_line = vim.api.nvim_win_get_cursor(0)[1]
            while new_line == current_line and vim.api.nvim_get_current_buf() == current_buf do
              vim.diagnostic.jump({
                count = next and 1 or -1,
                severity = severity and vim.diagnostic.severity[severity] or nil,
              })
              local newer_line = vim.api.nvim_win_get_cursor(0)[1]
              if newer_line == new_line then
                -- No more diagnostics to jump to
                break
              end
              new_line = newer_line
            end
            current_line = vim.api.nvim_win_get_cursor(0)[1]
          end
        end
      end

      vim.keymap.set({ "n", "x", "o" }, "<Right>*", diagnostic_goto(true), { desc = "Next Diagnostic" })
      vim.keymap.set({ "n", "x", "o" }, "<Down>*", diagnostic_goto(false), { desc = "Prev Diagnostic" })
      vim.keymap.set({ "n", "x", "o" }, "<Right>#", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
      vim.keymap.set({ "n", "x", "o" }, "<Down>#", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
      vim.keymap.set({ "n", "x", "o" }, "<Up>#", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
      vim.keymap.set({ "n", "x", "o" }, "<Left>#", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

      -- stylua: ignore
      local swap_keymaps = {
        -- FUNCTION
        { "<leader>gj", "next", "@function.outer"    },
        { "<leader>gJ", "prev", "@function.outer"    },
        { "<leader>gt", "next", "@function.inner"    },
        { "<leader>gT", "prev", "@function.inner"    },
        -- ATTRIBUTE
        { "<leader>gd", "next", "@attribute.outer"   },
        { "<leader>gD", "prev", "@attribute.outer"   },
        { "<leader>gs", "next", "@attribute.inner"   },
        { "<leader>gS", "prev", "@attribute.inner"   },
        -- CLASS
        { "<leader>g}", "next", "@class.outer"       },
        { "<leader>g!", "prev", "@class.outer"       },
        { "<leader>g{", "next", "@class.inner"       },
        { "<leader>g`", "prev", "@class.inner"       },
        -- COMMENT
        { "<leader>gr", "next", "@comment.outer"     },
        { "<leader>gR", "prev", "@comment.outer"     },
        -- ASSIGNMENT
        { "<leader>gw", "next", "@assignment.outer"  },
        { "<leader>gW", "prev", "@assignment.outer"  },
        { "<leader>gq", "next", "@assignment.inner"  },
        { "<leader>gQ", "prev", "@assignment.inner"  },
        { "<leader>g/", "next", "@assignment.rhs"    },
        { "<leader>g\\","prev", "@assignment.rhs"    },
        { "<leader>gm", "next", "@assignment.lhs"    },
        { "<leader>gM", "prev", "@assignment.lhs"    },
        -- NUMBER
        { "<leader>g=", "next", "@number.inner"      },
        { "<leader>g@", "prev", "@number.inner"      },
        -- PARAMETER
        { "<leader>gf", "next", "@parameter.outer"   },
        { "<leader>gF", "prev", "@parameter.outer"   },
        { "<leader>gn", "next", "@parameter.inner"   },
        { "<leader>gN", "prev", "@parameter.inner"   },
        -- CALL
        { "<leader>gh", "next", "@call.outer"        },
        { "<leader>gH", "prev", "@call.outer"        },
        { "<leader>gl", "next", "@call.inner"        },
        { "<leader>gL", "prev", "@call.inner"        },
        -- CONDITIONAL
        { "<leader>gc", "next", "@conditional.outer" },
        { "<leader>gC", "prev", "@conditional.outer" },
        { "<leader>gv", "next", "@conditional.inner" },
        { "<leader>gV", "prev", "@conditional.inner" },
        -- RETURN
        { "<leader>gi", "next", "@return.outer"      },
        { "<leader>gI", "prev", "@return.outer"      },
        { "<leader>go", "next", "@return.inner"      },
        { "<leader>gO", "prev", "@return.inner"      },
        -- LOOP
        { "<leader>gy",   "next", "@loop.outer"   },
        { "<leader>gY", "prev", "@loop.outer"   },
        { "<leader>gz",      "next", "@loop.inner"   },
        { "<leader>gZ",      "prev", "@loop.inner"   },
        -- REGEX
        { "<leader>gk", "next", "@regex.outer"       },
        { "<leader>gK", "prev", "@regex.outer"       },
        { "<leader>g,", "next", "@regex.inner"       },
        { "<leader>g;", "prev", "@regex.inner"       },
        -- BLOCK
        { "<leader>gx",      "next", "@block.outer"  },
        { "<leader>gX",      "prev", "@block.outer"  },
        { "<leader>g<Tab>",  "next", "@block.inner"  },
        { "<leader>g<S-Tab>","prev", "@block.inner"  },
      }

      local swap = require("nvim-treesitter-textobjects.swap")
      for _, map in ipairs(swap_keymaps) do
        local key, dir, query = map[1], map[2], map[3]
        local fn = dir == "next" and swap.swap_next or swap.swap_previous
        local label = query:gsub("^@", ""):gsub("%.", " ")
        local desc = dir .. " " .. label
        vim.keymap.set("n", key, function()
          fn(query)
        end, { desc = desc })
      end
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },
}
