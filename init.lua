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
vim.opt.pumheight = 20

-- Load the plugins
local plugins = {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate"
    },
    {
        "nvim-telescope/telescope.nvim",
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<leader>e", "<cmd>NvimTreeFocus<cr>",  desc = "Focus NvimTree" },
            { "<C-n>",     "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
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
    -- {
    --    "catppuccin/nvim",
    --    name = "catppuccin",
    --    lazy = false,
    --    priority = 1000,
    -- },
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000
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
    {
        "lewis6991/gitsigns.nvim",
        version = "*",
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        version = "*"
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        version = "*"
    },
    {
        "hrsh7th/cmp-buffer",
        version = "*"
    },
    {
        "hrsh7th/cmp-path",
        version = "*"
    },
    {
        "hrsh7th/cmp-cmdline",
        version = "*"
    },
    {
        "hrsh7th/nvim-cmp",
        version = "*"
    },
    {
        "L3MON4D3/LuaSnip",
        version = "*",
        dependencies = { "rafamadriz/friendly-snippets" },
	    build = "make install_jsregexp",
    },
    {
        "saadparwaiz1/cmp_luasnip",
        version = "*"
    },
    {
        "rafamadriz/friendly-snippets",
    },
    {
	"supermaven-inc/supermaven-nvim",
    }
}

local opts = {}

-- Set the keymap for the leader key

vim.g.mapleader = " "

-- Load the plugins

require("lazy").setup(plugins, opts)
require("mason").setup()
require("nvim-tree").setup()
require("lualine").setup({
    options = {
        theme = 'everforest'
    }
})
require("everforest").setup({
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
    },
    transparent_background_level = 1,
})
require("nvim-treesitter.configs").setup({
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
    highlight = {
        enable = true,
        use_languagetree = true,
    },
    indent = {
        enable = true,
    },
})
require("nvim-autopairs").setup()
require("gitsigns").setup()
require("supermaven-nvim").setup({})

local null_ls = require("null-ls")
local sources = {
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.completion.luasnip
}
null_ls.setup({ sources = sources })

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }
    }, {
        { name = 'buffer' }
    }),
    mapping = {
        ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    },
})
-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'buffer' }
    })
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        -- on_attach = my_custom_on_attach,
        capabilities = capabilities,
    }
end
require("luasnip.loaders.from_vscode").lazy_load()

vim.cmd([[colorscheme everforest]])
vim.cmd([[set number]])

vim.opt.completeopt = 'menuone,noselect'
vim.lsp.set_log_level('trace')

-- Telescope Keymapping
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', function() builtin.find_files() end)
vim.keymap.set('n', '<leader>fw', function() builtin.live_grep() end)
vim.keymap.set('n', '<leader>fb', function() builtin.buffers() end)
vim.keymap.set('n', '<leader>fh', function() builtin.help_tags() end)

-- Gitsigns Keymapping
vim.keymap.set('n', '<leader>pb', '<cmd>Gitsigns blame_line<cr>')
vim.keymap.set('n', ']c', '<cmd>Gitsigns next_hunk<cr>')
vim.keymap.set('n', '[c', '<cmd>Gitsigns prev_hunk<cr>')
vim.keymap.set('n', '<leader>ph', '<cmd>Gitsigns preview_hunk<cr>')

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

-- LSP Keymapping
vim.keymap.set('n', "K", function() vim.lsp.buf.hover() end)
vim.keymap.set('n', "gD", function() vim.lsp.buf.declaration() end)
vim.keymap.set('n', "gd", function() vim.lsp.buf.definition() end)
vim.keymap.set('n', "gi", function() vim.lsp.buf.implementation() end)
vim.keymap.set('n', "gr", function() vim.lsp.buf.references() end)
vim.keymap.set('n', "ca", function() vim.lsp.buf.code_action() end)

