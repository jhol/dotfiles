#!/usr/bin/env bash

set -e
set -o pipefail
set -u

install_path="$(cd "$(dirname "$0")"; pwd -P)"

#
# Install the configs
#

echo "-- Installing config symbolic links"
cd "$HOME"
(cd "$install_path"; git ls-files) | grep -v \
  -e 'bin/' \
  -e 'install.sh' \
  -e 'README.md' \
| while read -r f; do
  path=.$f
  echo "  $path"
  mkdir -p "$(dirname "$path")"
  ln -fs "$(realpath --relative-to="$(dirname "$path")" "${install_path}/$f")" "$path";
done

#
# Install the tools
#

echo "-- Installing tool symbolic links"
(cd "$install_path"; git ls-files) | grep \
  -e 'bin/' \
| while read -r f; do
  echo "  $f"
  mkdir -p "$(dirname "$f")"
  ln -fs "$(realpath --relative-to="$(dirname "$f")" "${install_path}/$f")" "$f";
done

#
# Configure neovim
#

echo "-- Installing vim plugins"

packer_nvim_dir=$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
if [ ! -d "$packer_nvim_dir" ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
      "$packer_nvim_dir"
fi

nvim \
  -u "$HOME"/.config/nvim/lua/plugins.lua \
  -c 'autocmd User PackerComplete ++once qa' \
  -c 'PackerSync'

#
# Configure Zsh
#

if [ ! -d "${HOME}/.zim" ]; then
  echo "-- Installing zim"
  cp "${HOME}/.zshrc" "${HOME}/.zshrc.bak"
  sed -i '/ZIM/d' "${HOME}/.zshrc"
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
  cp "${HOME}/.zshrc.bak" "${HOME}/.zshrc"
else
  echo "-- Upgrading zim"
  >/dev/null zsh "${HOME}/.zim/zimfw.zsh" upgrade
fi

echo "-- Installing zim packages"
>/dev/null zsh "${HOME}/.zim/zimfw.zsh" install

echo "-- Upgrading zim packages"
>/dev/null zsh "${HOME}/.zim/zimfw.zsh" upgrade
