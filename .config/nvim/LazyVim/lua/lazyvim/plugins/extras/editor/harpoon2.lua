return {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  branch = "harpoon2",
  config = function()
    local harpoon = require("harpoon")
    require("harpoon"):setup({
      settings = {
        save_on_toggle = false,
        sync_on_ui_close = false,
        key = function()
          return "global"
        end,
      },
    })

    -- ========================

    local buffer_select_keys = { "<M-1>", "<M-2>", "<M-3>", "<M-4>", "<M-5>", "<M-6>", "<M-7>", "<M-8>", "<M-9>" }
    for i, k in ipairs(buffer_select_keys) do
      vim.keymap.set({ "n", "i" }, k, function()
        local list = harpoon:list()
        if k == "<M-9>" then
          list:select(#list.items)
          return
        end
        local count = vim.v.count
        local target = count > 0 and (count * i) or i
        list:select(target)
      end, { desc = "harpoon: select buffer " .. i .. " (or N×" .. i .. " with count)" })
    end

    -- ========================

    local function normalize_list_paths(list)
      for _, item in ipairs(list.items) do
        if item then
          item.value = vim.fn.fnamemodify(item.value, ":p")
        end
      end
    end
    local function ensure_harpoon_index(list)
      normalize_list_paths(list)
      local current = vim.fn.expand("%:p")
      for idx, item in ipairs(list.items) do
        if item.value == current then
          return idx
        end
      end
      harpoon:list():add()
      normalize_list_paths(list) -- normalize the newly added item too
      return #list.items
    end
    local function harpoon_move_block_to(from, count, to, list)
      normalize_list_paths(list)
      local items = list.items
      count = math.max(1, count)
      local last = math.min(from + count - 1, #items)
      local block = {}
      for idx = from, last do
        table.insert(block, items[idx])
      end
      for _ = from, last do
        table.remove(items, from)
      end
      to = math.max(1, math.min(to, #items + 1))
      for offset, item in ipairs(block) do
        table.insert(items, to + offset - 1, item)
      end
      harpoon:sync()
    end

    local buffer_move_keys =
      { "y<M-1>", "y<M-2>", "y<M-3>", "y<M-4>", "y<M-5>", "y<M-6>", "y<M-7>", "y<M-8>", "y<M-9>" }
    for i, k in ipairs(buffer_move_keys) do
      vim.keymap.set("n", k, function()
        local list = harpoon:list()
        local from = ensure_harpoon_index(list)
        local count = vim.v.count > 0 and vim.v.count or 1
        local to = (k == "y<M-9>") and #list.items or i
        harpoon_move_block_to(from, count, to, list)
      end, { desc = "Harpoon: Move current file to slot " .. i .. " (use a count to bring following files along)" })
    end
  end,
}
