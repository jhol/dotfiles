--
-- Neovide Configuration
--

--
-- Font
--

vim.o.guifont = 'Source Code Pro for Powerline:h8.0';

--
-- Animation
--

vim.g.neovide_refresh_rate = 60;
vim.g.neovide_cursor_animation_length = 0.01;

--
-- Full Screen Toggle
--

vim.api.nvim_exec(
[[

function! s:GuiFullScreenToggle()
  let g:neovide_fullscreen=!g:neovide_fullscreen
endfunction

command! GuiFullScreenToggle call s:GuiFullScreenToggle()

]], true)

vim.api.nvim_set_keymap('n', '<F11>', ':GuiFullScreenToggle<CR>', { noremap = false })
