-- Modus follows 'background', which Neovim reads from Ghostty. Don't set it.
require('modus-themes').setup({ styles = { comments = { italic = false }, keywords = { italic = false } } })
vim.cmd.colorscheme('modus')
