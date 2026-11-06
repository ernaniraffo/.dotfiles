-- LSP (Neovim 0.11+ native config: vim.lsp.config / vim.lsp.enable)

-- Advertise nvim-cmp's completion capabilities to every server.
-- cmp_nvim_lsp.default_capabilities() doesn't load nvim-cmp itself.
vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.lsp.enable({ 'clangd', 'pyright', 'perlnavigator' })

-- Keep colors stable: semantic tokens arrive once the server is ready and
-- recolor the file up to a second after it opens.
vim.lsp.semantic_tokens.enable(false)

-- Buffer-local keymaps whenever a server attaches.
-- (on_attach is ignored by vim.lsp.enable, so these use LspAttach instead.)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('eraffo_lsp', { clear = true }),
    callback = function(args)
        local function map(lhs, rhs)
            vim.keymap.set('n', lhs, rhs, { buffer = args.buf, silent = true })
        end
        local border = { border = 'rounded' }

        map('gD', vim.lsp.buf.declaration)
        map('gd', vim.lsp.buf.definition)
        map('K', function() vim.lsp.buf.hover(border) end)
        map('gi', vim.lsp.buf.implementation)
        map('<C-k>', function() vim.lsp.buf.signature_help(border) end)
        map('<space>wa', vim.lsp.buf.add_workspace_folder)
        map('<space>wr', vim.lsp.buf.remove_workspace_folder)
        map('<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
        map('<space>D', vim.lsp.buf.type_definition)
        map('<space>rn', vim.lsp.buf.rename)
        map('<space>ca', vim.lsp.buf.code_action)
        map('gr', vim.lsp.buf.references)
        map('<space>e', function() vim.diagnostic.open_float(border) end)
        map('[d', function() vim.diagnostic.jump({ count = -1, float = border }) end)
        map(']d', function() vim.diagnostic.jump({ count = 1, float = border }) end)
        map('<space>q', vim.diagnostic.setloclist)
        map('<space>f', function() vim.lsp.buf.format({ async = true }) end)
    end,
})

-- Diagnostics: inline messages (off by default since 0.11), errors first,
-- and bordered floats.
vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = '●' },
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
})

-- better autocompletion experience
vim.o.completeopt = 'menuone,noselect'

-- nvim-cmp + LuaSnip are only needed once you start typing, so set them up
-- on the first InsertEnter instead of at startup.
vim.api.nvim_create_autocmd('InsertEnter', {
    once = true,
    callback = function()
        local cmp = require('cmp')
        local lspkind = require('lspkind')
        local luasnip = require('luasnip')

        cmp.setup {
            -- Format the autocomplete menu
            formatting = {
                format = lspkind.cmp_format({
                    mode = 'symbol_text',
                    maxwidth = 50,
                    symbol_map = {
                        Text = "τ",
                        Method = "ﬁ",
                        Function = "ƒ",
                        Constructor = "⌂",
                        Field = "Ψ",
                        Variable = "α",
                        Class = "♠",
                        Interface = "",
                        Module = "□",
                        Property = "∩",
                        Unit = "∆",
                        Value = "∞",
                        Enum = "±",
                        Keyword = "$",
                        Snippet = "φ",
                        Color = "∂",
                        File = "∑",
                        Reference = "∏",
                        Folder = "§",
                        EnumMember = "{",
                        Constant = "",
                        Struct = "»",
                        Event = "◊",
                        Operator = "ℓ",
                        TypeParameter = "☼"
                    },
                })
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = {
                -- Use Tab and shift-Tab to navigate autocomplete menu
                ['<Tab>'] = function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end,
                ['<S-Tab>'] = function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end,
                ['<CR>'] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                },
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            },
        }
    end,
})
