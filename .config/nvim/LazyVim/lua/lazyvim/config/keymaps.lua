-- utility_functions START ===================================================================

local paste_from_clipboard = function()
  local clipboard = vim.fn.getreg("+")
  if vim.api.nvim_get_mode().mode == "c" then
    local cur = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    vim.fn.setcmdline(cur:sub(1, pos - 1) .. clipboard .. cur:sub(pos), pos + #clipboard)
  else
    vim.api.nvim_paste(clipboard, true, -1)
  end
end

local function make_window_jump(win_cmd, move_cmd, input_keys, esc_replace_mode)
  return function()
    local count = vim.v.count1
    local mode = vim.fn.mode()
    local was_insert = mode == "i"
    local was_visual = mode:match("^[vV\22]$") ~= nil

    local visual_key
    if mode == "V" then
      visual_key = "V"
    elseif mode == "\22" then
      visual_key = "<C-v>"
    else
      visual_key = "v"
    end

    if was_insert or was_visual then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), esc_replace_mode, false)
    end

    vim.cmd("wincmd " .. win_cmd)

    if move_cmd:match("^<.+>$") then
      local keys = vim.api.nvim_replace_termcodes(move_cmd, true, false, true)
      for _ = 1, count do
        vim.api.nvim_feedkeys(keys, "m", true)
      end
    else
      vim.cmd("normal " .. count .. move_cmd)
    end

    vim.api.nvim_input(input_keys)

    if was_insert then
      vim.schedule(function()
        vim.cmd("startinsert")
      end)
    elseif was_visual then
      vim.schedule(function()
        local keys = vim.api.nvim_replace_termcodes("`<" .. visual_key .. "``", true, false, true)
        vim.cmd("normal! " .. keys)
      end)
    end
  end
end

-- utility_functions END ===================================================================

vim.keymap.set("n", "<leader>ac", function()
  local reg = vim.fn.getreg("*"):gsub("^:", "")
  vim.fn.histadd("cmd", reg)
  vim.cmd(reg)
end, { desc = "Execute clipboard as :" })

