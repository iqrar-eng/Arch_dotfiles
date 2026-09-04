return {
  {
    "nvim-mini/mini.move",
    event = "VeryLazy",
    config = function()
      require("mini.move").setup({
        mappings = {
          left = "<C-S-E>",
          line_left = "<C-S-E>",
          down = "<C-S-J>",
          line_down = "<C-S-J>",
          up = "<C-S-K>",
          line_up = "<C-S-K>",
          right = "<C-S-L>",
          line_right = "<C-S-L>",
        },
      })
    end,
  },

  {
    "nvim-mini/mini.bracketed",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.bracketed").setup({
        buffer = { suffix = "" },
        comment = { suffix = "" },
        conflict = { suffix = "" },
        diagnostic = { suffix = "" },
        file = { suffix = "" },
        indent = { suffix = "" },
        jump = { suffix = "" },
        location = { suffix = "" },
        oldfile = { suffix = "" },
        quickfix = { suffix = "" },
        treesitter = { suffix = "" },
        undo = { suffix = "" },
        window = { suffix = "" },
        yank = { suffix = "" },
      })
      vim.keymap.set({ "n", "o" }, "<C-K>", "<Cmd>lua MiniBracketed.jump('backward')<CR>")
      vim.keymap.set({ "n", "o" }, "<C-S-U>", "<Cmd>lua MiniBracketed.jump('forward')<CR>")

      vim.keymap.set("n", "<C-J>", "<Cmd>lua MiniBracketed.oldfile('backward')<CR>")
      vim.keymap.set("n", "<M-C-C>", "<Cmd>lua MiniBracketed.oldfile('forward')<CR>")
      vim.keymap.set("n", "<C-S-W>", "<Cmd>lua MiniBracketed.oldfile('last')<CR>")

      vim.keymap.set("n", "<M-C-H>", "<Cmd>lua MiniBracketed.file('forward')<CR>")
      vim.keymap.set("n", "<M-C-E>", "<Cmd>lua MiniBracketed.file('backward')<CR>")
      vim.keymap.set("n", "<C-S-A>", "<Cmd>lua MiniBracketed.file('first')<CR>")
      vim.keymap.set("n", "<C-S-F>", "<Cmd>lua MiniBracketed.file('last')<CR>")
    end,
  },

  {
    "nvim-mini/mini.operators",
    event = "VeryLazy",
    version = false,
    config = function()
      local mini = require("mini.operators")
      mini.setup({
        evaluate = { prefix = "g=", func = nil }, -- no mini.make_mappings needed
        exchange = { prefix = "", reindent_linewise = true },
        multiply = { prefix = "", func = nil },
        replace = { prefix = "", reindent_linewise = true },
        sort = { prefix = "", func = nil },
      })
      mini.make_mappings("replace", { textobject = "u", line = "", selection = "" })
      mini.make_mappings("exchange", { textobject = "s", line = "", selection = "s" })
      mini.make_mappings("multiply", { textobject = "<Tab>", line = "", selection = "<Tab>" })
    end,
  },

  { "kylechui/nvim-surround", event = "VeryLazy" },
  { "tpope/vim-abolish", event = "VeryLazy" },
}
