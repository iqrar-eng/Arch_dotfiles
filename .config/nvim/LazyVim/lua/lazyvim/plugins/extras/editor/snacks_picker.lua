-- stylua: ignore start
local globs = {
  "**/_cacache/**",
  "**/.cache/**",
  "**/.cargo/**",
  "**/.copilot/**",
  "**/copyq/items**",
  "**/.git/**",
  "**/.github/**",
  "**/go/**",
  "**license**",
  "**License**",
  "**LICENSE**",
  "**/.local/bin**",
  "**/.local/lib**",
  "**/.local/state/**",
  "**.log",
  "**.LOG",
  "**/mason/packages/**",
  "**/mise/**",
  "**/mozilla/firefox/**",
  "**/node_modules/**",
  "**/.npm/**",
  "**/nvim/mason**",
  "**/.nvm/**",
  "**/pipx/**",
  "**/pnpm/**",
  "**/.quokka/**",
  "**/Trash/**",
  "**/.Trash-1000/**",
  "**ttf**",
  "**/undodir/**",
}

local function get_basedir()
  local count = vim.v.count
  local buf_path = vim.api.nvim_buf_get_name(0)
  local base = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":h") or vim.uv.cwd()
  if count > 0 then
    for _ = 1, count do
      base = vim.fn.fnamemodify(base, ":h")
    end
  end
  return base
end

if lazyvim_docs then
  -- In case you don't want to use `:LazyExtras`,
  -- then you need to set the option below.
  vim.g.lazyvim_picker = "snacks"
end

---@module 'snacks'

---@type LazyPicker
local picker = {
  name = "snacks",
  commands = {
    files = "files",
    live_grep = "grep",
    oldfiles = "recent",
  },

  ---@param source string
  ---@param opts? snacks.picker.Config
  open = function(source, opts)
    return Snacks.picker.pick(source, opts)
  end,
}
if not LazyVim.pick.register(picker) then
  return {}
end

