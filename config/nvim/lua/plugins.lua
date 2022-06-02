require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use 'airblade/vim-rooter'
  use 'camspiers/lens.vim'
  use 'chriskempson/base16-vim'
  use 'embear/vim-localvimrc'
  use 'ggandor/lightspeed.nvim'
  use 'jenterkin/vim-autosource'
  use 'jlanzarotta/bufexplorer'
  use { 'junegunn/fzf', run = 'cd ~/.fzf; ./install --all' }
  use 'junegunn/fzf.vim'
  use 'Lenovsky/nuake'
  use 'neovim/nvim-lspconfig'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    commit = '808473cfbb41ef07b57397100f3593d7a6aa788f'
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
  use 'jhol/zoomer.vim'

  -- Order is important
  use 'tpope/vim-sleuth'
  use 'sgur/vim-editorconfig'
end)
