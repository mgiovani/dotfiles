# Neovim Configuration - Lazy Migration from Vim

This Neovim setup is designed to be **extremely lazy-friendly** - it reuses your existing Vim configuration while gradually adding modern Neovim features.

## How It Works

1. **Compatibility First**: `init.lua` sources your existing `.vimrc`
2. **Zero Breaking Changes**: All your current keybindings and plugins work exactly the same
3. **Gradual Enhancement**: Modern features are added on top, not replacing existing ones

## Quick Start

```bash
# Install (via dotfiles install script)
./scripts/install.sh

# Or manually symlink
ln -sf ~/.config/nvim/init.lua ~/projects/dotfiles/nvim/init.lua

# Start using
nvim
```

## What You Get Immediately

✅ **All your existing Vim setup** - exactly as it was  
✅ **Modern colorscheme support** - 24-bit colors  
✅ **Same keybindings** - `<leader>o` for NERDTree, `<c-p>` for Files, etc.  
✅ **Same plugins** - vim-plug, all your current plugins work  
✅ **Enhanced terminal** - better integration  

## Optional Modern Features (Uncomment to Try)

The config includes commented sections you can gradually enable:

- Built-in LSP (Language Server Protocol)
- Modern file explorer 
- Better terminal integration
- Enhanced search/replace

## Migration Strategy (Super Lazy Approach)

1. **Day 1**: Just use Neovim with existing config (zero changes needed)
2. **Week 1**: Uncomment one modern feature to try
3. **Month 1**: Consider replacing one old plugin with modern alternative
4. **Eventually**: Full modern Neovim setup (optional)

## Your Existing Mappings That Still Work

- `<leader>o` - NERDTree toggle
- `<c-p>` - FZF files
- `<leader>f` - Ruff format
- `<leader>c` - ALEFix ruff
- `F1` - Clear search highlight
- All your custom mappings from .vimrc

## Troubleshooting

If something doesn't work:
1. Check if the issue exists in regular Vim too
2. The config sources your `.vimrc` - any Vim issue will appear in Neovim
3. Comment out the Neovim-specific enhancements in `init.lua`

## Why This Approach?

- **No learning curve**: Use exactly what you know
- **Risk-free**: Can always fall back to Vim
- **Gradual adoption**: Try new features when you want
- **No plugin migration**: All your vim-plug plugins work