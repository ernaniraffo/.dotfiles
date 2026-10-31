-- Make Neovim blend into the terminal.
--
-- The Terminal.app profile ("Ernani") uses a translucent, blurred dark
-- background (#212121 at 85% opacity) with green text. Neovim enables
-- termguicolors automatically, and the default colorscheme then paints an
-- opaque NvimDarkGrey background, so Neovim looked different from the shell.
-- Clearing the background (and Normal's foreground) on the main groups lets
-- the terminal's own background and text color show through.
-- Syntax highlighting still comes from the default colorscheme.

vim.o.background = 'dark'

local transparent = {
    'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder', 'FloatTitle',
    'SignColumn', 'LineNr', 'CursorLineNr', 'FoldColumn', 'EndOfBuffer',
    'MsgArea',
}

local function apply()
    for _, group in ipairs(transparent) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg, hl.ctermbg = nil, nil
        vim.api.nvim_set_hl(0, group, hl)
    end
    -- Use the terminal's own text color for regular text.
    vim.api.nvim_set_hl(0, 'Normal', {})
end

vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('eraffo_colors', { clear = true }),
    callback = apply,
})

apply()
