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

      local M = {}
      local innerOuterMaps = {
        subword = "m",
        key = "c",
        value = "v",
        color = "o",
        number = "g",
        doubleSquareBrackets = "<Up>",
        chainMember = "<Left>",
        filepath = "<tab>",
      }
      local oneMaps = {
        entireBuffer = "al",
        url = "i<CR>",
        nearEoL = "ia",
        visibleInWindow = "ai",
        emoji = "a<CR>",
      }

      function M.setup(disabledKeymaps)
        local function keymap(...)
          local args = { ... }
          if vim.tbl_contains(disabledKeymaps, args[2]) then
            return
          end
          vim.keymap.set(...)
        end
        for objName, map in pairs(oneMaps) do
          keymap(
            { "o", "x" },
            map,
            "<cmd>lua require('various-textobjs')." .. objName .. "()<CR>",
            { desc = objName .. " textobj" }
          )
        end
        for objName, map in pairs(innerOuterMaps) do
          local name = " " .. objName .. " textobj"
          keymap(
            { "o", "x" },
            "a" .. map,
            "<cmd>lua require('various-textobjs')." .. objName .. "('outer')<CR>",
            { desc = "outer" .. name }
          )
          keymap(
            { "o", "x" },
            "i" .. map,
            "<cmd>lua require('various-textobjs')." .. objName .. "('inner')<CR>",
            { desc = "inner" .. name }
          )
        end
      end
      M.setup({})

      local function get_surrounding_indent_borders(count)
        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
        local startLn, endLn
        for i = 1, count do
          if i > 1 then
            vim.api.nvim_feedkeys(esc, "x", false)
            vim.api.nvim_win_set_cursor(0, { startLn + 1, 0 }) -- top border is content one level up
          end
          require("various-textobjs").indentation("outer", "outer")
          vim.cmd.normal({ "V", bang = true })
          local newStart = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
          local newEnd = vim.api.nvim_buf_get_mark(0, ">")[1] - 1
          if i > 1 and newStart == startLn and newEnd == endLn then
            break
          end -- outermost reached
          startLn, endLn = newStart, newEnd
        end
        return startLn, endLn
      end

      local function collect_indent_borders(count)
        local borders = {}
        local curPos = vim.api.nvim_win_get_cursor(0)
        for _ = 1, count do
          vim.api.nvim_win_set_cursor(0, curPos)
          require("various-textobjs").indentation("outer", "outer")
          vim.cmd.normal({ "V", bang = true })
          local startLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
          local endLn = vim.api.nvim_buf_get_mark(0, ">")[1] - 1
          vim.cmd("normal! \27")
          if #borders > 0 then
            local prev = borders[#borders]
            if startLn == prev.startLn and endLn == prev.endLn then
              break
            end
          end
          local startLine = vim.api.nvim_buf_get_lines(0, startLn, startLn + 1, false)[1]
          local endLine = vim.api.nvim_buf_get_lines(0, endLn, endLn + 1, false)[1]
          table.insert(borders, { startLn = startLn, endLn = endLn, startLine = startLine, endLine = endLine })
          if startLn == 0 then
            break
          end
          curPos = { startLn, 0 }
        end
        return borders
      end
      local function sorted_yank_lines(borders)
        local entries = {}
        for _, b in ipairs(borders) do
          table.insert(entries, { ln = b.startLn, text = b.startLine })
          table.insert(entries, { ln = b.endLn, text = b.endLine })
        end
        table.sort(entries, function(a, b)
          return a.ln < b.ln
        end)
        return vim.tbl_map(function(e)
          return e.text
        end, entries)
      end

      vim.keymap.set({ "o", "x" }, "il", '<cmd>lua require("various-textobjs").lineCharacterwise("inner")<CR>')
      vim.keymap.set({ "o", "x" }, "gl", '<cmd>lua require("various-textobjs").column("both")<CR>')
      vim.keymap.set({ "o", "x" }, "go", '<cmd>lua require("various-textobjs").column("down")<CR>')
      vim.keymap.set({ "o", "x" }, "gt", '<cmd>lua require("various-textobjs").column("up")<CR>')

      local ns = vim.api.nvim_create_namespace("si")
      local dur = 100
      local function hl_borders(bufnr, borders)
        for _, b in ipairs(borders) do
          vim.hl.range(bufnr, ns, "IncSearch", { b.startLn, 0 }, { b.startLn, -1 }, { timeout = dur })
          vim.hl.range(bufnr, ns, "IncSearch", { b.endLn, 0 }, { b.endLn, -1 }, { timeout = dur })
        end
      end

      local function si_multi(delete)
        return function()
          local startPos = vim.api.nvim_win_get_cursor(0)
          local borders = collect_indent_borders(vim.v.count1)
          if #borders == 0 then
            return
          end
          hl_borders(vim.api.nvim_get_current_buf(), borders)
          local yankLines = sorted_yank_lines(borders)
          vim.fn.setreg("+", table.concat(yankLines, "\n") .. "\n")
          if delete then
            local seen, toDelete = {}, {}
            for _, b in ipairs(borders) do
              for _, ln in ipairs({ b.endLn, b.startLn }) do
                if not seen[ln] then
                  seen[ln] = true
                  table.insert(toDelete, ln)
                end
              end
            end
            table.sort(toDelete, function(a, b)
              return a > b
            end)
            for _, ln in ipairs(toDelete) do
              vim.api.nvim_buf_set_lines(0, ln, ln + 1, false, {})
            end
            vim.api.nvim_win_set_cursor(0, { math.min(startPos[1], vim.api.nvim_buf_line_count(0)), startPos[2] })
          else
            vim.api.nvim_win_set_cursor(0, startPos)
          end
          vim.notify(table.concat(yankLines, "\n"), delete and vim.log.levels.WARN or vim.log.levels.INFO)
        end
      end

      vim.keymap.set("n", "du", si_multi(true), { desc = "Delete Surrounding Indent(s)" })
      vim.keymap.set("n", "su", si_multi(false), { desc = "Yank Surrounding Indent(s)" })
    end,
  },
}
