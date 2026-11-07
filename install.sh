#!/bin/bash

# stow links packages into the parent of the repo (normally ~), so always run
# from the repo itself, wherever the script was called from.
cd "$(dirname "$0")" || exit 1
TARGET=$(dirname "$PWD")

function ubuntu_nvim() {
    sudo apt-get update
    sudo apt install curl python3-neovim

    # Neovim from its official release, as Neovim's install guide describes.
    # The config needs 0.12+, and apt and the neovim-ppa only have older
    # versions (the PPA's stable is 0.7.2). /usr/local/bin is on PATH by
    # default and comes before /usr/bin, so it also wins over an apt install.
    local arch tmp
    case $(uname -m) in
        x86_64) arch=x86_64 ;;
        aarch64) arch=arm64 ;;
        *) echo "No Neovim release for $(uname -m)"; exit 1 ;;
    esac
    tmp=$(mktemp -d)
    curl -fLo "$tmp/nvim.tar.gz" \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz" || exit 1
    sudo rm -rf "/opt/nvim-linux-$arch"
    sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
    sudo ln -sf "/opt/nvim-linux-$arch/bin/nvim" /usr/local/bin/nvim
    rm -rf "$tmp"
    hash -r  # forget any nvim bash already found on PATH

    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

function ubuntu_tree_sitter() {
    # nvim-treesitter (main branch) builds parsers with tree-sitter-cli and a C
    # compiler. apt's tree-sitter-cli is older than the version it needs, so use
    # the official release, the same way as Neovim.
    sudo apt install build-essential

    local arch tmp
    case $(uname -m) in
        x86_64) arch=x64 ;;
        aarch64) arch=arm64 ;;
        *) echo "No tree-sitter release for $(uname -m)"; return ;;
    esac
    tmp=$(mktemp -d)
    curl -fLo "$tmp/tree-sitter.gz" \
        "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$arch.gz" || exit 1
    gunzip "$tmp/tree-sitter.gz"
    chmod +x "$tmp/tree-sitter"
    # The release needs a recent glibc (Ubuntu 24.04+), so make sure it runs.
    if "$tmp/tree-sitter" --version; then
        sudo install -m 755 "$tmp/tree-sitter" /usr/local/bin/tree-sitter
    else
        echo "The tree-sitter release doesn't run on this system, likely because it needs a newer glibc (Ubuntu 24.04+)."
        echo "Treesitter highlighting falls back to regex syntax until tree-sitter-cli is installed."
    fi
    rm -rf "$tmp"
}

# Stow one package. Files that already exist where stow wants to link (e.g. a
# ~/.config/nvim made before the dotfiles) would make stow skip the whole package,
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

    # before the plugins, whose install builds the Treesitter parsers
    ubuntu_tree_sitter

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
    echo "Usage: $0 [mac, ubuntu]"
}

if [[ $# -ne 1 ]]; then
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
