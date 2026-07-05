-- options.lua — sensible defaults that don't require plugins

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.showmode = false
opt.termguicolors = true
opt.signcolumn = "yes:1"
opt.updatetime = 250
opt.timeoutlen = 400

-- Indent
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.showmatch = true
opt.matchtime = 2

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("cache") .. "/undo"
opt.confirm = true
opt.autoread = true
opt.shadafile = "NONE"

-- Catppuccin Mocha palette
vim.cmd.colorscheme("catppuccin-mocha")

-- Set transparency-friendly background
vim.o.background = "dark"

-- Clipboard
opt.clipboard = "unnamedplus"
