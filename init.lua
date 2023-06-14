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
        }
    }
}
local opts = {}

vim.g.mapleader = " "

require("lazy").setup(plugins, opts)
require("mason").setup()
require("nvim-tree").setup()

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', function() builtin.find_files() end)
vim.keymap.set('n', '<leader>fw', function() builtin.live_grep() end)
vim.keymap.set('n', '<leader>fb', function() builtin.buffers() end)
vim.keymap.set('n', '<leader>fh', function() builtin.help_tags() end)
