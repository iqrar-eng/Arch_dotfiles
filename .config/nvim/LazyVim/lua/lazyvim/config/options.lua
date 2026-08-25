vim.g.mapleader = " "
vim.g.maplocalleader = " g"
vim.opt.number = true
vim.g.markdown_recommended_style = 0
vim.g.autoformat = false
vim.g.snacks_animate = false
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_cmp = "auto"
vim.g.ai_cmp = true
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
-- Set LSP servers to be ignored when used with `util.root.detectors.lsp`
-- for detecting the LSP root
vim.g.root_lsp_ignore = { "copilot" }
vim.g.deprecation_warnings = false
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.foldtext = ""
vim.opt.formatexpr = "v:lua.LazyVim.format.formatexpr()"
vim.opt.formatoptions = "jcroqlnt" -- tcqj
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.inccommand = "nosplit" -- preview incremental substitute
vim.opt.jumpoptions = "view"
vim.opt.list = true -- Show some invisible characters (tabs...
vim.opt.mouse = "a" -- Enable mouse mode
vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.scrolloff = 10 -- Lines of context
vim.opt.sessionoptions = { "curdir", "buffers", "tabpages", "winsize", "resize", "help", "globals", "skiprtp" }
vim.opt.undofile = true
vim.opt.equalalways = false
vim.opt.shiftround = true -- Round indent
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showmode = false
vim.opt.ignorecase = true -- Ignore case
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.spelllang = {}
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitkeep = "screen"
vim.opt.splitright = true -- Put new windows right of current
vim.opt.statuscolumn = [[%!v:lua.LazyVim.statuscolumn()]]
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.termguicolors = true -- True color support
vim.opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.winminwidth = 5 -- Minimum window width
vim.opt.wrap = false -- Disable line wrap
vim.opt.linebreak = true -- IF wrap is on, break at word boundaries (doesn't enable wrap)
vim.opt.cursorline = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undolevels = 10000
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.guicursor = "n:block25,c:ver25,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait175-blinkoff150-blinkon175"
vim.opt.whichwrap:append("<>[]hl")
vim.o.autowriteall = true
vim.lsp.inline_completion.enable(true)
vim.o.statusline = "%#WinSeparator#%{%repeat('─', winwidth(0))%}%*"
vim.o.laststatus = 0
vim.o.showtabline = 0
vim.filetype.add({
  pattern = {
    ["vimiumc.*%.conf"] = "toml",
  },
  filename = {
    ["/etc/keyd/default.conf"] = "toml",
  },
})
vim.o.winborder = "rounded"
vim.opt.concealcursor = "n"
vim.opt.conceallevel = 1 -- Hide * markup for bold and italic, but not markers with substitutions
