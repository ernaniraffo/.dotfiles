-- Colorscheme, kept in sync with Ghostty by ghostty-theme-sync.nvim.
--
-- :GhosttyTheme lists the themes that exist in both Neovim (installed
-- colorschemes) and Ghostty, sets the picked one in Neovim, writes it to the
-- Ghostty config, and rewrites the colorscheme line below so it persists.
-- Reload Ghostty's config afterwards (cmd+shift+,) to apply it there.
require('ghostty-theme-sync').setup({
    ghostty_config_path = '~/.config/ghostty/config.ghostty', -- tracked in dotfiles
    persist_nvim_theme = true,
    nvim_config_path = vim.fn.stdpath('config') .. '/lua/eraffo/colors.lua',
})

-- Kanagawa without italics (its defaults italicize comments, keywords and
-- builtin variables like `self`).
require('kanagawa').setup({
    commentStyle = { italic = false },
    keywordStyle = { italic = false },
    overrides = function()
        return { ['@variable.builtin'] = { italic = false } }
    end,
})

vim.cmd.colorscheme('kanagawa-dragon')
