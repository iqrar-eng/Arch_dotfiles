local buf = vim.api.nvim_get_current_buf()
vim.bo[buf].buflisted = true
vim.bo[buf].buftype = "" -- remove nofile so it shows in buffers picker
vim.bo[buf].bufhidden = "hide" -- ← keep buffer alive so C-^ / e # can reach it

vim.keymap.del("n", "j", { buffer = true })
vim.keymap.del("n", "k", { buffer = true })
