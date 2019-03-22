#!/bin/bash

set -e
set -o pipefail
set -u

install_path="$(cd "$(dirname "$0")"; pwd -P)"

#
# Install the tools
#

sudo apt-get install tmux vim zsh

#
# Install the configs
#

cd $HOME
(cd $install_path; git ls-files) | grep -v -e 'install.sh' -e 'README.md' | while read f; do
  ln -fs $(realpath --relative-to=$HOME ${install_path}/$f) .$f; done

#
# Configure tmux
#

tpm_dir=~/.tmux/plugins/tpm
[ ! -d $tpm_dir ] && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#
# Configure vim
#

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +'PlugInstall --sync' +qa

#
# Configure Zsh
#

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
