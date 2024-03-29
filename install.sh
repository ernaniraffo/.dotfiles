#/bin/bash

function ubuntu_nvim() {
    # install neovim
    apt install neovim
    apt install python3-neovim
    apt-get install software-properties-common
    add-apt-repository ppa:neovim-ppa/stable
    apt-get update
    
    # install newest version
    apt-get install neovim
    
    # vim-plug install needs curl
    apt install curl
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
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    
    # install plugins
    nvim_plugins

    # stow git and zsh
    brew install git
    brew install stow
    stow_packages
    stow zsh

    # install clangd
    brew install llvm
}

function install_on_ubuntu() {
    # check if running as root
    if [[ $(id -u) != 0 ]]; then
        echo "Please run as root"
        echo "Usage: sudo $0 ubuntu"
        exit
    fi

    # install neovim + plugins
    ubuntu_nvim
    nvim_plugins

    # install git and stow
    apt install git
    apt install stow
    stow_packages
    
    # install clangd language server
    apt-get install clangd-12
}

function usage() {
    echo "Usage: $0 [mac, ubuntu]"
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
