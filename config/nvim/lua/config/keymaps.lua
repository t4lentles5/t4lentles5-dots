-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- vim.g.mapleader = " "
-- vim.g.maplocalleader = " "

vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Save current file
vim.keymap.set("n", "<leader>w", ":w<cr>", { desc = "Save file", remap = true })

-- ESC pressing jk
vim.keymap.set("i", "jk", "<ESC>", { desc = "jk to esc", noremap = true })

-- Quit Neovim
vim.keymap.set("n", "<leader>q", ":q<cr>", { desc = "Quit Neovim", remap = true })

-- Increment/decrement
vim.keymap.set("n", "+", "<C-a>", { desc = "Increment numbers", noremap = true })
vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement numbers", noremap = true })

-- Select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G", { desc = "Select all", noremap = true })
