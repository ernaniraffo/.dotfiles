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
-- can freeze the editor.
local max_bytes_parsed_up_front = 1024 * 1024

local function highlight(buf, lang)
    -- Start before the first redraw so the file is never painted with regex
    -- colors first. The highlight query compiles once per language per session
    -- (~40 ms); deferring it wouldn't save that time, it would just freeze the
    -- editor right after a flash of wrong colors.
    --
    -- Filetype plugins for some languages (Lua, Markdown) have already started
    -- it. A second highlighter would save the first one's 'spelloptions' as the
    -- original, which breaks spell checking if the filetype changes later.
    local active = vim.treesitter.highlighter.active[buf]
    if not (active and active.tree:lang() == lang) then
        vim.treesitter.stop(buf)
        vim.treesitter.start(buf, lang)
    end

    -- Parse now too, including code blocks in Markdown. Neovim otherwise parses
    -- in the background, so the first paint is missing colors.
    local size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
    if size <= max_bytes_parsed_up_front then
        vim.treesitter.get_parser(buf, lang):parse(true)
    end
end

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('eraffo_treesitter', { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        local ok, err = pcall(function()
            if lang and lang ~= 'cpp' and vim.treesitter.language.add(lang) then
                highlight(args.buf, lang)
            else
                -- Regex syntax. Stopping also drops the highlighter of a
                -- previous filetype, like after `:set ft=cpp` in a .c file.
                vim.treesitter.stop(args.buf)
            end
        end)
        -- A parser that won't load or a query broken by an update falls back to
        -- regex syntax. Report it, but don't let it reach whatever opened the
        -- file, because `gd` would then stop before moving the cursor. That
        -- rules out the ERROR level too, which raises through callers as well.
        if not ok then
            vim.treesitter.stop(args.buf)
            vim.notify(('Treesitter failed for %s: %s'):format(lang, tostring(err):match('[^\n]+')), vim.log.levels.WARN)
        end
    end,
})
