#!/bin/bash

set -e
set -o pipefail
set -u

install_path="$(cd "$(dirname "$0")"; pwd -P)"

sudo true

#
# Install the tools
#

echo "Installing packages"
sudo apt-get install -y -qq \
  tmux \
  neovim \
  python3-neovim \
  zsh

#
# Install the configs
#

echo "Installing config symbolic links"
cd $HOME
(cd $install_path; git ls-files) | grep -v -e 'install.sh' -e 'README.md' | while read f; do
  path=.$f
  echo "  $path"
  mkdir -p $(dirname $path)
  ln -fs $(realpath --relative-to=$(dirname $path) ${install_path}/$f) $path;
done

#
# Configure neovim
#

echo "Configuring NeoVim"

sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor

echo "Installing vim plugins"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null
vim +'PlugInstall --sync' +qa

#
# Configure Zsh
#

if [ ! -d ${HOME}/.oh-my-zsh ]; then
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh 2>/dev/null)"
fi
