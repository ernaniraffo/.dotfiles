-- Gruvbox follows 'background', which Neovim updates from the terminal's
-- background colour when Ghostty switches theme with the system appearance.
-- Don't set 'background' in the config: that stops Neovim following it. So does
-- morhetz/gruvbox, which sets it when loaded, so don't use that port.
-- The Ghostty side is the theme line in ~/.config/ghostty/config.ghostty.

-- Match the Ghostty themes, Gruvbox Dark Hard and Gruvbox Light. The contrast
-- setting covers both modes, so choose it each time the colorscheme loads.
vim.api.nvim_create_autocmd('ColorSchemePre', {
    pattern = 'gruvbox',
    callback = function()
        require('gruvbox').setup({
            contrast = vim.o.background == 'dark' and 'hard' or '',
            italic = { strings = false, emphasis = false, comments = false, operators = false, folds = false },
        })
    end,
})

vim.cmd.colorscheme('gruvbox')
