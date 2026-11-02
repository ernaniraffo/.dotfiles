-- nvim-treesitter (main branch): the plugin only installs parsers and
-- queries; highlighting is Neovim's own vim.treesitter, started per buffer.

local parsers = { 'c', 'cpp', 'python', 'bash' }

-- No-op for parsers that are already installed; runs asynchronously.
require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('eraffo_treesitter', { clear = true }),
    callback = function(args)
        -- Compiling a language's highlight query is slow the first time in
        -- a session (~150 ms for C++), and doing it here would block the
        -- first screen. Defer it so the file shows immediately with regex
        -- syntax, then Treesitter takes over a moment later.
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(args.buf) then return end
            -- pcall: filetypes without an installed parser keep regex syntax.
            pcall(vim.treesitter.start, args.buf)
        end)
    end,
})
