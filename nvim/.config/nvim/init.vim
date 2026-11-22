lua vim.loader.enable()

" No plugin needs these; skipping them avoids slow provider lookups.
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0

set guicursor=
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set number
set relativenumber
set signcolumn=yes
set nohlsearch
set ignorecase
set smartcase
set splitbelow
set splitright
set scrolloff=8
set undofile
set mouse=a

" Don't continue comments on <Enter> or o/O.
augroup eraffo | autocmd!
autocmd FileType * setlocal formatoptions-=r formatoptions-=o
augroup END

call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'onsails/lspkind-nvim'
Plug 'karb94/neoscroll.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main', 'do': ':TSUpdate' }
Plug 'bfrg/vim-cpp-modern'
Plug 'mg979/vim-visual-multi'
call plug#end()

let g:cpp_member_highlight = 1
" macOS Mission Control takes <C-Down>/<C-Up>.
let g:VM_maps = { 'Add Cursor Down': '\\j', 'Add Cursor Up': '\\k' }

lua require('eraffo')
