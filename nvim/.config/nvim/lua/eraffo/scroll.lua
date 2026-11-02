-- Smooth scrolling (neoscroll.nvim): animates <C-u>/<C-d>, <C-b>/<C-f>,
-- <C-y>/<C-e> and zt/zz/zb as quick line-by-line glides instead of jumps.
--
-- Set up after the first screen is drawn so it doesn't add to startup time.
vim.schedule(function()
    require('neoscroll').setup({
        easing = 'quadratic', -- ease in/out instead of constant speed
    })
end)
