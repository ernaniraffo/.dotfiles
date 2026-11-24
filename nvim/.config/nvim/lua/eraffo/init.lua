vim.o.winborder = 'rounded'
vim.filetype.add({ extension = { metal = 'metal' } })

require('eraffo.colors')
require('eraffo.lsp')
require('eraffo.treesitter')

require('nvim-autopairs').setup({})

require('telescope').setup({})
require('telescope').load_extension('fzf')

-- After the first redraw, to keep it out of startup time.
vim.schedule(function()
    require('neoscroll').setup({ easing = 'quadratic' })
end)
