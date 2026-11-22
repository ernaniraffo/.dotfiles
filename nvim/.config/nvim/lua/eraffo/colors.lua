-- Gruvbox follows 'background', which Neovim reads from Ghostty. Don't set it.
-- Hard contrast in dark mode matches Ghostty's Gruvbox Dark Hard.
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
