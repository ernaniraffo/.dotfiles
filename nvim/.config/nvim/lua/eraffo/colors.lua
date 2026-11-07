-- Gruvbox follows 'background', which Neovim updates from the terminal's
-- background colour when Ghostty switches theme with the system appearance.
-- Don't set 'background' in the config: that stops Neovim following it.
-- The Ghostty side is the theme line in ~/.config/ghostty/config.ghostty.

-- The darkest version of each mode.
vim.g.gruvbox_contrast_dark = 'hard'
vim.g.gruvbox_contrast_light = 'soft'
vim.g.gruvbox_italic = 0

vim.cmd.colorscheme('gruvbox')
