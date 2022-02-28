--
-- Base Configuration
--

vim.o.cmdheight = 1
vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.signcolumn = "yes"
vim.o.updatetime = 300

-- Undo file
vim.o.undofile = true
vim.o.undodir = string.format("%s/.vim/undo", vim.env.HOME)

-- Color Column
vim.o.colorcolumn = "120"
vim.api.nvim_command("hi ColorColumn ctermbg=4")

vim.api.nvim_set_keymap("x", "p", "pgvy", { noremap = true })

vim.api.nvim_command("filetype plugin indent on")

vim.opt.syntax = "on"

-- Mouse Configuraturation
vim.o.mouse = "a"

-- Fold Configuration
vim.o.foldmethod = "syntax"
vim.o.foldnestmax = 10
vim.o.foldenable = false

-- Terminal Configuration
vim.o.shell = "zsh"

--
-- Load Plugins
--

local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug('airblade/vim-rooter')
Plug('camspiers/lens.vim')
Plug('chriskempson/base16-vim')
Plug('embear/vim-localvimrc')
Plug('ggandor/lightspeed.nvim')
Plug('jlanzarotta/bufexplorer')
Plug('junegunn/fzf', { dir = '~/.fzf', ['do'] = './install --all' })
Plug('junegunn/fzf.vim')
Plug('pbrisbin/vim-mkdir')
Plug('rbong/vim-flog')
Plug('Shirk/vim-gas')
Plug('sirtaj/vim-openscad')
Plug('skywind3000/asyncrun.vim')
Plug('tomtom/tinykeymap_vim')
Plug('tpope/vim-fugitive')
Plug('tpope/vim-repeat')
Plug('vhdirk/vim-cmake')
Plug('vim-airline/vim-airline')
Plug('vim-airline/vim-airline-themes')
Plug('vim-scripts/SmartCase')
Plug('vim-scripts/errormarker.vim')
Plug('vim-scripts/zoom.vim')

-- Order is important
Plug('sheerun/vim-polyglot')
Plug('tpope/vim-sleuth')
Plug('sgur/vim-editorconfig')

vim.call('plug#end')

--
-- Colour Scheme
--

vim.o.termguicolors = (not vim.env.TMUX and vim.fn.has('termguicolors') == 1)

vim.api.nvim_command("colorscheme base16-default-dark")

vim.call('Base16hi', 'Normal', vim.g.base16_gui05, '000000', vim.g.base16_cterm05, vim.g.base16_cterm00, '', '')
vim.call('Base16hi', 'LineNr', vim.g.base16_gui03, '000000', vim.g.base16_cterm03, vim.g.base16_cterm00, '', '')

vim.g.terminal_color_0  = '#2e3436'
vim.g.terminal_color_1  = '#cc0000'
vim.g.terminal_color_2  = '#4e9a06'
vim.g.terminal_color_3  = '#c4a000'
vim.g.terminal_color_4  = '#3465a4'
vim.g.terminal_color_5  = '#75507b'
vim.g.terminal_color_6  = '#0b939b'
vim.g.terminal_color_7  = '#d3d7cf'
vim.g.terminal_color_8  = '#555753'
vim.g.terminal_color_9  = '#ef2929'
vim.g.terminal_color_10 = '#8ae234'
vim.g.terminal_color_11 = '#fce94f'
vim.g.terminal_color_12 = '#729fcf'
vim.g.terminal_color_13 = '#ad7fa8'
vim.g.terminal_color_14 = '#00f5e9'
vim.g.terminal_color_15 = '#eeeeec'

--
-- Additional Synax Highlighting
--

vim.api.nvim_command("au BufRead,BufNewFile *.[sS] set filetype=gas")

--
-- AirLine
--

vim.g.airline_powerline_fonts = 1
vim.g.airline_theme = 'base16'
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g['airline#extensions#tabline#fnamemod'] = ':t'
vim.api.nvim_command("let g:airline_section_error = airline#section#create_right(['%{g:asyncrun_status}'])")

--
-- Key Binding
--

-- Disable XON/XOFF
vim.api.nvim_set_keymap('', '<C-q>', '', { noremap = true })
vim.api.nvim_set_keymap('', '<C-s>', '', { noremap = true })

-- Hide search highlight
vim.api.nvim_set_keymap('', 'z/', ':nohlsearch<CR>', { noremap = true })

-- Close the buffer without closing the split
vim.api.nvim_set_keymap('n', '<leader>bd', ':bp\\|bd #<CR>', { noremap = false })

-- Quick-fix list
vim.api.nvim_set_keymap('n', '<leader>qo', ':copen<CR>', { noremap = false })
vim.api.nvim_set_keymap('n', '<leader>qc', ':cclose<CR>', { noremap = false })

vim.api.nvim_set_keymap('t', '<C-Space>', '<C-\\><C-n>', { noremap = true })

--
-- Code folding
--

vim.o.foldmethod = 'indent'
vim.o.foldnestmax = 10
vim.o.foldenable = false
vim.o.foldlevel = 2

--
-- Line numbering
--

vim.api.nvim_command('set number relativenumber')

-- Hide line numbers in terminal buffers
vim.api.nvim_command("au TermOpen * setlocal nonumber norelativenumber")

--
-- netrw file browser
--

vim.api.nvim_exec(
[[

let g:netrw_liststyle = 3

]], true)

--
-- localvimrc
--

vim.api.nvim_exec(
[[

let g:localvimrc_persistent=1
let g:localvimrc_sandbox=0

]], true)

--
-- tinykeymap bindings
--

vim.api.nvim_exec(
[[

let g:tinykeymap#timeout = 1000

let g:tinykeymap#mapleader = '<leader>'
call tinykeymap#Load(['buffers'])
call tinykeymap#Load(['qfl'])
call tinykeymap#Load(['tabs'])

let g:tinykeymap#map#windows#map = '<C-w>'
call tinykeymap#Load(['windows'])

]], true)

--
-- fzf
--

vim.api.nvim_exec(
[[

nmap <leader>ff :Files<CR>
nmap <leader>fg :GFiles<CR>
nmap <leader>fs :GFiles?<CR>
nmap <leader>fb :Buffers<CR>
nmap <leader>fl :BLines<CR>
nmap <leader>fL :Lines<CR>
nmap <leader>fa :Ag<CR>

]], true)

--
-- AsyncRun
--

vim.api.nvim_exec(
[[

let g:asyncrun_auto = "make"
let g:asyncrun_open = 10
let g:asyncrun_rootmarks = ['build', '_build', '.git']
let g:asyncrun_status = ''

nmap <leader>mm :AsyncRun -cwd=<root> -program=make<CR>
nmap <leader>mc :AsyncStop<CR>

]], true)

--
-- vim-fugitive
--

vim.api.nvim_exec(
[[

nmap <leader>ga :Gwrite<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gs :Git<CR>
nmap <leader>gv :Flogsplit<CR>
nmap <leader>gV :Flogsplit -all<CR>

]], true)

--
-- lens.vim
--

vim.api.nvim_exec(
[[

let g:lens#width_resize_min = 20
let g:lens#width_resize_max = 128

]], true)

--
-- Focus
--

vim.api.nvim_exec(
[[

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

]], true)

--
-- vim-cmake
--

vim.api.nvim_exec(
[[

let g:cmake_export_compile_commands = 1
let g:cmake_ycm_symlinks = 1

]], true)

--
-- neovim-remote
--

vim.api.nvim_exec(
[[

if has('nvim')
  let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

]], true)

--
-- lighspeed.nvim
--

vim.api.nvim_exec(
[[

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

]], true)
