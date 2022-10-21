#/bin/bash

function ubuntu_nvim() {
    # install neovim
    sudo apt install neovim
    sudo apt install python3-neovim
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get update
    # install again just in case
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
    brew install nvim
    brew install git
    brew install stow
    stow_packages
    stow zsh
    nvim_plugins
    brew install llvm
}

function install_on_ubuntu() {
    ubuntu_nvim
    sudo apt install git
    sudo apt install stow
    stow_packages
    nvim_plugins
    # install clangd language server
    sudo apt-get install clangd-12
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
