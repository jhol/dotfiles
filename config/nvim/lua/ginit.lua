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
