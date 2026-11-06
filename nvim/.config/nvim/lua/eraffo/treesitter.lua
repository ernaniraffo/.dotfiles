-- nvim-treesitter (main branch): the plugin only installs parsers and
-- queries; highlighting is Neovim's own vim.treesitter, started per buffer.

-- No cpp, on purpose: its grammar is huge, so compiling its queries takes
-- ~170 ms every session, by far the biggest cost of opening a file. C++ uses
-- regex syntax from vim-cpp-modern instead, even if a parser is on disk. To go
-- back, add 'cpp' here and remove the cpp check below.
local parsers = { 'c', 'python', 'bash' }

-- No-op for parsers that are already installed; runs asynchronously.
require('nvim-treesitter').install(parsers)

-- Bigger files keep Neovim's background parsing, since parsing them up front
-- would freeze the editor (~780 ms at 200,000 lines).
local max_lines_parsed_up_front = 50000

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('eraffo_treesitter', { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if args.match == 'cpp' or not lang or not vim.treesitter.language.add(lang) then
            -- Regex syntax. Stopping also drops the highlighter of a previous
            -- filetype, like after `:set ft=cpp` in a .c file.
            vim.treesitter.stop(args.buf)
            return
        end

        -- Start before the first redraw so the file is never painted with
        -- regex colors first. The highlight query compiles once per language
        -- per session (~40 ms); deferring it wouldn't save that time, it would
        -- just freeze the editor right after a flash of wrong colors.
        vim.treesitter.start(args.buf, lang)

        -- Parse now too. Neovim otherwise parses in the background, so the
        -- first paint of a long file has no colors at all.
        if vim.api.nvim_buf_line_count(args.buf) <= max_lines_parsed_up_front then
            vim.treesitter.get_parser(args.buf, lang):parse()
        end
    end,
})
