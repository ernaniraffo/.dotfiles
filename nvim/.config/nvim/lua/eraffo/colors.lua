-- Kanagawa follows 'background', which Neovim updates from the terminal's
-- background colour when Ghostty switches theme with the system appearance.
-- Don't set 'background' in the config: that stops Neovim following it.
-- The Ghostty side is the theme line in ~/.config/ghostty/config.ghostty.
require('kanagawa').setup({
    -- No italics (its defaults italicize comments, keywords and builtin
    -- variables like `self`).
    commentStyle = { italic = false },
    keywordStyle = { italic = false },
    overrides = function()
        return { ['@variable.builtin'] = { italic = false } }
    end,
    background = { dark = 'dragon', light = 'lotus' },
})

vim.cmd.colorscheme('kanagawa')
