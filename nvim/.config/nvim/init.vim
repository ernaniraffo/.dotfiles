" cache compiled Lua modules (faster startup)
lua vim.loader.enable()

" No plugin here uses Python, Ruby, Node or Perl. Without these, Neovim's
" Python and Ruby filetype plugins search for those languages each time such a
" file opens, which can take seconds on a slow or managed machine.
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0

" turn off cursor styling
set guicursor=

" number of spaces in a <Tab>
set tabstop=4
set softtabstop=4
set expandtab

" enable autoindents
set smartindent

" number of spaces used for autoindents
set shiftwidth=4

" line numbers: absolute on the cursor line, relative elsewhere
set number
set relativenumber

" columns used for the line number
set numberwidth=4

" highlights the matched text pattern when searching
set incsearch
set nohlsearch

" open splits intuitively
set splitbelow
set splitright

" navigate buffers without losing unsaved work
set hidden

" start scrolling when 8 lines from top or bottom
set scrolloff=8

" Save undo history
set undofile

" Enable mouse support
set mouse=a

" case insensitive search unless capital letters are used
set ignorecase
set smartcase

inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>

" Insert open/closing braces, then enter insert mode in-between.
inoremap {<cr> {<cr>}<esc>O

" Don't continue comments on <Enter> or o/O.
augroup eraffo_no_comment_continuation
    autocmd!
    autocmd FileType * setlocal formatoptions-=r formatoptions-=o
augroup END

" give signs (gitsigns, diagnostics) their own column left of the numbers
set signcolumn=yes

call plug#begin('~/.config/nvim/plugged')

" Telescope requires plenary to function
Plug 'nvim-lua/plenary.nvim'
" The main Telescope plugin
Plug 'nvim-telescope/telescope.nvim'
" An optional plugin recommended by Telescope docs
Plug 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make' }

" vim-fugitive
Plug 'tpope/vim-fugitive'

" gitsigns
Plug 'lewis6991/gitsigns.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'

" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'onsails/lspkind-nvim'

" Smooth scrolling animation for <C-d>/<C-u>/<C-f>/<C-b>/<C-e>/<C-y>/zt/zz/zb
Plug 'karb94/neoscroll.nvim'

Plug 'ellisonleao/gruvbox.nvim'

" Treesitter
" main branch: the maintained rewrite (master is frozen). Needs tree-sitter-cli.
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main', 'do': ':TSUpdate' }

" Regex highlighting for C++, which deliberately skips Treesitter (see lua/eraffo/treesitter.lua)
let g:cpp_member_highlight = 1
Plug 'bfrg/vim-cpp-modern'

call plug#end()

lua require('eraffo')
