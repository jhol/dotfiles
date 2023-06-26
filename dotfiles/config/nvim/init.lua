--
-- Configure NeoVide
--

if vim.g.neovide then
  require('neovide')
end

--
-- Load Plugins
--

require('plugins')

--
-- Load Main Configuration
--

require('config')
