#/bin/bash

function stow_packages() {
    stow nvim
    stow git
}

function nvim_plugins() {
    nvim --headless +PlugInstall +qall
}

function install_on_macOS() {
    brew install nvim
    brew install git
    brew install stow
    stow_packages
    stow zsh
    nvim_plugins
}

function install_on_ubuntu() {
    apt-get install neovim
    apt-get install git
    apt-get install stow
    stow_packages
    nvim_plugins
}

function usage() {
    echo "Usage: $0 --[mac, ubuntu]"
}

if [[ $# -gt 2 ]];  then
    usage
elif [[ $1 == "mac" ]]; then
    install_on_macOS
elif [[ $1 == "ubuntu" ]]; then
    install_on_ubuntu
else
    usage
fi
