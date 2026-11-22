-- No cpp: compiling its queries costs ~170 ms per session, so C++ uses
-- vim-cpp-modern's regex syntax instead.
require('nvim-treesitter').install({ 'c', 'python', 'bash' })

-- Larger files are left to Neovim's background parsing, to avoid freezing.
local max_parse_bytes = 256 * 1024

local function highlight(buf, lang)
    -- Lua and Markdown ftplugins already start it; a second start breaks spell.
    local active = vim.treesitter.highlighter.active[buf]
    if not (active and active.tree:lang() == lang) then
        vim.treesitter.stop(buf)
        vim.treesitter.start(buf, lang)
    end
    -- Parse up front so the first paint has colors; skip buffers never shown.
    local size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
    if size <= max_parse_bytes and vim.fn.win_gettype() ~= 'autocmd' then
        vim.treesitter.get_parser(buf, lang):parse(true)
    end
end

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('eraffo_treesitter', { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        local ok = pcall(function()
            if lang and lang ~= 'cpp' and vim.treesitter.language.add(lang) then
                highlight(args.buf, lang)
            else
                vim.treesitter.stop(args.buf)
            end
        end)
        -- Warn rather than error, so callers like `gd` aren't interrupted.
        if not ok then
            pcall(vim.treesitter.stop, args.buf)
            vim.notify_once(('Treesitter failed for %s, using regex. Try :TSUpdate.'):format(lang), vim.log.levels.WARN)
        end
    end,
})
