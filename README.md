# .dotfiles
My Neovim and Ghostty configs.

## Install
Clone into `~/.dotfiles` and run as your normal user:

```
./install.sh mac      # or: ./install.sh linux
```

Each top-level folder (`nvim`, `ghostty`, `yapf`) is a
[Stow](https://www.gnu.org/software/stow/) package linked into `~/.config`.
Existing configs in the way are renamed to `<name>.pre-dotfiles`.
On a machine where `~/.config` is a symlink into this repo (the old layout),
rerun `./install.sh` after pulling to switch it over.

## What gets installed
- [Neovim](https://neovim.io) 0.12+ with [vim-plug](https://github.com/junegunn/vim-plug)
- [Ghostty](https://ghostty.org) (macOS)
- [GNU Stow](https://www.gnu.org/software/stow/) to link the configs
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) to build parsers
- Language servers: [clangd](https://clangd.llvm.org) (C/C++),
  [pyright](https://github.com/microsoft/pyright) (Python),
  [Perl Navigator](https://github.com/bscan/PerlNavigator) (Perl)
- [Node.js](https://nodejs.org) to install pyright and Perl Navigator