vim.keymap.set({ "n", "o" }, "<M-C-D>", "*<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("x", "<M-C-D>", "<Esc>*gvn<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set({ "n", "o" }, "<M-C-A>", "#<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("x", "<M-C-A>", "<Esc>#gvn<cmd>nohlsearch<CR>", { silent = true })

vim.keymap.set({ "n", "x", "o" }, "m", "e")
vim.keymap.set({ "n", "x", "o" }, "M", "E")
vim.keymap.set({ "n", "x", "o" }, "gm", "ge")
vim.keymap.set({ "n", "x", "o" }, "gM", "gE")

vim.keymap.set("n", "<C-R>", "<C-i>")
vim.keymap.set({ "n", "x", "o" }, "ge", "gM")
vim.keymap.set("n", "<leader>^", "m")

vim.keymap.set("n", "ZR", function()
  vim.defer_fn(function()
    vim.cmd("normal! 8ZR")
  end, 500)
  vim.cmd("wa")
end, { desc = "Reload nvim" })

vim.keymap.set("n", "<C-Q>", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
  end
  vim.defer_fn(function()
    vim.cmd("wqa!")
  end, 50)
end, { desc = "Quit nvim" })

vim.keymap.set("n", "<esc>", function()
  local cc_map = vim.fn.maparg("<C-c>", "n", false, true)
  if type(cc_map) == "table" and cc_map.desc == "Stop exchange" and cc_map.callback then
    cc_map.callback()
  end
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

vim.keymap.set({ "c", "i" }, "<C-x>", "<Insert>")
vim.keymap.set("c", "<C-S-G>", "<C-t>")
vim.keymap.set("c", "<M-C-Q>", "<C-f>")

-- ========================

vim.keymap.set("x", "<M-2>", function()
  vim.cmd("normal! " .. ("jojo"):rep(vim.v.count1))
end, { silent = true, desc = "visual move down" })
vim.keymap.set("x", "<M-3>", function()
  vim.cmd("normal! " .. ("koko"):rep(vim.v.count1))
end, { silent = true, desc = "visual move up" })

vim.keymap.set("x", "<M-4>", function()
  vim.cmd("normal! " .. ("lolo"):rep(vim.v.count1))
end, { silent = true, desc = "visual move right" })
vim.keymap.set("x", "<M-1>", function()
  vim.cmd("normal! " .. ("hoho"):rep(vim.v.count1))
end, { silent = true, desc = "visual move left" })

vim.keymap.set("x", "x", function()
  vim.cmd("normal! " .. ("joko"):rep(vim.v.count1))
end, { silent = true, desc = "visual extend/shrink vertically" })
vim.keymap.set("x", "z", function()
  vim.cmd("normal! " .. ("loho"):rep(vim.v.count1))
end, { silent = true, desc = "visual extend/shrink horizontally" })

-- ========================

vim.keymap.set("n", "<leader>ev", function()
  local file = vim.fn.expand("%")
  if vim.fn.executable(file) == 1 then
    vim.cmd("!chmod -x " .. file)
    vim.notify("chmod -x " .. file, vim.log.levels.WARN)
  else
    vim.cmd("!chmod +x " .. file)
    vim.notify("chmod +x " .. file, vim.log.levels.INFO)
  end
end, { desc = "toggle chmod +x/-x" })

vim.keymap.set("n", "<leader>eb", "<cmd>source %<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<leader>aj", "<cmd>!keyd reload<CR>", { desc = "Reload keyd" })

vim.keymap.set("n", "<leader>a}", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "query" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  vim.treesitter.inspect_tree()
  vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == "query" then
      vim.api.nvim_input("I")
    end
  end)
end, { desc = "Toggle Inspect Tree" })

vim.keymap.set("n", "<leader>a{", vim.show_pos, { desc = "Inspect Pos" })

vim.keymap.set("n", "<C-S-z>", "<C-R>")
vim.keymap.set("n", "<C-z>", "u")
vim.keymap.set("i", "<C-S-z>", "<c-o>:redo<CR>", { silent = true })
vim.keymap.set("i", "<C-z>", "<c-o>:undo<CR>", { silent = true })

vim.keymap.set("n", "<M-C-P>", "g+")
vim.keymap.set("n", "<M-C-N>", "g-")
vim.keymap.set("i", "<M-C-P>", "<c-o>:later<CR>", { silent = true })
vim.keymap.set("i", "<M-C-N>", "<c-o>:earlier<CR>", { silent = true })

vim.keymap.set("i", " ", "<C-]> <C-g>u") -- expands abbreviations, then adds space with undo break
vim.keymap.set("i", "-", "-<c-g>u")
vim.keymap.set("i", "_", "_<c-g>u")
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")
vim.keymap.set("i", ":", ":<c-g>u")

vim.keymap.set("n", "k", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "K", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
vim.keymap.set({ "x", "o" }, "k", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set({ "x", "o" }, "K", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

vim.keymap.set("n", "<leader>ah", "K")

vim.keymap.set({ "n", "x" }, "gJ", function()
  local count = vim.v.count1
  vim.cmd("normal! mz" .. count .. "gJ`z")
end)
vim.keymap.set({ "n", "x" }, "J", function()
  local count = vim.v.count1
  vim.cmd("normal! mz" .. count .. "J`z")
end)

vim.keymap.set({ "n", "i" }, "<M-C-Q>", "<C-^>")
vim.keymap.set("n", "<PageDown>", "<C-d>zz")
vim.keymap.set("n", "<PageUp>", "<C-u>zz")

vim.keymap.set({ "n", "x" }, "<leader>d", '"zd')
vim.keymap.set({ "n", "x" }, "<leader>c", '"zc')
vim.keymap.set({ "n", "x" }, "<leader>y", '"zy')

vim.keymap.set({ "n", "x" }, "<leader>p", '"zp')
vim.keymap.set({ "n", "x" }, "<leader>P", '"zP')
vim.keymap.set({ "n", "x" }, "<Del>P", '"zP')

vim.keymap.set("s", "<Del>", "<BS>i")
vim.keymap.set({ "c", "i" }, "<C-V>", paste_from_clipboard)

vim.keymap.set("n", "<leader>x", '"zx')
vim.keymap.set("n", "<leader>X", '"zX')
vim.keymap.set("n", "<Del>X", '"zX')

vim.keymap.set({ "n", "i" }, "<C-PageDown>", make_window_jump("1w", "h", "\r", "n"), {})
vim.keymap.set({ "n", "i" }, "<C-S-PageDown>", make_window_jump("1w", "<C-End>", "\r", "O"), {})
vim.keymap.set({ "n", "i" }, "<C-PageUp>", make_window_jump("1w", "l", "\r", "O"), {})
vim.keymap.set({ "n", "i" }, "<C-S-PageUp>", make_window_jump("1w", "<C-Home>", "\r", "O"), {})

vim.keymap.set({ "n", "i", "x" }, "<C-P>", make_window_jump("9l", "l", "\r", "O"), {})
vim.keymap.set({ "n", "i", "x" }, "<C-S-P>", make_window_jump("9l", "<C-Home>", "\r", "O"), {})
vim.keymap.set({ "n", "i", "x" }, "<C-G>", make_window_jump("9l", "h", "\r", "n"), {})
vim.keymap.set({ "n", "i", "x" }, "<C-S-G>", make_window_jump("9l", "<C-End>", "\r", "n"), {})

vim.keymap.set({ "n", "x", "o" }, "e", "h")
vim.keymap.set({ "n", "x", "o" }, "n", "l")
vim.keymap.set({ "n", "x" }, "h", "v:count > 1 ? \"m'\" . v:count . 'gj' : 'gj'", { expr = true })
vim.keymap.set({ "n", "x" }, "l", "v:count > 1 ? \"m'\" . v:count . 'gk' : 'gk'", { expr = true })
vim.keymap.set("o", "h", "j")
vim.keymap.set("o", "l", "k")

vim.keymap.set({ "n", "x" }, "-", "v:count > 1 ? \"m'\" . v:count . '-' : '-'", { expr = true })
vim.keymap.set({ "n", "x" }, "+", "v:count > 1 ? \"m'\" . v:count . '+' : '+'", { expr = true })

vim.keymap.set({ "n", "x" }, "<Home>", function()
  return vim.v.count > 1 and ("m'" .. vim.v.count .. "gk$") or "0"
end, { expr = true })

vim.keymap.set({ "n", "x" }, "<End>", function()
  return vim.v.count > 1 and ("m'" .. vim.v.count .. "gj$") or "$"
end, { expr = true })

vim.keymap.set("n", "<leader>i", function()
  vim.cmd("put! =repeat(nr2char(10), v:count1)")
  vim.cmd("'[")
end, { silent = true })
vim.keymap.set("n", "<leader>o", function()
  vim.cmd("put =repeat(nr2char(10), v:count1)")
end, { silent = true })

-- ========================

vim.keymap.set("n", "<leader>a}", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return
  end

  local modifier = ":h"
  if vim.v.count > 0 then
    modifier = modifier .. string.rep(":h", vim.v.count)
  end
  local dir = vim.fn.fnamemodify(path, modifier)

  vim.fn.jobstart("tmux new-window -c " .. vim.fn.shellescape(dir), { detach = true })
  vim.fn.jobstart([[hyprctl dispatch "hl.dsp.focus({ workspace = "3" })" >/dev/null]], { detach = true })
end, { desc = "Open tmux window N parent dir" })

vim.keymap.set("n", "<leader>a{", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return
  end

  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  local root = LazyVim.root.get({ buf = buf })

  vim.fn.jobstart("tmux new-window -c " .. vim.fn.shellescape(root), { detach = true })
  vim.fn.jobstart([[hyprctl dispatch "hl.dsp.focus({ workspace = "3" })" >/dev/null]], { detach = true })
end, { desc = "Open tmux window project root" })

vim.keymap.set("n", "<leader>ab", function()
  local modifier = ":~"
  if vim.v.count > 0 then
    modifier = modifier .. string.rep(":h", vim.v.count)
  end
  vim.fn.system("wl-copy", vim.fn.expand("%" .. modifier))
end, { desc = "Copy relative path N levels up" })

vim.keymap.set("n", "<leader>au", function()
  local modifier = ""
  if vim.v.count > 0 then
    modifier = modifier .. string.rep(":h", vim.v.count)
  end
  vim.fn.system("wl-copy", vim.fn.expand("%" .. modifier))
end, { desc = "Copy absolute path N levels up" })

vim.keymap.set("n", "<C-S-B>", function()
  local p = vim.fn.expand("%:p")
  local count = vim.v.count
  local path = count == 0 and p or vim.fn.fnamemodify(p, string.rep(":h", count))
  local uri = vim.uri_from_fname(path)
  local script = string.format("copy('text/uri-list','%s','x-special/gnome-copied-files','copy\\n%s')", uri, uri)
  vim.fn.jobstart({ "copyq", "eval", "--", script })
  vim.notify(uri, vim.log.levels.INFO)
end, { desc = "yank_file_uri" })

vim.keymap.set("n", "<leader>ec", function()
  local file_src = vim.api.nvim_buf_get_name(0)
  if file_src == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Copy to ", default = file_src, completion = "file" }, function(file_out)
    if not file_out or file_out == "" then
      return
    end
    local dir = vim.fn.fnamemodify(file_out, ":h")
    local res = vim.fn.system({ "mkdir", "-p", dir })
    if vim.v.shell_error ~= 0 then
      vim.notify(res, vim.log.levels.ERROR)
      return
    end
    vim.fn.system({ "cp", "-R", file_src, file_out })
    if vim.v.shell_error ~= 0 then
      vim.notify("Copy failed", vim.log.levels.ERROR)
      return
    end
    vim.notify("Copied to " .. file_out, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(file_out))
  end)
end, { desc = "Copy File To" })

vim.keymap.set("n", "<leader>ex", function()
  local file_src = vim.api.nvim_buf_get_name(0)
  if file_src == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Move to ", default = file_src, completion = "file" }, function(file_out)
    if not file_out or file_out == "" then
      return
    end
    local dir = vim.fn.fnamemodify(file_out, ":h")
    local res = vim.fn.system({ "mkdir", "-p", dir })
    if vim.v.shell_error ~= 0 then
      vim.notify(res, vim.log.levels.ERROR)
      return
    end
    vim.fn.system({ "mv", file_src, file_out })
    if vim.v.shell_error ~= 0 then
      vim.notify("Move failed", vim.log.levels.ERROR)
      return
    end
    vim.notify("Moved to " .. file_out, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(file_out))
  end)
end, { desc = "Move File To" })

require("lazyvim.config.keymaps-beta")
