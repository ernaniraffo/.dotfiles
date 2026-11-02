# .dotfiles
My dotfiles configurations.

## Installing
Clone this repository into your home directory (as `~/.dotfiles`, since
`stow` links into the parent directory) and run the install script with your
operating system:

```
$ ./install.sh mac
$ ./install.sh ubuntu
```

By default this sets up Neovim and Ghostty only. The `zsh` package holds my
personal shell aliases, so on macOS it's opt-in:

```
$ ./install.sh mac --personal   # also stows zsh
```

Git settings (name, email) aren't part of these dotfiles; set your own with
`git config --global`.

Run it as your normal user, **not** as root or with `sudo`. The script calls
`sudo` itself only for package installs, so stow, vim-plug and plugin builds
don't run as root or leave root-owned files in `$HOME`. On Ubuntu the script
refuses to run as root.

### What the script does

**macOS** (uses Homebrew):
1. Installs Neovim and curl, then downloads [vim-plug](https://github.com/junegunn/vim-plug).
2. Installs git and stow, then stows the `nvim` package (plus `zsh` with
   `--personal`).
3. Installs [Ghostty](https://ghostty.org) if it isn't in `/Applications`, and
   moves aside any config in `~/Library/Application Support/com.mitchellh.ghostty`
   (it would override the dotfiles' `~/.config/ghostty/config.ghostty`).
4. Installs `tree-sitter-cli`, which nvim-treesitter needs to build parsers.
5. Installs the Neovim plugins (`:PlugInstall`).
6. Installs `llvm` (for the `clangd` language server).

Restart Ghostty afterwards (or press `cmd+shift+,`) to load its config.

**Ubuntu** (uses apt):
1. Installs Neovim from the `neovim-ppa/stable` PPA, `python3-neovim` and curl,
   then downloads vim-plug.
2. Installs git and stow, then stows the `nvim` package.
3. Installs the Neovim plugins (`:PlugInstall`).
4. Installs `clangd-12`.

On both, files that already exist where stow wants to link (such as a
`~/.zshrc`) are moved aside as `<name>.pre-dotfiles` first,
since stow would otherwise skip the whole package.

The Ubuntu path does **not** install `tree-sitter-cli`. apt's version is
likely older than the 0.26.1+ that nvim-treesitter requires, so install a
recent release yourself (for example from the
[tree-sitter releases](https://github.com/tree-sitter/tree-sitter/releases))
and then run `:TSUpdate` in Neovim.

## Neovim

The configs require **Neovim 0.12+**: nvim-treesitter's `main` branch needs
0.12, and the LSP setup uses `vim.lsp.config`/`vim.lsp.enable` (0.11+).

Treesitter parsers (`c`, `cpp`, `python`, `bash`) are installed automatically
on first launch into `~/.local/share/nvim/site`. Building them needs
`tree-sitter-cli`, `curl`, `tar` and a C compiler.
