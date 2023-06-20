local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate"
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = '0.1.1',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
	keys = {
	    {"<leader>e", "<cmd>NvimTreeFocus<cr>", desc = "Focus NvimTree"},
	    {"<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree"},
	},
    },
    {
	"neovim/nvim-lspconfig",
	version = "*",
    },
    {
	"nvim-lualine/lualine.nvim",
	version = "*",
	dependencies = {
	    "nvim-tree/nvim-web-devicons",
        }
    },
    {
	"folke/tokyonight.nvim",
	version = "*",
	lazy = false,
	priority = 1000,
    },
    {
	"nvim-treesitter/nvim-treesitter",
	version = "*",
	build = ":TSUpdate",
    },
    {
	"windwp/nvim-autopairs",
	version = "*",
    },
}

local opts = {}

vim.g.mapleader = " "

require("lazy").setup(plugins, opts)
require("mason").setup()
require("nvim-tree").setup()
require("lualine").setup({
    options = {
        theme = 'tokyonight'
    }
})
require("tokyonight").setup({
    style = "storm",
    light_style = "day",
    terminal_colors = true
})
require("nvim-treesitter.configs").setup({
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
    highlight = {
	enable = true,
    },
    indent = {
	enable = true,
    },
})
require("nvim-autopairs").setup()

vim.cmd([[colorscheme tokyonight]])
vim.cmd([[set number]])

-- Telescope Keymapping
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', function() builtin.find_files() end)
vim.keymap.set('n', '<leader>fw', function() builtin.live_grep() end)
vim.keymap.set('n', '<leader>fb', function() builtin.buffers() end)
vim.keymap.set('n', '<leader>fh', function() builtin.help_tags() end)

-- Buffer Keymapping
vim.keymap.set('n', '<leader>x', "<cmd>bdelete<cr>")
vim.keymap.set('n', '<TAB>', "<cmd>bnext<cr>")

-- Navigation Keymapping
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')

-- General Keymapping
vim.keymap.set('i', 'jj', '<ESC>')
vim.keymap.set('n', ';', ':')
