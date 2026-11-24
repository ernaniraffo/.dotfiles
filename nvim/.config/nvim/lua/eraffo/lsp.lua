vim.lsp.config('*', { capabilities = require('cmp_nvim_lsp').default_capabilities() })
-- Not in nvim-lspconfig; settings from the tree-sitter-metal README.
vim.lsp.config('metal_analyzer', {
    cmd = { 'metal-analyzer' },
    filetypes = { 'metal' },
    root_markers = { 'metalfmt.toml', '.clang-format', 'Package.swift', '.git' },
})
vim.lsp.enable({ 'clangd', 'pyright', 'perlnavigator', 'metal_analyzer' })

-- Semantic tokens recolor files up to a second after opening.
vim.lsp.semantic_tokens.enable(false)

vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = '●' },
    severity_sort = true,
    float = { source = 'if_many' },
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('eraffo_lsp', { clear = true }),
    callback = function(args)
        local function map(lhs, rhs)
            vim.keymap.set('n', lhs, rhs, { buffer = args.buf, silent = true })
        end
        map('gD', vim.lsp.buf.declaration)
        map('gd', vim.lsp.buf.definition)
        map('gi', vim.lsp.buf.implementation)
        map('K', vim.lsp.buf.hover)
        map('<C-k>', vim.lsp.buf.signature_help)
        map('<space>D', vim.lsp.buf.type_definition)
        map('<space>rn', vim.lsp.buf.rename)
        map('<space>ca', vim.lsp.buf.code_action)
        map('<space>e', vim.diagnostic.open_float)
        map('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
        map(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
        map('<space>q', vim.diagnostic.setloclist)
        map('<space>f', function() vim.lsp.buf.format({ async = true }) end)
    end,
})

-- Completion is set up on first InsertEnter, to keep it out of startup time.
vim.api.nvim_create_autocmd('InsertEnter', {
    once = true,
    callback = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        cmp.setup({
            formatting = { format = require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 }) },
            snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
            sources = { { name = 'nvim_lsp' }, { name = 'luasnip' } },
            mapping = {
                ['<Tab>'] = function(fallback)
                    if cmp.visible() then cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                    else fallback() end
                end,
                ['<S-Tab>'] = function(fallback)
                    if cmp.visible() then cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                    else fallback() end
                end,
                ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
            },
        })
    end,
})
