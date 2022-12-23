-- Disable netrw 
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- Empty setup using defaults
require("nvim-tree").setup()

