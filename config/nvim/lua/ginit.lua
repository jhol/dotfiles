--
-- GUI Configuration
--

--
-- Font
--

vim.call('GuiFont', 'Source Code Pro for Powerline:h8')

--
-- Disable the GUI tab-line
--

vim.call('rpcnotify', 0, 'Gui', 'Option', 'Tabline', 0)

--
-- Full Screen Toggle
--

vim.api.nvim_exec(
[[

function! s:GuiFullScreenToggle()
  if g:GuiWindowFullScreen == 0
    call GuiWindowFullScreen(1)
  else
    call GuiWindowFullScreen(0)
  endif
endfunction

command! GuiFullScreenToggle call s:GuiFullScreenToggle()

]], true)

vim.api.nvim_set_keymap('n', '<F11>', ':GuiFullScreenToggle<CR>', { noremap = false })
