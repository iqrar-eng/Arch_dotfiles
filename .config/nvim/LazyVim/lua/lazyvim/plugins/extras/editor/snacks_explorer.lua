return {
  {
    "folke/snacks.nvim",
    event = "VeryLazy",
    opts = {
      picker = {
        sources = {
          explorer = {
            exclude = { ".git", ".github" },
            hidden = true,
            ignored = true,
            layout = { preset = "my_sidebar", preview = true },
            icons = { tree = { vertical = "│", middle = "├", last = "└" } },
            layouts = {
              my_sidebar = {
                preview = "main",
                layout = {
                  backdrop = false,
                  width = 28,
                  height = 0,
                  position = "left",
                  box = "vertical",
                  { win = "list" },
                  { win = "preview", height = 0.3 },
                },
              },
            },
            win = {
              list = {
                keys = {
                  ["h"] = "explorer_close", -- close directory
                  ["j"] = {
                    function()
                      return vim.v.count > 1 and ("m'" .. vim.v.count .. "gj") or "gj"
                    end,
                    mode = { "n", "x" },
                    expr = true,
                    desc = "move down (visual line)",
                  },
                  ["k"] = {
                    function()
                      return vim.v.count > 1 and ("m'" .. vim.v.count .. "gk") or "gk"
                    end,
                    mode = { "n", "x" },
                    expr = true,
                    desc = "move up (visual line)",
                  },
                  ["l"] = "confirm",
                },
              },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>ht",
        function()
          local explorer = Snacks.picker.get({ source = "explorer" })[1]
          if explorer then
            explorer:close()
            return
          end
          local buf = vim.api.nvim_get_current_buf()
          local root = LazyVim.root.get({ buf = buf })
          Snacks.explorer({ cwd = root, focus = false })
        end,
        desc = "Toggle NvimTree (find file)",
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("SnacksExplorerRoot", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local buftype = vim.bo[buf].buftype
          if vim.tbl_contains({ "terminal", "nofile", "quickfix", "prompt" }, buftype) then
            return
          end
          local file = vim.api.nvim_buf_get_name(buf)
          if file == "" or not vim.uv.fs_stat(file) then
            return
          end
          file = vim.uv.fs_realpath(file) or file

          local explorer = Snacks.picker.get({ source = "explorer" })[1]
          if not explorer then
            return
          end
          local root = LazyVim.root.get({ buf = buf })
          root = vim.uv.fs_realpath(root) or root

          vim.schedule(function()
            if explorer:cwd() ~= root then
              explorer:set_cwd(root)
            end
            require("snacks.explorer").reveal({ file = file })
          end)
        end,
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if #vim.api.nvim_tabpage_list_wins(0) >= 2 then
            return
          end
          local buf = vim.api.nvim_get_current_buf()
          local file = vim.api.nvim_buf_get_name(buf)
          file = (file ~= "" and vim.uv.fs_realpath(file)) or file
          require("lazy").update({ show = false })
          if file ~= "" then
            vim.schedule(function()
              local picker = require("snacks.explorer").reveal({ file = file })
              if picker then
                picker.opts.enter = false
              end
            end)
          end
        end,
      })
    end,
  },

  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>hz", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree (closes explorer first)" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 3
      vim.g.undotree_DiffAutoOpen = 0
      vim.g.undotree_HelpLine = 0
      vim.cmd([[
      function! g:Undotree_CustomMap()
      noremap <buffer> <C-Home> gg<plug>UndotreeEnter
      noremap <buffer> <C-End> G<plug>UndotreeEnter
      noremap <buffer> <PageDown> <C-d>zz<plug>UndotreeEnter
      noremap <buffer> <PageUp> <C-u>zz<plug>UndotreeEnter
      noremap <buffer><expr> j v:count > 1 ? "j\<Plug>UndotreeEnter" : "\<Plug>UndotreePreviousState"
      noremap <buffer><expr> k v:count > 1 ? "k\<Plug>UndotreeEnter" : "\<Plug>UndotreeNextState"
      noremap <buffer> l <plug>UndotreeEnter<C-W>h
      noremap <buffer> <C-S-Z> <plug>UndotreeRedo
      noremap <buffer> <C-Z> <plug>UndotreeUndo
      noremap <buffer> t <plug>UndotreeDiffToggle
      noremap <buffer> g? <plug>UndotreeHelp
      noremap <buffer> ? ?
      endfunction
      ]])
    end,
  },
}
