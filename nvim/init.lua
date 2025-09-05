-- ==================== NEOVIM INIT.LUA ====================
-- This configuration is based on your existing .vimrc but modernized for Neovim
-- It maintains all your current keybindings and settings while adding Neovim enhancements

-- ==================== COMPATIBILITY LAYER ====================
-- Source your existing vimrc to maintain compatibility
local vimrc_path = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc_path) == 1 then
    vim.cmd("source " .. vimrc_path)
end

-- ==================== NEOVIM-SPECIFIC ENHANCEMENTS ====================

-- Enable modern Neovim features
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors

-- Better default settings for Neovim
vim.opt.signcolumn = "yes"    -- Always show sign column to avoid text shifting
vim.opt.updatetime = 250      -- Faster completion and diagnostics
vim.opt.timeoutlen = 300      -- Faster which-key popup

-- Modern clipboard handling (better than vim's clipboard=unnamed)
if vim.fn.has('macunix') == 1 then
    vim.opt.clipboard = "unnamedplus"
end

-- ==================== LSP AND MODERN FEATURES ====================
-- Only add if not conflicting with existing plugins

-- Function to safely load modern Neovim features
local function safe_setup()
    -- Check if we have modern completion already from vim plugins
    local has_completion = vim.fn.exists(':SuperTabDefaultCompletionType') == 2
    
    if not has_completion then
        -- Basic built-in LSP setup (lightweight)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show hover' })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
    end
end

-- Apply safe setup
safe_setup()

-- ==================== MAINTAIN VIM COMPATIBILITY ====================
-- Ensure all your existing vim commands and mappings still work
vim.cmd([[
  " Maintain compatibility with existing vimrc mappings
  " All your existing keybindings should continue to work
  
  " Enhanced search highlighting for Neovim
  set hlsearch
  set incsearch
  
  " Better split opening
  set splitright
  set splitbelow
  
  " Maintain your existing colorscheme logic but enhance for Neovim
  if has('termguicolors')
    set termguicolors
  endif
]])

-- ==================== OPTIONAL MODERN ENHANCEMENTS ====================
-- These are commented out - uncomment gradually to try new features

--[[ 
-- Modern file explorer (if you want to try something new alongside NERDTree)
vim.keymap.set('n', '<leader>e', ':Explore<CR>', { desc = 'File explorer' })

-- Better terminal integration
vim.keymap.set('n', '<leader>t', ':terminal<CR>', { desc = 'Open terminal' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Modern search and replace (keep your existing fzf setup)
vim.keymap.set('n', '<leader>/', ':nohlsearch<CR>', { desc = 'Clear search' })
--]]

-- ==================== LAZY PLUGIN MANAGEMENT (OPTIONAL) ====================
-- Uncomment the next line when you're ready to try modern plugin management
-- require('lazy-setup').setup_lazy_nvim()

-- ==================== HELPFUL COMMANDS ====================
-- :EnableModernNvim - Enable modern plugins when you're ready to experiment