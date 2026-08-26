return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    -- stylua: ignore
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      -- global/multicursor-mode mappings
      vim.keymap.set({ "n", "x" }, "<C-Down>", function() mc.lineAddCursor(1) end, { desc = "MC: cursor below" })
      vim.keymap.set({ "n", "x" }, "<C-Up>", function() mc.lineAddCursor(-1) end, { desc = "MC: cursor above" })
      vim.keymap.set({ "n", "x" }, "<C-S-Down>", function() mc.lineSkipCursor(1) end, { desc = "MC: skip below" })
      vim.keymap.set({ "n", "x" }, "<C-S-Up>", function() mc.lineSkipCursor(-1) end, { desc = "MC: skip above" })

      vim.keymap.set({ "n", "x" }, "<C-Right>", function() mc.matchAddCursor(1) end, { desc = "MC: match forward" })
      vim.keymap.set({ "n", "x" }, "<C-Left>", function() mc.matchAddCursor(-1) end, { desc = "MC: match backward" })
      vim.keymap.set({ "n", "x" }, "<C-S-Right>", function() mc.matchSkipCursor(1) end, { desc = "MC: skip fwd" })
      vim.keymap.set({ "n", "x" }, "<C-S-Left>", function() mc.matchSkipCursor(-1) end, { desc = "MC: skip back" })
      vim.keymap.set({ "n", "x" }, "<leader>aa", mc.matchAllAddCursors, { desc = "MC: all matches" })

      vim.keymap.set({ "n", "x" }, "<M-C-S>", function() mc.searchAddCursor(1) end, { desc = "MC: cursor next search" })
      vim.keymap.set({ "n", "x" }, "<M-C-B>", function() mc.searchAddCursor(-1) end, { desc = "MC: cursor prev search" })
      vim.keymap.set({ "n", "x" }, "<M-C-S-S>", function() mc.searchSkipCursor(1) end, { desc = "MC: next search" })
      vim.keymap.set({ "n", "x" }, "<M-C-S-B>", function() mc.searchSkipCursor(-1) end, { desc = "MC: prev search" })
      vim.keymap.set("n", "<leader>a/", mc.searchAllAddCursors, { desc = "MC: all search results" })

      vim.keymap.set({ "n", "x" }, "<leader>v", mc.addCursorOperator, { desc = "MC: cursor per line" })
      vim.keymap.set({ "n", "x" }, "<leader>s", mc.operator, { desc = "MC: cursor per match" })

      vim.keymap.set({ "n","x" }, "gy", mc.toggleCursor, { desc = "MC: toggle cursor" })
      vim.keymap.set("n", "<leader>ar", mc.restoreCursors, { desc = "MC: restore cursors" })
      vim.keymap.set("x", "<leader>ar", mc.matchCursors, { desc = "MC: match in selection" })
      vim.keymap.set("x", "<leader>al", mc.splitCursors, { desc = "MC: split by regex" })

      -- buffer/multicursor-mode mappings
      mc.addKeymapLayer(function(layerSet)
        layerSet("n", "<leader>al", mc.alignCursors, { desc = "MC: align columns" })

        layerSet({"x", "n"}, "g<C-A>", mc.sequenceIncrement)
        layerSet({"x", "n"}, "g<C-X>", mc.sequenceDecrement)

        layerSet("x", "<C-S-L>", function() mc.transposeCursors(1) end, { desc = "MC: transpose forward", buffer = true })
        layerSet("x", "<C-S-E>", function() mc.transposeCursors(-2) end, { desc = "MC: transpose backward", buffer = true })

        layerSet("x", "<C-S-J>", function() mc.swapCursors(1) end, { desc = "MC: swap forward", buffer = true })
        layerSet("x", "<C-S-K>", function() mc.swapCursors(-1) end, { desc = "MC: swap backward", buffer = true })

        layerSet({ "n", "x" }, "<C-O>", mc.jumpBackward, { desc = "MC: jump back", buffer = true })
        layerSet({ "n", "x" }, "<C-R>", mc.jumpForward, { desc = "MC: jump fwd", buffer = true })

        layerSet({ "n", "x" }, "<C-F>", function() for _ = 1, vim.v.count1 do mc.nextCursor() end end, { desc = "MC: next cursor", buffer = true })
        layerSet({ "n", "x" }, "<C-L>", function() for _ = 1, vim.v.count1 do mc.prevCursor() end end, { desc = "MC: prev cursor", buffer = true })
        layerSet({ "n", "x" }, "<C-S-F>", mc.lastCursor, { desc = "MC: last cursor", buffer = true })
        layerSet({ "n", "x" }, "<M-C-E>", mc.firstCursor, { desc = "MC: first cursor", buffer = true })

        layerSet({ "n","x" }, "gY", mc.enableCursors, { desc = "MC: toggle cursor" })
        layerSet({ "n", "x" }, "<C-C>", mc.duplicateCursors, { desc = "MC: duplicate cursors", buffer = true })
        layerSet({ "n", "x" }, "<M-C-Q>", function() for _ = 1, vim.v.count1 do mc.deleteCursor() end end, { desc = "MC: delete cursor", buffer = true })
        layerSet("n", "<Esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end, { desc = "MC: enable/clear cursors", buffer = true })

        -- flash's char move is too slow in multicursor-mode
        layerSet({ "n", "o", "x" }, "f", "f", { desc = "MC: next cursor", buffer = true })
        layerSet({ "n", "o", "x" }, 't', "t", { desc = "MC: prev cursor", buffer = true })
        layerSet({ "n", "o", "x" }, "F", "F", { desc = "MC: next cursor", buffer = true })
        layerSet({ "n", "o", "x" }, 'T', "T", { desc = "MC: prev cursor", buffer = true })
      end)
    end,
  },
}
