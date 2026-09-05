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

vim.keymap.set({ "n", "i" }, "<C-PageDown>", make_window_jump("1w", "j", "l", "n"), {})
vim.keymap.set({ "n", "i" }, "<C-S-PageDown>", make_window_jump("1w", "<C-End>", "l", "O"), {})
vim.keymap.set({ "n", "i" }, "<C-PageUp>", make_window_jump("1w", "k", "l", "O"), {})
vim.keymap.set({ "n", "i" }, "<C-S-PageUp>", make_window_jump("1w", "<C-Home>", "l", "O"), {})

vim.keymap.set({ "n", "i", "x" }, "<C-P>", make_window_jump("9l", "k", "l", "O"), {})
vim.keymap.set({ "n", "i", "x" }, "<C-S-P>", make_window_jump("9l", "<C-Home>", "l", "O"), {})
vim.keymap.set({ "n", "i", "x" }, "<C-G>", make_window_jump("9l", "j", "l", "n"), {})
vim.keymap.set({ "n", "i", "x" }, "<C-S-G>", make_window_jump("9l", "<C-End>", "l", "n"), {})

-- ========================

vim.keymap.set({ "n", "o" }, "<M-C-D>", "*<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("x", "<M-C-D>", "<Esc>*gvn<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set({ "n", "o" }, "<M-C-A>", "#<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("x", "<M-C-A>", "<Esc>#gvn<cmd>nohlsearch<CR>", { silent = true })

vim.keymap.set("n", "ZR", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
  end
  vim.defer_fn(function()
    vim.cmd("w")
  end, 50)
  vim.defer_fn(function()
    vim.cmd("normal! 8ZR")
  end, 200)
end, { desc = "Reload nvim" })

vim.keymap.set("n", "<C-Q>", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
  end
  vim.defer_fn(function()
    vim.cmd("w")
  end, 50)
  vim.defer_fn(function()
    vim.cmd("qa!")
  end, 200)
end, { desc = "Quit nvim" })

vim.keymap.set("n", "<C-R>", "<C-i>")

vim.keymap.set("n", "<esc>", function()
  local cc_map = vim.fn.maparg("<C-c>", "n", false, true)
  if type(cc_map) == "table" and cc_map.desc == "Stop exchange" and cc_map.callback then
    cc_map.callback()
  end
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

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

vim.keymap.set("n", "<leader>hv", function()
  local file = vim.fn.expand("%")
  if vim.fn.executable(file) == 1 then
    vim.cmd("!chmod -x " .. file)
    vim.notify("chmod -x " .. file, vim.log.levels.WARN)
  else
    vim.cmd("!chmod +x " .. file)
    vim.notify("chmod +x " .. file, vim.log.levels.INFO)
  end
end, { desc = "toggle chmod +x/-x" })

vim.keymap.set("n", "<leader>hb", "<cmd>source %<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<leader>az", "<cmd>!keyd reload<CR>", { desc = "Reload keyd" })
vim.keymap.set("n", "<leader>ab", "<cmd>Lazy<CR>")
vim.keymap.set("n", "<leader>ae", "<cmd>Mason<CR>")

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

vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
vim.keymap.set({ "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set({ "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

vim.keymap.set({ "n", "i" }, "<M-C-_>", "<C-^>")
vim.keymap.set("n", "<PageDown>", "<C-d>zz")
vim.keymap.set("n", "<PageUp>", "<C-u>zz")

vim.keymap.set("s", "<Del>", "<BS>i")

vim.keymap.set({ "n", "x" }, "j", "v:count > 1 ? \"m'\" . v:count . 'j' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count > 1 ? \"m'\" . v:count . 'k' : 'k'", { expr = true })

vim.keymap.set({ "n", "x" }, "-", "v:count > 1 ? \"m'\" . v:count . '-' : '-'", { expr = true })
vim.keymap.set({ "n", "x" }, "+", "v:count > 1 ? \"m'\" . v:count . '+' : '+'", { expr = true })

vim.keymap.set({ "n", "x" }, "<Home>", function()
  return vim.v.count > 1 and ("m'" .. vim.v.count .. "gk$") or "0"
end, { expr = true })

vim.keymap.set({ "n", "x" }, "<End>", function()
  return vim.v.count > 1 and ("m'" .. vim.v.count .. "gj$") or "$"
end, { expr = true })

-- ========================

local function yank_motion_text(type)
  local rv, rt = vim.fn.getreg('"'), vim.fn.getregtype('"')
  if type == "line" then
    vim.cmd("normal! '[V']y")
  elseif type == "block" then
    vim.cmd("normal! `[\22`]y")
  else
    vim.cmd("normal! `[v`]y")
  end
  local text = vim.fn.getreg('"')
  vim.fn.setreg('"', rv, rt)
  return text
end

local function yank_selection_text()
  local rv, rt = vim.fn.getreg('"'), vim.fn.getregtype('"')
  vim.cmd("normal! y")
  local text = vim.fn.getreg('"')
  vim.fn.setreg('"', rv, rt)
  return text
end

local cmd = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })' && ~/archlinux/.config/hypr/bin/paste"

local function bind_send(lhs, cmd, register)
  local global_name = "SlimeBrowserSendOp_" .. lhs:gsub("[^%w]", "_")
  _G[global_name] = function(type)
    vim.fn.setreg(register, yank_motion_text(type))
    vim.fn.jobstart(cmd, { detach = true })
  end
  vim.keymap.set("n", lhs, function()
    vim.o.operatorfunc = "v:lua." .. global_name
    return "g@"
  end, { expr = true, desc = "Send motion to browser" })
  vim.keymap.set("x", lhs, function()
    vim.fn.setreg(register, yank_selection_text())
    vim.fn.jobstart(cmd, { detach = true })
  end, { desc = "Send selection to browser" })
end

bind_send("<leader>f", cmd, "+")

-- ========================

local function bind_send_text(lhs, base_cmd)
  local global_name = "SlimeBrowserSendTextOp_" .. lhs:gsub("[^%w]", "_")
  _G[global_name] = function(type)
    local text = yank_motion_text(type)
    vim.fn.jobstart({ "sh", "-c", base_cmd .. " --text " .. vim.fn.shellescape(text) }, { detach = true })
  end
  vim.keymap.set("n", lhs, function()
    vim.o.operatorfunc = "v:lua." .. global_name
    return "g@"
  end, { expr = true, desc = "Send motion text via --text" })
  vim.keymap.set("x", lhs, function()
    local text = yank_selection_text()
    vim.fn.jobstart({ "sh", "-c", base_cmd .. " --text " .. vim.fn.shellescape(text) }, { detach = true })
  end, { desc = "Send selection text via --text" })
end

bind_send_text("<leader>r", "~/archlinux/.local/bin/clipboard-slime-core --jump")
bind_send_text("<leader>w", "~/archlinux/.local/bin/clipboard-slime-core --execute")
bind_send_text("<leader>q", "~/archlinux/.local/bin/clipboard-slime-core --jump --execute")
bind_send_text("<leader>m", "~/archlinux/.local/bin/clipboard-slime-core --jump --no-cancel")

-- ========================

vim.keymap.set("n", "<leader>a[", function()
  vim.cmd("normal! mz")
  vim.cmd("put! ='stylua: ignore'")
  vim.cmd("normal gcc")
  vim.cmd("normal! ==`z")
  vim.cmd("undojoin")
end, { silent = true, desc = "stylua: ignore above" })

vim.keymap.set("n", "<leader>a]", function()
  vim.cmd("normal! mz")
  vim.cmd("put ='========================'")
  vim.cmd("normal gcc")
  vim.cmd("put =''")
  vim.cmd("normal! =k`z")
  vim.cmd("undojoin")
end, { silent = true, desc = "separator below" })

vim.keymap.set({ "n", "x", "o" }, "<BS>8", "<Esc>vie*", { remap = true })
vim.keymap.set({ "n", "x", "o" }, "<BS>9", "<Esc>vie#", { remap = true })

vim.keymap.set({ "n", "x", "o" }, "<BS>*", "<Esc>viW*", { remap = true })
vim.keymap.set({ "n", "x", "o" }, "<BS>#", "<Esc>viW#", { remap = true })

vim.keymap.set({ "n", "x", "o" }, "|", "/\\V")
vim.keymap.set({ "n", "x", "o" }, "\\", "?\\V")

vim.keymap.set({ "n", "x", "o" }, "<Left>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Right>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Down>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Up>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<Del>", "<nop>")
vim.keymap.set({ "n", "x", "o" }, ">", "<nop>")
vim.keymap.set({ "n", "x", "o" }, "<", "<nop>")
vim.keymap.set({ "x", "o" }, "<LeftMouse>", "<nop>")
vim.keymap.set({ "x", "o" }, "<RightMouse>", "<nop>")

Snacks.toggle.option("wrap"):map("<leader>hr")

vim.keymap.set("x", "<leader>o", ':g#^$#normal! "_dd<CR><Cmd>noh<CR>', { silent = true, desc = "Delete blank lines" })
vim.keymap.set("n", "<leader>a<CR>", ":let @+=@:<Left><Insert>", { desc = "let @+ =@x" })

-- ========================

vim.keymap.set("i", "<C-S-End><Del>", '<C-Home><C-v><Esc>"zd<C-End>', { remap = true, silent = true })

vim.keymap.set("c", "<S-End><Del><BS>", '<c-f>"zD<C-c>')

vim.keymap.set({ "c", "i" }, "<C-BS>", "<C-s-w>")
vim.keymap.set({ "c", "i" }, "<S-Home><BS>", "<C-u>")

vim.keymap.set("i", "<C-Del>", function()
  local col = vim.fn.col(".")
  if col == 1 then
    return '<esc>"zdei'
  else
    return '<esc>l"zdei'
  end
end, { expr = true })
vim.keymap.set("c", "<C-Del>", '<c-f>"zde<C-c>')

vim.keymap.set("i", "<S-End><Del>", function()
  local col = vim.fn.col(".")
  if col == 1 then
    return '<esc>"zd$a'
  else
    return '<esc>l"zd$a'
  end
end, { expr = true })
vim.keymap.set("c", "<S-End><Del>", '<c-f>"zD<C-c>')
