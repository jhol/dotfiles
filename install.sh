#!/bin/bash

set -e
set -o pipefail
set -u

install_path="$(cd "$(dirname "$0")"; pwd -P)"

#
# Install the tools
#

echo "-- Installing packages"

apt_packages="
  cmake
  curl
  kitty
  neovim
  python3-neovim
  python3-pip
  zsh
  "

if ! dpkg -s $apt_packages >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y -qq $apt_packages
else
  echo "  Already Done"
fi

echo "-- Installing pip packages"

pip_packages="
  neovim-remote
  "

if ! pip3 show $pip_packages >/dev/null 2>&1; then
  sudo pip3 install $pip_packages
else
  echo "  Already Done"
fi

#
# Install the configs
#

echo "-- Installing config symbolic links"
cd $HOME
(cd $install_path; git ls-files) | grep -v \
  -e 'bin/' \
  -e 'install.sh' \
  -e 'README.md' \
| while read f; do
  path=.$f
  echo "  $path"
  mkdir -p $(dirname $path)
  ln -fs $(realpath --relative-to=$(dirname $path) ${install_path}/$f) $path;
done

#
# Install the tools
#

echo "-- Installing tool symbolic links"
(cd $install_path; git ls-files) | grep \
  -e 'bin/' \
| while read f; do
  echo "  $f"
  mkdir -p $(dirname $f)
  ln -fs $(realpath --relative-to=$(dirname $f) ${install_path}/$f) $f;
done

#
# Configure neovim
#

echo "-- Configuring NeoVim"

configure_nvim_alternative() {
  link=/usr/bin/$1
  if [ "$(readlink -f $link)" != "/usr/bin/nvim" ]; then
    sudo update-alternatives --remove-all $1 || true
    sudo update-alternatives --install $link vi /usr/bin/nvim 60
  fi
}

configure_nvim_alternative vi
configure_nvim_alternative vim
configure_nvim_alternative editor

echo "-- Installing vim plugins"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null
vim +'PlugInstall --sync' +qa

#
# Configure Zsh
#

if [ ! -d ${HOME}/.zim ]; then
  echo "-- Installing zim"
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

echo "-- Installing zim packages"
zsh ${HOME}/.zim/zimfw.zsh install
