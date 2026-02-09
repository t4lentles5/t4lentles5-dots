local keymap = vim.keymap

-- General Keymaps
keymap.set("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear search highlights" })

-- Window Navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize Windows
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer Navigation
keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
keymap.set("n", "<leader>x", "<cmd>Bdelete<cr>", { desc = "Close current buffer" })

-- Save File
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Plugins
keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Toggle LazyGit" })

-- Better Indenting
keymap.set("v", "<", "<vgv", { desc = "Indent out" })
keymap.set("v", ">", ">gv", { desc = "Indent in" })

-- Move Lines
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Search Centering
keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Paste without losing registry

keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over selection" })

-- LSP Keymaps (only when LSP is attached)

vim.api.nvim_create_autocmd("LspAttach", {

	group = vim.api.nvim_create_augroup("UserLspConfig", {}),

	callback = function(ev)
		local opts = { buffer = ev.buf }

		keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = ev.buf })

		keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references", buffer = ev.buf })

		keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation", buffer = ev.buf })

		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = ev.buf })

		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", buffer = ev.buf })
	end,
})
