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

local cmd = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })' && ~/dotfiles/.config/scripts/util/hyprland"

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

vim.keymap.set({ "n", "x", "o" }, "<BS>8", "<Esc>vim*", { remap = true })
vim.keymap.set({ "n", "x", "o" }, "<BS>9", "<Esc>vim#", { remap = true })

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

Snacks.toggle.option("wrap"):map("<leader>er")

vim.keymap.set({ "n", "x" }, "<leader>hv", function()
  Snacks.gitbrowse()
end, { desc = "Git browser (open)" })

vim.keymap.set({ "n", "x" }, "<leader>hc", function()
  Snacks.gitbrowse({
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
  })
end, { desc = "Git browser (copy)" })

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

-- ========================

vim.keymap.set("x", "<leader>o", ':g#^$#normal! "_dd<CR><Cmd>noh<CR>', { silent = true, desc = "Delete blank lines" })

vim.keymap.set("n", "<leader>a<CR>", ":let @+=@:<Left><Insert>", { desc = "let @+ =@x" })
