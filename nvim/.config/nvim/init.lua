-- nvim/init.lua — entry point
-- Bootstrap lazy.nvim on first launch, then load the rest.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load the rest
require("options")
require("keymaps")
require("plugins")
