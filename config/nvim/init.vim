"
" Base Configuration
"

set cmdheight=1
set hidden
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=yes
set updatetime=300

" Undo file
set undofile
set undodir=$HOME/.vim/undo

set colorcolumn=120
hi ColorColumn ctermbg=4
xnoremap p pgvy

filetype plugin indent on
syntax on

"
" Mouse Configuraturation
"

set mouse=a

"
" Fold Configuration
"

set foldmethod=syntax
set foldnestmax=10
set nofoldenable

"
" Terminal Configuration
"

set shell=zsh

"
" Load Plugins
"

call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-rooter'
Plug 'camspiers/lens.vim'
Plug 'chriskempson/base16-vim'
Plug 'embear/vim-localvimrc'
Plug 'ggandor/lightspeed.nvim'
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'pbrisbin/vim-mkdir'
Plug 'rbong/vim-flog'
Plug 'Shirk/vim-gas'
Plug 'sirtaj/vim-openscad'
Plug 'skywind3000/asyncrun.vim'
Plug 'tomtom/tinykeymap_vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'vhdirk/vim-cmake'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/SmartCase'
Plug 'vim-scripts/errormarker.vim'
Plug 'vim-scripts/zoom.vim'

" Order is important
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sleuth'
Plug 'sgur/vim-editorconfig'

call plug#end()

"
" Colour Scheme
"

if (empty($TMUX))
  if (has("termguicolors"))
    set termguicolors
  endif
endif

colorscheme base16-default-dark

call g:Base16hi("Normal", g:base16_gui05, "000000", g:base16_cterm05, g:base16_cterm00, "", "")
call g:Base16hi("LineNr", g:base16_gui03, "000000", g:base16_cterm03, g:base16_cterm00, "", "")

let g:terminal_color_0  = '#2e3436'
let g:terminal_color_1  = '#cc0000'
let g:terminal_color_2  = '#4e9a06'
let g:terminal_color_3  = '#c4a000'
let g:terminal_color_4  = '#3465a4'
let g:terminal_color_5  = '#75507b'
let g:terminal_color_6  = '#0b939b'
let g:terminal_color_7  = '#d3d7cf'
let g:terminal_color_8  = '#555753'
let g:terminal_color_9  = '#ef2929'
let g:terminal_color_10 = '#8ae234'
let g:terminal_color_11 = '#fce94f'
let g:terminal_color_12 = '#729fcf'
let g:terminal_color_13 = '#ad7fa8'
let g:terminal_color_14 = '#00f5e9'
let g:terminal_color_15 = '#eeeeec'

"
" Additional Synax Highlighting
"

au BufRead,BufNewFile *.[sS] set filetype=gas

"
" AirLine
"

let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_section_error = airline#section#create_right(['%{g:asyncrun_status}'])


"
" Key Binding
"

" Disable XON/XOFF
noremap <C-q> <Nop>
noremap <C-s> <Nop>

" Hide search highlight
noremap z/ :nohlsearch<CR>

" Close the buffer without closing the split
nmap <leader>bd :bp\|bd #<CR>

" quick-fix list
nmap <leader>qo :copen<CR>
nmap <leader>qc :cclose<CR>

tnoremap <C-Space> <C-\><C-n>

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

set number relativenumber

" Hide line numbers in terminal buffers
au TermOpen * setlocal nonumber norelativenumber

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

let g:tinykeymap#mapleader = '<leader>'
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
" AsyncRun
"

let g:asyncrun_auto = "make"
let g:asyncrun_open = 10
let g:asyncrun_rootmarks = ['build', '_build', '.git']
let g:asyncrun_status = ''

nmap <leader>mm :AsyncRun -cwd=<root> -program=make<CR>
nmap <leader>mc :AsyncStop<CR>

"
" vim-fugitive
"

nmap <leader>ga :Gwrite<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gs :Git<CR>
nmap <leader>gv :Flogsplit<CR>
nmap <leader>gV :Flogsplit -all<CR>

"
" lens.vim
"

let g:lens#width_resize_min = 20
let g:lens#width_resize_max = 128

"
" Focus
"

function! s:Focus()
  " Close the quickfix list
  :cclose

  " Close all the vim fugitive windows
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && getbufvar(v:val, "fugitive_type") != ""')
    silent execute 'bwipeout' buf
  endfor
endfunction

command! Focus call s:Focus()

nmap <leader>F :Focus<CR>

"
" vim-cmake
"

let g:cmake_export_compile_commands = 1
let g:cmake_ycm_symlinks = 1

"
" neovim-remote
"

if has('nvim')
  let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

"
" lighspeed.nvim
"

" Bind lighspeed s/S to q/Q, and remap 'record macro' to Ctrl-Q
nnoremap <C-q> q

nmap q <Plug>Lightspeed_s
nmap Q <Plug>Lightspeed_S
nmap f <Plug>Lightspeed_f
nmap F <Plug>Lightspeed_F
nmap t <Plug>Lightspeed_t
nmap T <Plug>Lightspeed_T

nmap ; <Plug>Lightspeed_;_ft
vmap ; <Plug>Lightspeed_;_ft
nmap , <Plug>Lightspeed_,_ft
vmap , <Plug>Lightspeed_,_ft
