"
" Base Configuration
"

set hidden
set undofile
set undodir=$HOME/.vim/undo

set colorcolumn=120
hi ColorColumn ctermbg=4
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

Plug 'airblade/vim-rooter'
Plug 'embear/vim-localvimrc'
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'rbong/vim-flog'
Plug 'sirtaj/vim-openscad'
Plug 'tomtom/tinykeymap_vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/SmartCase'
Plug 'https://git.danielmoch.com/vim-makejob.git'

call plug#end()

"
" Colour Scheme
"

colorscheme default
highlight LineNr ctermfg=darkgrey

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

" Hide line numbers in terminal buffers
au BufWinEnter * if &buftype == 'terminal' | setlocal nonumber norelativenumber | endif

"
" netrw file browser
"

let g:netrw_liststyle = 3

"
" localvimrc
"

let g:localvimrc_persistent=1
let g:localvimrc_sandbox=0

"
" tinykeymap bindings
"

let g:tinykeymap#timeout = 1000

call tinykeymap#Load(['buffers'])
call tinykeymap#Load(['qfl'])
call tinykeymap#Load(['tabs'])

let g:tinykeymap#map#windows#map = '<C-w>'
call tinykeymap#Load(['windows'])

"
" fzf
"

nmap <leader>ff :Files<CR>
nmap <leader>fg :GFiles<CR>
nmap <leader>fs :GFiles?<CR>
nmap <leader>fb :Buffers<CR>
nmap <leader>fl :BLines<CR>
nmap <leader>fL :Lines<CR>
nmap <leader>fa :Ag<CR>

"
" Make
"

nmap <leader>mm :MakeJob<CR>
nmap <leader>mc :MakeJobStop<CR>

"
" vim-fugitive
"

nmap <leader>ga :Gwrite<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gv :Flogsplit<CR>
nmap <leader>gV :Flogsplit -all<CR>
