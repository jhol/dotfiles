"
" Base Configuration
"

set cmdheight=2
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
Plug 'camspiers/lens.vim'
Plug 'chriskempson/base16-vim'
Plug 'embear/vim-localvimrc'
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pbrisbin/vim-mkdir'
Plug 'rbong/vim-flog'
Plug 'sheerun/vim-polyglot'
Plug 'sirtaj/vim-openscad'
Plug 'skywind3000/asyncrun.vim'
Plug 'tomtom/tinykeymap_vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/SmartCase'
Plug 'vim-scripts/errormarker.vim'

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

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" Close the buffer without closing the split
nmap <leader>bd :bp\|bd #<CR>

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

set number

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
nmap <leader>gs :Gstatus<CR>
nmap <leader>gv :Flogsplit<CR>
nmap <leader>gV :Flogsplit -all<CR>

"
" coc
"

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <C-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nmap <silent> <leader>cp <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>cn <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> <leader>cd <Plug>(coc-definition)
nmap <silent> <leader>cy <Plug>(coc-type-definition)
nmap <silent> <leader>ci <Plug>(coc-implementation)
nmap <silent> <leader>cr <Plug>(coc-references)

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Configure language servers
call coc#config('languageserver', {
  \  'ccls': {
  \    "command": "ccls",
  \    "trace.server": "verbose",
  \    "filetypes": ["c", "cpp", "objc", "objcpp"],
  \    "rootPatterns": [".ccls-root", "compile_commands.json"],
  \    "initializationOptions": {
  \      "cache": {
  \        "directory": ".ccls-cache"
  \      }
  \    }
  \  }
  \})
