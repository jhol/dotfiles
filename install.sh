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
(cd "$install_path/dotfiles"; git ls-files) | \
while read -r f; do
  path=.$f
  echo "  $path"
  mkdir -p "${HOME}/$(dirname "$path")"
  ln -fs "$(realpath --relative-to="$(dirname "$path")" "${install_path}/dotfiles/$f")" "${HOME}/$path";
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
