-- nvim-treesitter (main branch): the plugin only installs parsers and
-- queries; highlighting is Neovim's own vim.treesitter, started per buffer.

-- No cpp, on purpose: its grammar is huge, so compiling its queries takes
-- ~180 ms every session, by far the biggest cost of opening a file. C++ uses
-- regex syntax instead. To go back, add 'cpp' here.
local parsers = { 'c', 'python', 'bash' }

-- No-op for parsers that are already installed; runs asynchronously.
require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('eraffo_treesitter', { clear = true }),
    callback = function(args)
        -- Start before the first redraw so the file is never painted with
        -- regex colors first. The highlight query compiles once per language
        -- per session (~40 ms); deferring it wouldn't save that time, it would
        -- just freeze the editor right after a flash of wrong colors.
        -- pcall: filetypes without an installed parser keep regex syntax.
        pcall(vim.treesitter.start, args.buf)
    end,
})
