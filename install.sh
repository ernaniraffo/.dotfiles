#!/bin/bash

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

function stow_packages() {
    stow nvim
    stow git
}

function nvim_plugins() {
    nvim --headless +PlugInstall +qall
}

function install_on_macOS() {
    # install neovim
    brew install nvim

    # install vim-plug
    brew install curl
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # stow git and zsh (before installing plugins, so the nvim config exists)
    brew install git
    brew install stow
    stow_packages
    stow zsh

    # install plugins
    nvim_plugins

    # install clangd
    brew install llvm
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
    
    # install clangd language server
    sudo apt-get install clangd-12
}

function usage() {
    echo "Usage: $0 [mac, ubuntu]"
}

if [[ $# -ne 1 ]]; then
    usage
elif [[ $1 == "mac" ]]; then
    install_on_macOS
elif [[ $1 == "ubuntu" ]]; then
    install_on_ubuntu
else
    usage
fi
