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

call plug#begin('~/.vim/plugged')

Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'embear/vim-localvimrc'
Plug 'kana/vim-submode'
Plug 'sirtaj/vim-openscad'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/SmartCase'

call plug#end()


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

" Close the current buffer and move to the previous one
nmap <leader>bq :bp <BAR> bd #<CR>

" Show all open buffers and their status
nmap <leader>bl :ls<CR>


"
" Disable Arrow Keys
"
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
noremap <Home> <NOP>
noremap <End> <NOP>

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
" Window Submode
"

" A message will appear in the message line when we're in a submode and stay there until the mode has existed.
let g:submode_always_show_submode = 1

" We're taking over the default <C-w> setting. We'll do our best to put back the default functionality.
call submode#enter_with('Window', 'n', '', '<C-w>')

" Note: <C-c> will also get you out to the mode without this mapping.
" Note: <C-[> also behaves as <ESC>
call submode#leave_with('Window', 'n', '', '<ESC>')

" Go through every letter mapping it to <C-w> when in the Windows submode
for key in ['a','b','c','d','e','f','g','h','i','j','k','l','m',
\           'n','o','p','q','r','s','t','u','v','w','x','y','z']
  " maps lowercase, uppercase and <C-key>
  call submode#map('Window', 'n', '', key, '<C-w>' . key)
  call submode#map('Window', 'n', '', toupper(key), '<C-w>' .  toupper(key))
  call submode#map('Window', 'n', '', '<C-' . key . '>', '<C-w>' .  '<C-'.key . '>')
endfor

" Go through symbols. Sadly, '|', not supported in submode plugin.
for key in ['=','_','+','-','<','>']
  call submode#map('Window', 'n', '', key, '<C-w>' . key)
endfor

" Old way, just in case.
nnoremap <Leader>w <C-w>
