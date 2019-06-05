"
" Base Configuration
"

set hidden
set undofile
set undodir=$HOME/.vim/undo

set colorcolumn=120
hi ColorColumn ctermbg=4
let g:localvimrc_ask=0
xnoremap p pgvy

filetype plugin indent on
syntax on

"
" GUI Configuration
"

if has("gui_running")
  set guifont=Source\ Code\ Pro\ for\ Powerline\ Medium\ 10
  set guioptions -=T
endif

"
" Terminal Configuration
"

set shell=zsh

"
" Load Plugins
"

call plug#begin('~/.vim/plugged')

Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'embear/vim-localvimrc'
Plug 'jlanzarotta/bufexplorer'
Plug 'sirtaj/vim-openscad'
Plug 'tomtom/tinykeymap_vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/SmartCase'

call plug#end()

"
" Colour Scheme
"

colorscheme default
highlight LineNr ctermfg=darkgrey

"
" CtrlP
"

" Setup some default ignores
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
  \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg)$',
\}

" Use the nearest .git directory as the cwd
let g:ctrlp_working_path_mode = 'r'

" Use a leader instead of the actual named binding
nmap <leader>p :CtrlP<cr>

" Add tmux-style binding for creating splits
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("v")': ['<c-v>', '<Bar>', '<RightMouse>'],
  \ }

"
" AirLine
"

let g:airline_powerline_fonts = 1
let g:airline_theme = 'murmur'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'


"
" Key Binding
"

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" Close the buffer without closing the split
nmap <leader>bd :bp\|bd #<CR>

"
" Code folding
"

set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2

"
" Line numbering
"

set number

"
" netrw file browser
"

let g:netrw_liststyle = 3

"
" tinykeymap bindings
"

let g:tinykeymap#timeout = 1000

call tinykeymap#Load(['buffers'])
call tinykeymap#Load(['tabs'])

let g:tinykeymap#map#windows#map = '<C-w>'
call tinykeymap#Load(['windows'])
