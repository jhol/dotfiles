#!/bin/bash

set -e
set -o pipefail
set -u

install_path="$(cd "$(dirname "$0")"; pwd -P)"

sudo -v

#
# Install the tools
#

echo "Installing packages"
sudo apt-get install -y -qq tmux vim zsh

#
# Install the configs
#

echo "Installing config symbolic links"
cd $HOME
(cd $install_path; git ls-files) | grep -v -e 'install.sh' -e 'README.md' | while read f; do
  echo "  .$f"
  ln -fs $(realpath --relative-to=$HOME ${install_path}/$f) .$f;
done

#
# Configure vim
#

echo "Installing vim plugins"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null
vim +'PlugInstall --sync' +qa

#
# Configure Zsh
#

if [ ! -d ${HOME}/.oh-my-zsh ]; then
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh 2>/dev/null)"
fi
