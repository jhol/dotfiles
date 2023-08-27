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

-- Window Navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = false })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = false })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = false })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = false })
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w><', { noremap = false })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>+', { noremap = false })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>-', { noremap = false })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>>', { noremap = false })
vim.api.nvim_set_keymap('n', '<cr>', '<C-w>w', { noremap = false })

local wk = require("which-key")

wk.register({
  ['<C-h>'] = { '<C-w>h', 'Go to the left window' },
  ['<C-j>'] = { '<C-w>j', 'Go to the up window' },
  ['<C-k>'] = { '<C-w>k', 'Go to the down window' },
  ['<C-l>'] = { '<C-w>l', 'Go to the right window' },
  ['<A-h>'] = { '<C-w><', 'Decrease width' },
  ['<A-j>'] = { '<C-w>+', 'Increase height' },
  ['<A-k>'] = { '<C-w>-', 'Decrease height' },
  ['<A-l>'] = { '<C-w>>', 'Increase width' },
  ['<cr>'] = { '<C-w>w', 'Switch windows' }
})

--
-- Code Folding
--

vim.o.foldmethod = 'indent'
vim.o.foldnestmax = 10
vim.o.foldenable = false
vim.o.foldlevel = 2

--
-- Line Numbering
--

vim.api.nvim_command('set number relativenumber')

-- Hide line numbers in terminal buffers
vim.api.nvim_command("au TermOpen * setlocal nonumber norelativenumber")

--
-- netrw File Browser
--

vim.api.nvim_command('let g:netrw_liststyle = 3')

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

]], true)

vim.api.nvim_set_keymap('n', '<leader>F', ':Focus<CR>', { noremap = false })


--
-- neovim-remote
--

if vim.fn.has('nvim') then
  vim.env.NVIM_LISTEN_ADDRESS = vim.v.servername
  vim.env.GIT_EDITOR = 'nvr -cc split --remote-wait'
end
