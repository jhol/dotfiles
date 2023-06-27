require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use 'airblade/vim-rooter'
  use 'camspiers/lens.vim'
  use 'chriskempson/base16-vim'
  use 'embear/vim-localvimrc'
  use 'jenterkin/vim-autosource'
  use 'jlanzarotta/bufexplorer'
  use { 'junegunn/fzf', run = 'cd ~/.fzf; ./install --all' }
  use 'junegunn/fzf.vim'
  use 'LnL7/vim-nix'
  use 'neovim/nvim-lspconfig'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    commit = 'b9bcbf8d73b5a6c3e04922936b5fc500b436d4f5'
  }
  use 'pbrisbin/vim-mkdir'
  use 'peterhoeg/vim-qml'
  use 'rbong/vim-flog'
  use 'Shirk/vim-gas'
  use 'sirtaj/vim-openscad'
  use 'skywind3000/asyncrun.vim'
  use 'tomtom/tinykeymap_vim'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-repeat'
  use 'vhdirk/vim-cmake'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'vim-scripts/SmartCase'
  use 'vim-scripts/errormarker.vim'

  -- Order is important
  use 'tpope/vim-sleuth'
  use 'sgur/vim-editorconfig'
end)