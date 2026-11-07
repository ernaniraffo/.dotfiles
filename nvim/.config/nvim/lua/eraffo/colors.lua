-- Gruvbox follows 'background', which Neovim updates from the terminal's
-- background colour when Ghostty switches theme with the system appearance.
-- Don't set 'background' in the config: that stops Neovim following it. So does
-- morhetz/gruvbox, which sets it when loaded, so don't use that port.
-- The Ghostty side is the theme line in ~/.config/ghostty/config.ghostty.
require('gruvbox').setup({
    -- Match the Ghostty themes, Gruvbox Dark Hard and Gruvbox Light. Contrast
    -- applies to both modes, so put the light background back to medium.
    contrast = 'hard',
    palette_overrides = { light0_hard = '#fbf1c7' },
    italic = { strings = false, emphasis = false, comments = false, operators = false, folds = false },
})

vim.cmd.colorscheme('gruvbox')
