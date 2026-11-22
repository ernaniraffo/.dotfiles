#!/bin/bash
set -e
cd "$(dirname "$0")"
TARGET=$(dirname "$PWD")

# Move aside files that would block stow, then link the configs.
stow_nvim() {
    stow -n nvim 2>&1 | sed -n 's/.*existing target \(is not owned by stow: \)\{0,1\}\([^ ]*\).*/\2/p' |
        while read -r f; do mv "$TARGET/$f" "$TARGET/$f.pre-dotfiles"; done
    stow nvim
}

plug() {
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

mac() {
    brew install nvim git stow tree-sitter-cli llvm node
    [[ -d /Applications/Ghostty.app ]] || brew install --cask ghostty
    # This location overrides ~/.config/ghostty.
    for f in "$HOME/Library/Application Support/com.mitchellh.ghostty/config"{,.ghostty}; do
        [[ -f $f ]] && mv "$f" "$f.pre-dotfiles"
    done
    plug && stow_nvim
    nvim --headless "+PlugInstall --sync" +qall
    "$(brew --prefix)/bin/npm" install -g pyright perlnavigator-server
}

ubuntu() {
    [[ $(id -u) != 0 ]] || { echo "Run as your normal user, not root"; exit 1; }
    sudo apt-get update
    sudo apt-get install -y curl git stow build-essential clangd nodejs npm
    local arch=$(uname -m) ts=x64
    [[ $arch == aarch64 ]] && arch=arm64 ts=arm64
    # apt's Neovim and tree-sitter are too old.
    sudo rm -rf "/opt/nvim-linux-$arch"
    curl -fL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz" |
        sudo tar -C /opt -xz
    sudo ln -sf "/opt/nvim-linux-$arch/bin/nvim" /usr/local/bin/nvim
    curl -fL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$ts.gz" |
        gunzip | sudo tee /usr/local/bin/tree-sitter >/dev/null
    sudo chmod +x /usr/local/bin/tree-sitter
    plug && stow_nvim
    nvim --headless "+PlugInstall --sync" +qall
    npm install -g --prefix "$HOME/.local" pyright perlnavigator-server
}

case $1 in
    mac|ubuntu) $1 ;;
    *) echo "Usage: $0 mac|ubuntu"; exit 1 ;;
esac
