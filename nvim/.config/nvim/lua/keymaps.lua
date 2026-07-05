-- keymaps.lua — emacs-style nav when in normal mode is off by default;
-- vim keybindings live here, only inside nvim. The shell uses emacs.

local keymap = vim.keymap

-- Better escape — jj in insert mode exits
keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Window navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })

-- Resize windows
keymap.set("n", "<C-Up>",    "<cmd>resize +2<CR>", { desc = "Resize up" })
keymap.set("n", "<C-Down>",  "<cmd>resize -2<CR>", { desc = "Resize down" })
keymap.set("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Resize left" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize right" })

-- Move text up/down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- Clear search highlights with <Esc>
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostics
keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

-- Better paste (no auto-indent weirdness)
keymap.set("v", "p", "p", { desc = "Paste (smart)" })
keymap.set("n", "p", "p", { desc = "Paste (smart)" })

-- Quick command palette
keymap.set("n", "<leader><leader>", function()
  vim.cmd("Lazy")
end, { desc = "Lazy plugin manager" })