return {
  desc = "Fast and modern file picker",
  recommended = true,
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = { win = { width = 0, height = 0 } },
      scratch = {
        autowrite = false, -- prevent the callback that re-hides the buffer
        win_by_ft = { lua = { keys = { ["source"] = false, }, }, },
      },
      indent = {
        indent = {
          hl = {
            "SnacksIndent1",
            "SnacksIndent2",
            "SnacksIndent3",
            "SnacksIndent4",
            "SnacksIndent5",
            "SnacksIndent6",
            "SnacksIndent7",
            "SnacksIndent8",
            "SnacksIndent9",
            "SnacksIndent10",
            "SnacksIndent11",
            "SnacksIndent12",
          },
        },
        scope = { enabled = false },
      },
      scope = {
        keys = {
          textobject = {
            id = {
              min_size = 2, -- minimum size of the scope
              edge = false, -- inner scope
              cursor = false,
              treesitter = { blocks = { enabled = false } },
              desc = "inner scope",
            },
            ad = {
              cursor = false,
              min_size = 2, -- minimum size of the scope
              treesitter = { blocks = { enabled = false } },
              desc = "full scope",
            },
          },
        },
      },
      scroll = { enabled = false },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      image = { doc = { inline = false } },
      input = { win = { b = { completion = true } } },
      toggle = { map = LazyVim.safe_keymap_set },
      notifier = {},
      words = {},
      styles = {
        scratch = { position = "current", keys = { q = false, }, },
        input = {
          keys = {
            i_ctrl_c = { "<C-c>", "cancel", mode = "i" },
            n_ctrl_c = { "<C-c>", "cancel", mode = "n" },
          },
        },
      },
      picker = {
        matcher = { ignorecase = true, smartcase = false, },
        layout = "custom_layout",
        layouts = {
          custom_layout_list_only = {
            layout = {
              width = 0,
              min_width = 0,
              height = 0,
              box = "vertical",
              { win = "input", height = 1 },
              { win = "list" },
            },
          },
          custom_layout = {
            layout = {
              reverse = true,
              backdrop = false,
              width = 0,
              min_width = 0,
              height = 0,
              box = "vertical",
              { win = "preview", height = 0.7 },
              { win = "input", height = 1 },
              { win = "list" },
            },
          },
        },

        actions = {
          -- Snacks.picker.grep() closes any picker of the same source before opening a
          -- new one (see snacks/picker/init.lua:M.pick). Since this action runs from
          -- inside a grep picker, that would just close us with nothing replacing it.
          -- Call the constructor .new( ... ) to stack a new grep picker on top instead.
          picker_grep = function(picker, item)
            if item then
              require("snacks.picker.core.picker").new({ source = "grep", cwd = Snacks.picker.util.dir(item) })
            end
          end,

          picker_files = function(picker, item)
            if not item then
              return
            end
            require("snacks.picker.core.picker").new({ source = "files", cwd = Snacks.picker.util.dir(item) })
          end,

          picker_open_tmux_window_root = function(picker, item)
            if not item then
              return
            end
            local path = Snacks.picker.util.path(item)
            if not path then
              return
            end
            local buf = vim.fn.bufadd(path)
            vim.fn.bufload(buf)
            local root = LazyVim.root.get({ buf = buf })

            vim.fn.jobstart("tmux new-window -c " .. vim.fn.shellescape(root), { detach = true })
            vim.fn.jobstart([[hyprctl dispatch "hl.dsp.focus({ workspace = "3" })" >/dev/null]], { detach = true })
          end,

          picker_open_tmux_window_dir = function(picker, item)
            if not item then
              return
            end
            local path = Snacks.picker.util.path(item)
            if not path then
              return
            end

            -- if the item is a file, use its parent directory
            local dir = path
            local stat = vim.uv.fs_stat(path)
            if stat and stat.type ~= "directory" then
              dir = vim.fn.fnamemodify(path, ":h")
            end

            vim.fn.jobstart("tmux new-window -c " .. vim.fn.shellescape(dir), { detach = true })
            vim.fn.jobstart([[hyprctl dispatch "hl.dsp.focus({ workspace = "3" })" >/dev/null]], { detach = true })
          end,

          picker_grep_root = function(picker, item)
            if not item then
              return
            end
            local path = Snacks.picker.util.path(item)
            if not path then
              return
            end
            local buf = vim.fn.bufadd(path)
            local root = LazyVim.root.get({ buf = buf })
            require("snacks.picker.core.picker").new({ source = "grep", cwd = root })
          end,

          picker_files_root = function(picker, item)
            if not item then
              return
            end
            local path = Snacks.picker.util.path(item)
            if not path then
              return
            end
            local buf = vim.fn.bufadd(path)
            vim.fn.bufload(buf)
            local root = LazyVim.root.get({ buf = buf })
            require("snacks.picker.core.picker").new({ source = "files", cwd = root })
          end,

          picker_grep_current_selected = function(picker)
            local paths = vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
            if #paths == 0 then
              return
            end
            require("snacks.picker.core.picker").new(Snacks.picker.config.get({
              source = "grep",
              dirs = paths,
            }))
          end,

          yank_file_uri = function(picker)
            local items = picker:selected({ fallback = true })
            if #items == 0 then
              return
            end
            local count = vim.v.count
            local vals = vim.tbl_filter(
              function(v)
                return v ~= nil
              end,
              vim.tbl_map(function(it)
                local p = Snacks.picker.util.path(it)
                if not p then
                  return nil
                end
                p = vim.fn.fnamemodify(p, ":p")
                local path = count == 0 and p or vim.fn.fnamemodify(p, string.rep(":h", count))
                return "file://" .. path
              end, items)
            )
            local uri_list = table.concat(vals, "\n")
            local function js_quote(s)
              return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
            end
            local gnome = "copy\n" .. uri_list
            local script = ("copy('text/uri-list',%s,'x-special/gnome-copied-files',%s)"):format(
              js_quote(uri_list),
              js_quote(gnome)
            )
            vim.fn.jobstart({ "copyq", "eval", "--", script })
            Snacks.notify("\n" .. uri_list .. "\n", { title = "Copied " .. #vals })
          end,

          yank_list = function(picker)
            local items = picker:selected({ fallback = true })
            if #items == 0 then
              return
            end
            local lines = {}
            for _, it in ipairs(items) do
              table.insert(lines, it.text or "")
            end
            local content = table.concat(lines, "\n") .. "\n"
            vim.fn.setreg("+", content)
            local line_count = #items
            Snacks.notify(content, {
              title = ("Yanked %d item(s) | %d line(s) to `*`"):format(#items, line_count),
            })
          end,

          yank_preview = function(picker)
            local items = picker:selected({ fallback = true })
            if #items == 0 then
              return
            end
            local chunks = {}
            for _, it in ipairs(items) do
              if type(it.preview) == "table" and it.preview.text then
                table.insert(chunks, it.preview.text)
              elseif it.buf and vim.api.nvim_buf_is_loaded(it.buf) then
                table.insert(chunks, table.concat(vim.api.nvim_buf_get_lines(it.buf, 0, -1, false), "\n"))
              elseif it.file then
                local path = vim.fn.expand(Snacks.picker.util.path(it))
                if vim.fn.filereadable(path) == 1 then
                  table.insert(chunks, table.concat(vim.fn.readfile(path), "\n"))
                end
              elseif it.text or it.data then
                table.insert(chunks, it.text or it.data)
              end
            end
            if #chunks == 0 then
              return
            end
            local content = table.concat(chunks, "\n\n")
            local line_count = select(2, content:gsub("\n", "\n")) + 1
            if line_count > 1000 then
              -- multiple items, or content too large: dump to tmp file, copy as uri-list via copyq eval
              local tmpfile = vim.fn.tempname() .. ".txt"
              vim.fn.writefile(vim.split(content, "\n"), tmpfile)
              local uri_list = "file://" .. tmpfile .. "\n"
              local gnome = "copy\n" .. uri_list
              local script = ("copy('text/uri-list',%s,'x-special/gnome-copied-files',%s)"):format(
                vim.json.encode(uri_list),
                vim.json.encode(gnome)
              )
              vim.fn.jobstart({ "copyq", "eval", "--", script })
              Snacks.notify(
                tmpfile,
                { title = ("Yanked %d item(s) | %d line(s) to tmp file:"):format(#items, line_count) }
              )
            else
              vim.fn.setreg("+", content)
              Snacks.notify(content, { title = ("Yanked %d item(s) | %d line(s) to `*`"):format(#items, line_count) })
            end
          end,
        },

        sources = {
          harpoon = {
            finder = function(opts, ctx)
              local list = require("harpoon"):list()
              local files = {}
              for idx = 1, list:length() do
                local item = list:get(idx)
                if item then
                  table.insert(files, {
                    text = item.value,
                    file = item.value,
                    idx = idx,
                  })
                end
              end
              return files
            end,
            format = "file",
            preview = "file",
            confirm = "jump",
            actions = {
              harpoon_remove = function(picker)
                local items = picker:selected({ fallback = true })
                if #items == 0 then
                  return
                end

                local harpoon = require("harpoon")
                local list = harpoon:list()

                -- remove by VALUE, not by cached idx — idx can be stale/duplicated
                local values_to_remove = {}
                for _, it in ipairs(items) do
                  values_to_remove[it.file] = true
                end

                -- walk the underlying items high-to-low and splice them out directly
                -- (list:remove_at leaves holes in some harpoon2 versions when the
                -- internal table already has gaps; rebuilding is the reliable fix)
                local kept = {}
                for i = 1, list:length() do
                  local item = list:get(i)
                  if item and not values_to_remove[item.value] then
                    table.insert(kept, item)
                  end
                end

                list.items = kept
                harpoon:sync()
                picker:find()
              end,
            },
            win = {
              input = {
                keys = {
                  ["<C-K>"] = { "harpoon_remove", mode = { "n", "x", "s", "i" } },
                },
              },
            },
          },

          icons = { layout = { preset = "custom_layout_list_only" } },
          search_history = { layout = { preset = "custom_layout_list_only" } },
          command_history = { layout = { preset = "custom_layout_list_only" } },
          highlights = { layout = { preset = "custom_layout" } },
          lines = { layout = { preview = "top", preset = "custom_layout" } },
          keymaps = { plugs = true },
          todo_comments = { hidden = true, exclude = globs },
          files = { hidden = true, exclude = globs, follow = true, },
          grep = { hidden = true, exclude = globs, regex = false, },
          grep_word = { hidden = true, exclude = globs, auto_confirm = true, },
        },
        win = {
          input = {
            keys = {
              -- default keys select mode support
              ["<CR>"] = { "confirm", mode = { "n", "i", "s" } },
              ["<S-CR>"] = { { "pick_win", "jump" }, mode = { "n", "i", "s" } },
              ["<c-t>"] = { "tab", mode = { "n", "i", "s" } },
              ["<C-Down>"] = { "history_forward", mode = { "i", "n", "s" } },
              ["<C-Up>"] = { "history_back", mode = { "i", "n", "s" } },
              ["<Down>"] = { "list_down", mode = { "i", "n", "s" } },
              ["<Up>"] = { "list_up", mode = { "i", "n", "s" } },
              ["<Tab>"] = { "select_and_next", mode = { "i", "n", "s" } },
              ["<S-Tab>"] = { "select_and_prev", mode = { "i", "n", "s" } },
              ["<a-h>"] = { "toggle_hidden", mode = { "i", "n", "s" } },
              ["<a-i>"] = { "toggle_ignored", mode = { "i", "n", "s" } },
              ["<a-r>"] = { "toggle_regex", mode = { "i", "n", "s" } },
              ["<a-p>"] = { "toggle_preview", mode = { "i", "n", "s" } },
              ["<a-w>"] = { "cycle_win", mode = { "i", "n", "s" } },
              ["<c-g>"] = { "toggle_live", mode = { "i", "n", "s" } },
              ["<c-q>"] = { "qflist", mode = { "i", "n", "s" } },
              ["<c-s>"] = { "edit_split", mode = { "i", "n", "s" } },
              ["<c-v>"] = { "edit_vsplit", mode = { "i", "n", "s" } },

              ["<C-c>"] = { "cancel", mode = { "n", "x", "s", "i" } },
              ["<M-s>"] = { "yank_preview", mode = { "n", "x", "s", "i" } },
              ["<M-d>"] = { "yank_list", mode = { "n", "x", "s", "i" } },
              ["<C-S-T>"] = { "picker_open_tmux_window_dir", mode = { "n", "x", "s", "i" } },
              ["<C-S-R>"] = { "picker_open_tmux_window_root", mode = { "n", "x", "s", "i" } },
              ["<C-^>"] = { "explorer_yank", mode = { "n", "x", "s", "i" } },
              ["<M-g>"] = { "explorer_del", mode = { "n", "x", "s", "i" } },
              ["<C-S-B>"] = { "yank_file_uri", mode = { "n", "x", "s", "i" } },
              ["k"] = { "n", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["K"] = { "N", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["<C-a>"] = {
                function()
                  require("dial.map").manipulate("increment", "normal")
                end,
                mode = { "n" },
                desc = "Increment",
              },
              ["<C-x>"] = {
                function()
                  require("dial.map").manipulate("decrement", "normal")
                end,
                mode = { "n" },
                desc = "Decrement",
              },
              ["<C-L>"] = { "focus_list", mode = { "n", "x", "s", "i" } },
              ["<PageUp>"] = { "list_scroll_up", mode = { "n", "x", "s", "i" } },
              ["<PageDown>"] = { "list_scroll_down", mode = { "n", "x", "s", "i" } },
              ["<C-Home>"] = { "list_top", mode = { "n", "x", "s", "i" } },
              ["<C-End>"] = { "list_bottom", mode = { "n", "x", "s", "i" } },
              ["<M-2>"] = { "preview_scroll_down", mode = { "n", "x", "s", "i" } },
              ['<M-3>'] = { "preview_scroll_up", mode = { "n", "x", "s", "i" } },
              ["<C-F>"] = { "picker_grep_current_selected", mode = { "n", "x", "s", "i" } },
              ["<C-S-W>"] = { "picker_files", mode = { "n", "x", "s", "i" } },
              ["<C-S-N>"] = { "picker_grep", mode = { "n", "x", "s", "i" } },
              ["<M-C-C>"] = { "picker_files_root", mode = { "n", "x", "s", "i" } },
              ["<M-C-D>"] = { "picker_grep_root", mode = { "n", "x", "s", "i" } },
              ["<M-5>"] = { vim.fn["repeat"]({ "preview_scroll_left" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-8>"] = { vim.fn["repeat"]({ "preview_scroll_right" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-6>"] = { vim.fn["repeat"]({ "preview_scroll_down" }, 999), mode = { "n", "x", "s", "i" }, },
              ["<M-7>"] = { vim.fn["repeat"]({ "preview_scroll_up" }, 999), mode = { "n", "x", "s", "i" }, },
              ["h"] = "list_down",
              ["l"] = "list_up",
              ["<C-J>"] = { "select_all", mode = { "n", "x", "s", "i" } },
              ["<C-K>"] = { "bufdelete", mode = { "n", "x", "s", "i" } },
              ["<C-x>"] = { "<C-X>", "<Insert>", expr = true, mode = { "i" } },
            },
          },
          list = {
            keys = {
              ["<C-c>"] = { "cancel", mode = { "n", "x", "s", "i" } },
              ["<M-s>"] = { "yank_preview", mode = { "n", "x", "s", "i" } },
              ["<M-d>"] = { "yank_list", mode = { "n", "x", "s", "i" } },
              ["<C-S-T>"] = { "picker_open_tmux_window_dir", mode = { "n", "x", "s", "i" } },
              ["<C-S-R>"] = { "picker_open_tmux_window_root", mode = { "n", "x", "s", "i" } },
              ["<C-^>"] = { "explorer_yank", mode = { "n", "x", "s", "i" } },
              ["<M-g>"] = { "explorer_del", mode = { "n", "x", "s", "i" } },
              ["<C-S-B>"] = { "yank_file_uri", mode = { "n", "x", "s", "i" } },
              ["k"] = { "n", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["K"] = { "N", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["/"] = { "/", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["?"] = { "?", mode = { "n", "x" }, expr = true, desc = "delete word" },
              ["<C-c>"] = "close",
              ["<PageUp>"] = "list_scroll_up",
              ["<PageDown>"] = "list_scroll_down",
              ["<C-Home>"] = "list_top",
              ["<C-End>"] = "list_bottom",
              ["<M-2>"] = "preview_scroll_down",
              ['<M-3>'] = "preview_scroll_up",
              ["<C-F>"] = { "picker_grep_current_selected", mode = { "n", "x", "s", "i" } },
              ["<C-S-W>"] = { "picker_files", mode = { "n", "x", "s", "i" } },
              ["<C-S-N>"] = { "picker_grep", mode = { "n", "x", "s", "i" } },
              ["<M-C-C>"] = { "picker_files_root", mode = { "n", "x", "s", "i" } },
              ["<M-C-D>"] = { "picker_grep_root", mode = { "n", "x", "s", "i" } },
              ["<M-5>"] = { vim.fn["repeat"]({ "preview_scroll_left" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-8>"] = { vim.fn["repeat"]({ "preview_scroll_right" }, 130), mode = { "n", "x", "s", "i" }, },
              ["<M-6>"] = { vim.fn["repeat"]({ "preview_scroll_down" }, 999), mode = { "n", "x", "s", "i" }, },
              ["<M-7>"] = { vim.fn["repeat"]({ "preview_scroll_up" }, 999), mode = { "n", "x", "s", "i" }, },
              ["<C-J>"] = { "select_all", mode = { "n", "x", "s", "i" } },
              ["<C-K>"] = { "bufdelete", mode = { "n", "x", "s", "i" } },
            },
          },
          preview = {
            keys = {
              ["<C-c>"] = { "cancel", mode = { "n", "x", "s", "i" } },
            },
          },
        },
      },
    },
    keys = {
      -- ── grepFile Specific Dotfiles ──────────────────────────────────────
      { "<leader>ay", function() LazyVim.pick("grep", { dirs = { "/etc/keyd/default.conf" } })() end, desc = "grepFile keyd config", mode = { "n", "x" } }, -- ── Find / Grep by Directory ──────────────────────────────────────────────
      { "<C-L>",     LazyVim.pick("files"), desc = "Find Files (root dir)", mode = { "n", "x" } },
      { "<BS><PageDown>", LazyVim.pick("grep"),  desc = "Grep (root dir)",       mode = { "n", "x" } },
      { "<BS><Home>", LazyVim.pick("grep_word"), desc = "Word/Selection (root dir)", mode = { "n", "x" } },
      { "<BS><Up>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)", mode = { "n", "x" } },
      { "<BS><PageUp>", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)", mode = { "n", "x" } },
      { "<BS><End>", LazyVim.pick("grep_word", { root = false }), desc = "Word/Selection (cwd)", mode = { "n", "x" } },
      { "<leader>ls", LazyVim.pick("files", { cwd = vim.fn.expand("~/.config/scripts") }), desc = "Find Files scripts", mode = { "n", "x" } },
      { "<leader>lS", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.config/scripts") }), desc = "Grep scripts", mode = { "n", "x" } },
      { "<leader>lv", LazyVim.pick("files", { cwd = vim.fn.expand("~/.config/nvim") }), desc = "Find Files nvim", mode = { "n", "x" } },
      { "<leader>lV", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.config/nvim") }), desc = "Grep nvim", mode = { "n", "x" } },
      { "<leader>lq", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/prisma/apps/docs/content/docs/") }), desc = "Find Files prisma", mode = { "n", "x" } },
      { "<leader>lQ", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/prisma/apps/docs/content/docs/") }), desc = "Grep prisma", mode = { "n", "x" } },
      { "<leader>lb", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/better-auth/docs/content/docs") }), desc = "Find Files better-auth", mode = { "n", "x" } },
      { "<leader>lB", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/better-auth/docs/content/docs") }), desc = "Grep better-auth", mode = { "n", "x" } },
      { "<leader>lx", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/next.js/docs/01-app") }), desc = "Find Files next.js", mode = { "n", "x" } },
      { "<leader>lX", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/next.js/docs/01-app") }), desc = "Grep next.js", mode = { "n", "x" } },
      { "<leader>ld", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/node/doc/api") }), desc = "Find Files node", mode = { "n", "x" } },
      { "<leader>lD", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/node/doc/api") }), desc = "Grep node", mode = { "n", "x" } },
      { "<leader>la", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/api") }), desc = "Find Files mdn api", mode = { "n", "x" } },
      { "<leader>lA", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/api") }), desc = "Grep mdn api", mode = { "n", "x" } },
      { "<leader>lh", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/http") }), desc = "Find Files mdn http", mode = { "n", "x" } },
      { "<leader>lH", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/http") }), desc = "Grep mdn http", mode = { "n", "x" } },
      { "<leader>lj", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/javascript") }), desc = "Find Files mdn javascript", mode = { "n", "x" } },
      { "<leader>lJ", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/mdn/files/en-us/web/javascript") }), desc = "Grep mdn javascript", mode = { "n", "x" } },
      { "<leader>lr", LazyVim.pick("files", { cwd = vim.fn.expand("~/.src/react/src/content/reference/") }), desc = "Find Files react", mode = { "n", "x" } },
      { "<leader>lR", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.src/react/src/content/reference/") }), desc = "Grep react", mode = { "n", "x" } },
      { "<leader>l<CR>", LazyVim.pick("files", { cwd = vim.fn.expand("~/.local/share/nvim/lazy/") }), desc = "Find Files react", mode = { "n", "x" } },
      { "<leader>l<S-CR>", LazyVim.pick("grep", { cwd = vim.fn.expand("~/.local/share/nvim/lazy/") }), desc = "Grep react", mode = { "n", "x" } },
      -- ── Core Navigation ──────────────────────────────────────────────────────
      { "<BS><Down>", LazyVim.pick("buffers"), desc = "Find Files Buffers", mode = { "n", "x" } },
      { "<BS><Left>", LazyVim.pick("grep_buffers"), desc = "Grep Buffers", mode = { "n", "x" } },
      { "<C-F>", function() LazyVim.pick("grep", { dirs = { vim.api.nvim_buf_get_name(0) } })() end, desc = "Grep Current File", mode = { "n", "x" }, },
      { "<leader>av",       function() Snacks.picker.lines()     end, desc = "Buffer Lines"          },
      { "<leader>k",   function() Snacks.picker.resume()    end, desc = "Resume Last Picker"    },
      { "<BS>?", LazyVim.pick("jumps"), desc = "Jump List", mode = { "n", "x" } },
      { "<BS>0", LazyVim.pick("undo"), desc = "Undo Tree", mode = { "n", "x" } },
      { "<leader><CR>", LazyVim.pick("help"), desc = "Help Pages", mode = { "n", "x" } },
      { "<leader>eq", LazyVim.pick("qflist"), desc = "Quickfix List", mode = { "n", "x" } },
      { "<leader>em", LazyVim.pick("marks"), desc = "Marks", mode = { "n", "x" } },
      { "<leader>ep", LazyVim.pick("lazy"), desc = "Plugin Specs", mode = { "n", "x" } },
      { "<leader>en", LazyVim.pick("notifications"), desc = "Notifications", mode = { "n", "x" } },
      { "<leader>ee", LazyVim.pick("registers"), desc = "Registers", mode = { "n", "x" } },
      { "<leader>ea", LazyVim.pick("autocmds"), desc = "Autocmds", mode = { "n", "x" } },
      { "<leader>eh", LazyVim.pick("command_history"), desc = "Command History", mode = { "n", "x" } },
      { "<leader>el", LazyVim.pick("search_history"), desc = "Search History", mode = { "n", "x" } },
      { "<leader>es", LazyVim.pick("keymaps"), desc = "Keymaps", mode = { "n", "x" } },
      { "<leader>eu", LazyVim.pick("highlights"), desc = "Highlights", mode = { "n", "x" } },
      { "<leader>eg",  function() Snacks.picker()                 end, desc = "All Pickers"     },
      { "<BS>7", LazyVim.pick("man"), desc = "Man Pages", mode = { "n", "x" } },
      { "<BS>6", LazyVim.pick("icons"), desc = "Icons", mode = { "n", "x" } },
      { "<leader>ed", function() LazyVim.pick("files", { cwd = get_basedir() })() end, desc = "Find Files nth current dir", mode = { "n", "x" } },
      { "<leader>ef", function() LazyVim.pick("grep", { cwd = get_basedir() })() end, desc = "Grep nth current dir", mode = { "n", "x" } },
      { "<BS><Right>", LazyVim.pick("harpoon"), desc = "Harpoon Picker", mode = { "n", "x" } },
      { "<BS>(", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<BS>)", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<BS>=", LazyVim.pick("diagnostics"), desc = "Diagnostics", mode = { "n", "x" } },
      { "<BS>+", LazyVim.pick("diagnostics_buffer"), desc = "Buffer Diagnostics", mode = { "n", "x" } },
      { "<BS>.", LazyVim.pick(function(opts) require("aerial").snacks_picker(opts) end), desc = "aerial picker", mode = { "n", "x" } },
      -- git
      { "<leader>hl", function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, desc = "Git Log" },
      { "<leader>hL", function() Snacks.picker.git_log_line({ cwd = LazyVim.root.git() }) end, desc = "Git Log Line" },
      { "<leader>hs", function() Snacks.picker.git_status({ cwd = LazyVim.root.git() }) end, desc = "Git Status" },
      { "<leader>hS", function() Snacks.picker.git_stash({ cwd = LazyVim.root.git() }) end, desc = "Git Stash" },
      { "<leader>hd", function() Snacks.picker.git_diff({ cwd = LazyVim.root.git() }) end, desc = "Git Diff (Hunks)" },
      { "<leader>hD", function() Snacks.picker.git_diff({ cwd = LazyVim.root.git(), base = "origin" }) end, desc = "Git Diff (Origin)" },
      { "<leader>hf", function() Snacks.picker.git_log_file({ cwd = LazyVim.root.git() }) end, desc = "Git Log File" },
      -- lazygit
      { "<leader>hg", function() Snacks.lazygit({ cwd = LazyVim.root.git() }) end,           desc = "Lazygit" },
      { "<leader>hG", function() Snacks.lazygit.log_file({ cwd = LazyVim.root.git() }) end,  desc = "Lazygit file log" },
      { "<leader>hY", function() Snacks.lazygit.log({ cwd = LazyVim.root.git() }) end,       desc = "Lazygit log" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
            { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
            { "gw", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
            { "g<CR>", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
            { "gD", function() Snacks.picker.lsp_declarations() end,     desc= "Goto lsp_declarations" },
            { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming", has = "callHierarchy/incomingCalls" },
            { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing", has = "callHierarchy/outgoingCalls" },
          },
        },
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "LazyFile",
    opts = {},
    keys = {
      { "<leader>e[",     LazyVim.pick("todo_comments"),                desc = "root"},
      { "<leader>e]",   LazyVim.pick.wrap("todo_comments", { root = false }),              desc = "cwd" },
      { "<Up>*", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "<Left>*", function() require("todo-comments").jump_prev() end, desc = "Prev Todo Comment" },
    },
  },
}
