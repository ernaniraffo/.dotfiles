#!/bin/bash

# stow links packages into the parent of the repo (normally ~), so always run
# from the repo itself, wherever the script was called from.
cd "$(dirname "$0")" || exit 1
TARGET=$(dirname "$PWD")

# --personal (macOS) also stows my own zsh config (aliases).
PERSONAL=false

function ubuntu_nvim() {
    # install neovim
    sudo apt install neovim
    sudo apt install python3-neovim
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get update
    
    # install newest version
    sudo apt-get install neovim
    
    # vim-plug install needs curl
    sudo apt install curl
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

# Stow one package. Files that already exist where stow wants to link (e.g. a
# ~/.zshrc made before the dotfiles) would make stow skip the whole package,
# so move them aside first as <name>.pre-dotfiles.
function stow_package() {
    local pkg=$1 target
    stow -n "$pkg" 2>&1 |
        sed -n -e 's/.* over existing target \(.*\) since .*/\1/p' \
               -e 's/.*existing target is not owned by stow: \(.*\)/\1/p' |
        while read -r target; do
            echo "Moving existing $TARGET/$target to $TARGET/$target.pre-dotfiles"
            mv "$TARGET/$target" "$TARGET/$target.pre-dotfiles"
        done
    stow "$pkg"
}

function stow_packages() {
    # The git package was removed from the repo (it held my name/email); drop
    # the ~/.gitconfig link an older install made to it, now pointing nowhere.
    if [[ -L $TARGET/.gitconfig && ! -e $TARGET/.gitconfig &&
          $(readlink "$TARGET/.gitconfig") == *.dotfiles/git/.gitconfig ]]; then
        echo "Removing broken link $TARGET/.gitconfig (git config is no longer in the dotfiles)"
        rm "$TARGET/.gitconfig"
    fi

    stow_package nvim  # also holds ~/.config/ghostty
}

function nvim_plugins() {
    # --sync: wait for every plugin to finish installing before quitting
    nvim --headless "+PlugInstall --sync" +qall
}

function ghostty_macOS() {
    if [[ ! -d /Applications/Ghostty.app ]]; then
        brew install --cask ghostty
    fi

    # On macOS Ghostty also reads ~/Library/Application Support/com.mitchellh.ghostty,
    # which overrides ~/.config/ghostty (from the dotfiles). Ghostty writes a
    # template there on first launch, so move any config there aside.
    local dir="$HOME/Library/Application Support/com.mitchellh.ghostty" f
    for f in "$dir/config" "$dir/config.ghostty"; do
        if [[ -f $f ]]; then
            echo "Moving $f to $f.pre-dotfiles"
            mv "$f" "$f.pre-dotfiles"
        fi
    done
}

function install_on_macOS() {
    # install neovim
    brew install nvim

    # install vim-plug
    brew install curl
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # stow (before installing plugins, so the nvim config exists)
    brew install git
    brew install stow
    stow_packages
    if $PERSONAL; then
        stow_package zsh
    fi

    # Ghostty terminal (its config comes from the nvim package above)
    ghostty_macOS

    # nvim-treesitter (main branch) builds parsers with tree-sitter-cli
    brew install tree-sitter-cli

    # install plugins
    nvim_plugins

    # install clangd
    brew install llvm

    # language servers for Python (pyright) and Perl (Perl Navigator), from npm.
    # Use Homebrew's npm explicitly: another Node (e.g. the nodejs.org
    # installer) may come first on PATH with a root-owned global folder.
    brew install node
    "$(brew --prefix)/bin/npm" install -g pyright perlnavigator-server

    echo "Done. Restart Ghostty (or press cmd+shift+,) to load the new config."
}

function install_on_ubuntu() {
    # Run as your normal user: only the package installs use sudo, so stow,
    # vim-plug and plugin builds don't run third-party code as root or write
    # root-owned files into $HOME.
    if [[ $(id -u) == 0 ]]; then
        echo "Please run as your normal user (not root/sudo)"
        echo "Usage: $0 ubuntu"
        exit 1
    fi

    # install neovim + plugins
    ubuntu_nvim

    # install git and stow (before installing plugins, so the nvim config exists)
    sudo apt install git
    sudo apt install stow
    stow_packages

    nvim_plugins
    
    # install clangd language server (the clangd package provides the `clangd`
    # command Neovim runs; clangd-NN packages only provide `clangd-NN`)
    sudo apt-get install clangd

    # language servers for Python (pyright) and Perl (Perl Navigator), from npm.
    # They need Node 16+ (apt has 18 on Ubuntu 24.04). Installed into ~/.local,
    # whose bin/ Ubuntu puts on PATH, so npm doesn't need sudo.
    sudo apt install nodejs npm
    npm install -g --prefix "$HOME/.local" pyright perlnavigator-server
}

function usage() {
    echo "Usage: $0 [mac, ubuntu] [--personal]"
    echo "  --personal  (mac) also stow my zsh config (personal aliases)"
}

if [[ $# -eq 2 && $2 == "--personal" ]]; then
    PERSONAL=true
elif [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

if [[ $1 == "mac" ]]; then
    install_on_macOS
elif [[ $1 == "ubuntu" ]]; then
    install_on_ubuntu
else
    usage
fi
