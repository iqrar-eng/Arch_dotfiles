return {
  {
    "jpalardy/vim-slime",
    event = "VeryLazy",
    -- stylua: ignore
    init = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_default_config = {
        socket_name = vim.split(vim.env.TMUX or "default", ",")[1],
        target_pane = ":",
      }
      vim.g.slime_dont_ask_default = 1
      vim.g.slime_bracketed_paste = 1
      vim.g.slime_no_mappings = 1

      -- behavior flags with defaults
      vim.g.slime_jump_after_send = 0 -- whether to call keyd jump after send
      vim.g.slime_no_execute = 0 -- whether to suppress Enter (paste only)

      vim.cmd([[
        function! SlimeOverrideSend(config, text)
        let config = copy(a:config)
        if exists('g:slime_send_target_pane')
        let config.target_pane = g:slime_send_target_pane
        endif
        call system("tmux -L " . shellescape(config.socket_name)
        \ . " send-keys -t " . shellescape(config.target_pane) . " C-c")
        if get(g:, 'slime_no_execute', 0)
        let text = substitute(a:text, '\n\+$', '', '')
        if len(text) == 0 | return | endif
        let socket = shellescape(config.socket_name)
        let pane   = shellescape(config.target_pane)
        call system("printf %s " . shellescape(text)
        \ . " | tmux -L " . socket . " load-buffer -")
        call system("tmux -L " . socket
        \ . " paste-buffer -d -p -t " . pane)
        else
        call slime#targets#tmux#send(config, a:text)
        endif
        if get(g:, 'slime_jump_after_send', 0)
        call jobstart('hyprctl dispatch ''hl.dsp.focus({ workspace = "3" })'' >/dev/null', {'detach': 1})
        endif
        let g:slime_no_execute = 0
        let g:slime_jump_after_send = 0
        unlet! g:slime_send_target_pane
        endfunction
        ]])

      local function slime(plug, opts)
        opts = opts or {}
        local pre = ""
        pre = pre .. string.format("<Cmd>let g:slime_jump_after_send=%d<CR>", opts.jump and 1 or 0)
        pre = pre .. string.format("<Cmd>let g:slime_no_execute=%d<CR>", opts.execute == false and 1 or 0)
        if opts.pane then
          pre = pre .. string.format("<Cmd>let g:slime_send_target_pane='%s'<CR>", opts.pane)
        end
        return pre .. plug
      end

      vim.keymap.set("n", "<leader>w", slime("<Plug>SlimeMotionSend"), { remap = true, desc = "Send motion to REPL" })
      vim.keymap.set("x", "<leader>w", slime("<Plug>SlimeRegionSend"), { remap = true, desc = "Send selection to REPL" })

      vim.keymap.set("n", "<leader>q", slime("<Plug>SlimeMotionSend", { jump = true }), { remap = true, desc = "Send motion to REPL and jump" })
      vim.keymap.set("x", "<leader>q", slime("<Plug>SlimeRegionSend", { jump = true }), { remap = true, desc = "Send selection to REPL and jump" })

      vim.keymap.set("n", "<leader>r", slime("<Plug>SlimeMotionSend", { execute = false, jump = true }), { remap = true, desc = "Paste motion to REPL (no execute) and jump" })
      vim.keymap.set("x", "<leader>r", slime("<Plug>SlimeRegionSend", { execute = false, jump = true }), { remap = true, desc = "Paste selection to REPL (no execute) and jump" })
    end,
  },
}
