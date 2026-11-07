-- Gruvbox follows 'background', which Neovim updates from the terminal's
-- background colour when Ghostty switches theme with the system appearance.
-- Don't set 'background' in the config: that stops Neovim following it.
-- The Ghostty side is the theme line in ~/.config/ghostty/config.ghostty.

-- Match the Ghostty themes, Gruvbox Dark Hard and Gruvbox Light. Ghostty has no
-- soft light theme, so Neovim's soft would be darker than the terminal around it.
vim.g.gruvbox_contrast_dark = 'hard'
vim.g.gruvbox_contrast_light = 'medium'
vim.g.gruvbox_italic = 0

vim.cmd.colorscheme('gruvbox')
