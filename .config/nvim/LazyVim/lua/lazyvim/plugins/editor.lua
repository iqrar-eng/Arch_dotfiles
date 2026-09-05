return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>ag",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          require("grug-far").open({
            prefills = { paths = LazyVim.root.get(), flags = "--ignore-case --fixed-strings --hidden" },
          })
        end,
        mode = { "n", "x" },
        desc = "root",
      },

      {
        "<leader>am",
        function()
          require("grug-far").open({
            prefills = { paths = vim.fn.expand("%"), flags = "--ignore-case --fixed-strings --hidden" },
          })
        end,
        mode = { "n", "x" },
        desc = "current file",
      },
    },
    opts = {
      wrap = false,
      windowCreationCommand = "tabnew",
    },
    config = function(_, opts)
      require("grug-far").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("grug-far-custom-keybinds", { clear = true }),
        pattern = { "grug-far" },
        callback = function()
          vim.keymap.set("n", "<localleader>z", function()
            require("grug-far").get_instance(0):toggle_flags({ "--fixed-strings" })
          end, { buffer = true, desc = "Toggle --fixed-strings" })

          vim.keymap.set("n", "<localleader>g", function()
            require("grug-far").get_instance(0):toggle_flags({ "--ignore-case" })
          end, { buffer = true, desc = "Toggle --ignore-case" })
        end,
      })
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {
      label = { before=true, after=false, rainbow = { enabled = true, shade = 6 } },
      highlight = { backdrop = false },
      modes = {
        search = { enabled = true, highlight = { backdrop = false } },
        char = {
          autohide = true,
          search = { wrap = true },
          highlight = { backdrop = false },
          char_actions = function()
            return {
              [";"] = "next", -- set to `right` to always go right
              [","] = "prev", -- set to `left` to always go left
            }
          end,
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      sort = { "local", "order", "desc", "alphanum", "mod" },
      preset = "helix",
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        map("n", ">h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next", { target = "staged" })
          end
        end, "Next Hunk")
        map("n", "<h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev", { target = "staged" })
          end
        end, "Prev Hunk")
        map("n", ">H", function() gs.nav_hunk("last", { target = "staged" }) end, "Gitsigns Last Hunk")
        map("n", "<H", function() gs.nav_hunk("first", { target = "staged" }) end, "Gitsigns First Hunk")

        map({ "n", "x" }, "<leader>jh", ":Gitsigns stage_hunk<CR>", "Gitsigns Stage Hunk")
        map("n", "<leader>ju", gs.stage_buffer, "Gitsigns Stage Buffer")
        map("n", "<leader>jU", gs.undo_stage_hunk, "Gitsigns Undo Stage Hunk")

        map("n", "<leader>jr", gs.reset_buffer, "Gitsigns Reset Buffer")
        map({ "n", "x" }, "<leader>jm", ":Gitsigns reset_hunk<CR>", "Gitsigns Reset Hunk")

        map("n", "<leader>jw", gs.preview_hunk_inline, "Gitsigns Preview Hunk Inline")
        map("n", "<M-p>", gs.preview_hunk, "Gitsigns Preview Hunk Inline")

        map("n", "<leader>jb", function() gs.blame() end, "Gitsigns Blame Buffer")
        map("n", "<leader>jB", function() gs.blame_line({ full = true }) end, "Gitsigns Blame Line")

        map("n", "<leader>j{", gs.diffthis, "Gitsigns Diff This")
        map("n", "<leader>j}", function() gs.diffthis("~") end, "Gitsigns Diff This ~")

        map({ "o", "x" }, "iu", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
    keys = {
      {
        "<leader>jA",
        function()
          vim.cmd("Git add -A")
          vim.cmd("Git commit -m 'add files/dirs'")
          vim.cmd("Git push origin main")
        end,
        desc = "Git add, commit, push",
      },
      {
        "<leader>ja",
        function()
          vim.cmd("Git add %")
        end,
        desc = "Git add %",
      },
    },
  },
}
