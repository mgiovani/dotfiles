-- ==================== SUPER LAZY NEOVIM PLUGIN SETUP ====================
-- This file handles plugin compatibility between Vim and Neovim
-- Only load if you want to try modern plugin management alongside vim-plug

local M = {}

-- Check if vim-plug is working (from your existing .vimrc)
function M.has_vim_plug()
    return vim.fn.exists(':PlugInstall') == 2
end

-- Lazy loader for modern Neovim plugins (optional)
function M.setup_lazy_nvim()
    -- Only proceed if user wants modern plugins
    if not vim.g.enable_modern_plugins then
        return
    end
    
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)

    -- Modern plugins that complement (don't replace) your vim setup
    require("lazy").setup({
        -- Modern LSP support (optional - your ALE still works)
        {
            "neovim/nvim-lspconfig",
            event = { "BufReadPre", "BufNewFile" },
            config = function()
                -- Only setup if ALE isn't handling it
                if not vim.g.ale_enabled then
                    -- Basic Python LSP setup
                    require('lspconfig').pyright.setup{}
                    require('lspconfig').ruff_lsp.setup{}
                end
            end,
        },
        
        -- Modern completion (only if SuperTab gets annoying)
        {
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            enabled = false, -- Disabled by default to not conflict with SuperTab
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
            },
        },
        
        -- Better syntax highlighting (TreeSitter)
        {
            "nvim-treesitter/nvim-treesitter",
            event = { "BufReadPre", "BufNewFile" },
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "python", "javascript", "typescript", "lua", "go" },
                    highlight = { enable = true },
                    incremental_selection = { enable = true },
                })
            end,
        },
    })
end

-- Function to gradually enable modern features
function M.enable_modern_mode()
    vim.g.enable_modern_plugins = true
    print("Modern Neovim plugins enabled! Restart to take effect.")
end

-- Add command to enable modern features when ready
vim.api.nvim_create_user_command('EnableModernNvim', M.enable_modern_mode, {})

return M