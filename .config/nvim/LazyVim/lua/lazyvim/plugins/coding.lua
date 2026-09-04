return {

  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      local ts = ai.gen_spec.treesitter
      return {
        n_lines = 1500,
        silent = true,
        mappings = {
          around_last = "a<leader>",
          inside_last = "i<leader>",
        },
        custom_textobjects = {
          ["f"] = ts({ a = "@function.outer", i = "@function.inner" }),
          ["j"] = ts({ a = "@comment.outer", i = "@comment.inner" }),
          ["r"] = ai.gen_spec.argument(),
          ["y"] = ts({ a = "@parameter.outer", i = "@parameter.inner" }),
          ["u"] = function(ai_type)
            if ai_type == "a" then
              return { "()%d%d%d%d%-%d%d%-%d%d()" }
            else
              return { "()%d%d:%d%d:%d%d()" }
            end
          end,
          ["x"] = ts({ a = "@block.outer", i = "@block.inner" }), -- matches ]<Tab>/]x in goto
          ["h"] = ts({ a = "@conditional.outer", i = "@conditional.inner" }),
          ["<Home>"] = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          ["<End>"] = ts({ a = "@call.outer", i = "@call.inner" }),
          ["<PageUp>"] = ts({ a = "@attribute.outer", i = "@attribute.inner" }),
          ["<PageDown>"] = ts({ a = "@loop.outer", i = "@loop.inner" }),
          ["4"] = ts({ a = "@regex.outer", i = "@regex.inner" }),
          ["3"] = ts({ a = "@return.outer", i = "@return.inner" }),

          ["2"] = { "%.()[%w%-_]+()" }, -- CSS class .main
          ["1"] = { "#()[%w%-_]+()" }, -- CSS id #main
          ["9"] = ts({ a = "@class.outer", i = "@class.inner" }),
        },
      }
    end,
  },

  -- stylua: ignore
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    config = function()
      require("various-textobjs").setup({
        forwardLooking = {
          small = 1500,
          big = 1500,
        },
        notify = { whenObjectNotFound = false },
      })

      -- inner/outer objects
      vim.keymap.set({ "o", "x" }, "ae", '<cmd>lua require("various-textobjs").subword("outer")<CR>', { desc = "outer subword textobj" })
      vim.keymap.set({ "o", "x" }, "ie", '<cmd>lua require("various-textobjs").subword("inner")<CR>', { desc = "inner subword textobj" })

      vim.keymap.set({ "o", "x" }, "ac", '<cmd>lua require("various-textobjs").key("outer")<CR>', { desc = "outer key textobj" })
      vim.keymap.set({ "o", "x" }, "ic", '<cmd>lua require("various-textobjs").key("inner")<CR>', { desc = "inner key textobj" })

      vim.keymap.set({ "o", "x" }, "av", '<cmd>lua require("various-textobjs").value("outer")<CR>', { desc = "outer value textobj" })
      vim.keymap.set({ "o", "x" }, "iv", '<cmd>lua require("various-textobjs").value("inner")<CR>', { desc = "inner value textobj" })

      vim.keymap.set({ "o", "x" }, "ao", '<cmd>lua require("various-textobjs").color("outer")<CR>', { desc = "outer color textobj" })
      vim.keymap.set({ "o", "x" }, "io", '<cmd>lua require("various-textobjs").color("inner")<CR>', { desc = "inner color textobj" })

      vim.keymap.set({ "o", "x" }, "ag", '<cmd>lua require("various-textobjs").number("outer")<CR>', { desc = "outer number textobj" })
      vim.keymap.set({ "o", "x" }, "ig", '<cmd>lua require("various-textobjs").number("inner")<CR>', { desc = "inner number textobj" })

      vim.keymap.set({ "o", "x" }, "a<Up>", '<cmd>lua require("various-textobjs").doubleSquareBrackets("outer")<CR>', { desc = "outer doubleSquareBrackets textobj" })
      vim.keymap.set({ "o", "x" }, "i<Up>", '<cmd>lua require("various-textobjs").doubleSquareBrackets("inner")<CR>', { desc = "inner doubleSquareBrackets textobj" })

      vim.keymap.set({ "o", "x" }, "a<Left>", '<cmd>lua require("various-textobjs").chainMember("outer")<CR>', { desc = "outer chainMember textobj" })
      vim.keymap.set({ "o", "x" }, "i<Left>", '<cmd>lua require("various-textobjs").chainMember("inner")<CR>', { desc = "inner chainMember textobj" })

      vim.keymap.set({ "o", "x" }, "a<Tab>", '<cmd>lua require("various-textobjs").filepath("outer")<CR>', { desc = "outer filepath textobj" })
      vim.keymap.set({ "o", "x" }, "i<Tab>", '<cmd>lua require("various-textobjs").filepath("inner")<CR>', { desc = "inner filepath textobj" })

      -- single (one-sided) objects
      vim.keymap.set({ "o", "x" }, "al", '<cmd>lua require("various-textobjs").entireBuffer()<CR>', { desc = "entireBuffer textobj" })
      vim.keymap.set({ "o", "x" }, "i<CR>", '<cmd>lua require("various-textobjs").url()<CR>', { desc = "url textobj" })
      vim.keymap.set({ "o", "x" }, "ia", '<cmd>lua require("various-textobjs").nearEoL()<CR>', { desc = "nearEoL textobj" })
      vim.keymap.set({ "o", "x" }, "ai", '<cmd>lua require("various-textobjs").visibleInWindow()<CR>', { desc = "visibleInWindow textobj" })
      vim.keymap.set({ "o", "x" }, "a<CR>", '<cmd>lua require("various-textobjs").emoji()<CR>', { desc = "emoji textobj" })
      vim.keymap.set({ "o", "x" }, "il", '<cmd>lua require("various-textobjs").lineCharacterwise("inner")<CR>')
      vim.keymap.set({ "o", "x" }, "gl", '<cmd>lua require("various-textobjs").column("both")<CR>')
      vim.keymap.set({ "o", "x" }, "go", '<cmd>lua require("various-textobjs").column("down")<CR>')
      vim.keymap.set({ "o", "x" }, "gt", '<cmd>lua require("various-textobjs").column("up")<CR>')

    vim.keymap.set("n", "du", function()
        -- select outer indentation
        require("various-textobjs").indentation("outer", "outer")

        -- plugin only switches to visual mode when a textobj has been found
        local indentationFound = vim.fn.mode():find("V")
        if not indentationFound then return end

        -- dedent indentation
        vim.cmd.normal { "<", bang = true }

        -- delete surrounding lines
        local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
        local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
        vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
        vim.cmd(tostring(startBorderLn) .. " delete")
    end, { desc = "Delete Surrounding Indentation" })

    vim.keymap.set("n", "yu", function()
        local startPos = vim.api.nvim_win_get_cursor(0)

        -- identify start- and end-border
        require("various-textobjs").indentation("outer", "outer")
        local indentationFound = vim.fn.mode():find("V")
        if not indentationFound then return end
        vim.cmd.normal { "V", bang = true } -- leave visual mode so the '< '> marks are set

        -- copy them into the + register
        local startLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
        local endLn = vim.api.nvim_buf_get_mark(0, ">")[1] - 1
        local startLine = vim.api.nvim_buf_get_lines(0, startLn, startLn + 1, false)[1]
        local endLine = vim.api.nvim_buf_get_lines(0, endLn, endLn + 1, false)[1]
        vim.fn.setreg("+", startLine .. "\n" .. endLine .. "\n")

        -- highlight yanked text
        local dur = 100
        local ns = vim.api.nvim_create_namespace("ysii")
        local bufnr = vim.api.nvim_get_current_buf()
        vim.hl.range(bufnr, ns, "IncSearch", { startLn, 0 }, { startLn, -1 }, { timeout = dur })
        vim.hl.range(bufnr, ns, "IncSearch", { endLn, 0 }, { endLn, -1 }, { timeout = dur })

        -- restore cursor position
        vim.api.nvim_win_set_cursor(0, startPos)
    end, { desc = "Yank surrounding indentation" })
    end,
  },
}
