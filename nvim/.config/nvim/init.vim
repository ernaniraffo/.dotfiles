" number of spaces in a <Tab>
set tabstop=4
set softtabstop=4
set expandtab

" enable autoindents
set smartindent

" number of spaces used for autoindents
set shiftwidth=4

" adds line numbers
set number

" columns used for the line number
set numberwidth=4

" highlights the matched text pattern when searching
set incsearch
set nohlsearch

set noshowmode

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

set signcolumn=number

call plug#begin('~/.config/nvim/plugged')

" color scheme
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/sonokai'
Plug 'projekt0n/github-nvim-theme', { 'tag': 'v0.0.7' }

" Telescope requires plenary to function
Plug 'nvim-lua/plenary.nvim'
" The main Telescope plugin
Plug 'nvim-telescope/telescope.nvim'
" An optional plugin recommended by Telescope docs
Plug 'nvim-telescope/telescope-fzf-native.nvim', {'do': 'make' }

Plug 'itchyny/lightline.vim'
Plug 'nvim-lualine/lualine.nvim'

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

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

call plug#end()

lua require('eraffo')

if has('termguicolors')
    set termguicolors
endif

let g:sonokai_disable_italic_comment = 1
let g:sonokai_transparent_background = 2
let g:sonokai_better_performance = 1

syntax on
colorscheme sonokai

set background=dark
