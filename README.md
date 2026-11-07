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
7. Installs Node and, with npm, the `pyright` (Python) and Perl Navigator
   (Perl) language servers.

Restart Ghostty afterwards (or press `cmd+shift+,`) to load its config.

**Ubuntu** (uses apt):
1. Installs curl and `python3-neovim`, then the latest Neovim release from
   GitHub into `/opt`, linked as `/usr/local/bin/nvim`. apt and the Neovim PPA
   only have versions older than the 0.12 this config needs. Then it downloads
   vim-plug.
2. Installs git and stow, then stows the `nvim` package.
3. Installs the Neovim plugins (`:PlugInstall`).
4. Installs `clangd`, then Node/npm and the `pyright` and Perl Navigator
   language servers (into `~/.local`, so no sudo). These need Node 16+, which
   apt provides from Ubuntu 24.04.

On both, files that already exist where stow wants to link (such as a
`~/.zshrc`) are moved aside as `<name>.pre-dotfiles` first,
since stow would otherwise skip the whole package.

The Ubuntu path does **not** install `tree-sitter-cli`. apt's version is
likely older than the 0.26.1+ that nvim-treesitter requires, so install a
recent release yourself (for example from the
[tree-sitter releases](https://github.com/tree-sitter/tree-sitter/releases))
and then run `:TSUpdate` in Neovim.

## Neovim

The configs require **Neovim 0.12+**: nvim-treesitter's `main` branch and
`vim.lsp.semantic_tokens.enable` both need it.

Treesitter parsers (`c`, `python`, `bash`) are installed automatically on first
launch into `~/.local/share/nvim/site`. Building them needs `tree-sitter-cli`,
`curl`, `tar` and a C compiler.

C++ deliberately doesn't use Treesitter. Compiling its queries added about
170 ms to opening a C++ file (or a `.h` file, which Neovim treats as C++), so it
uses regex syntax from
[vim-cpp-modern](https://github.com/bfrg/vim-cpp-modern). To go back, add
`'cpp'` to the list in `lua/eraffo/treesitter.lua` and remove the cpp check
there. `:TSUninstall cpp` removes a parser left over from an older setup. Until
you run it, Telescope previews, hover popups and Markdown code blocks still use
that parser.

That has a few limits:

- `cpp` code blocks in Markdown and in LSP hover popups aren't colored.
- Headers in a C project are colored a little differently from `.c` files.
- Jumping into the middle of a raw string or `#if 0` block longer than 50 lines
  can show the wrong colors. `g:c_minlines` widens that window, but makes far
  jumps slower.

LSP semantic tokens are off, because they recolor a file up to a second after it
opens. That also means `clangd` doesn't dim code in inactive `#ifdef` branches.

## Themes

Ghostty and Neovim both follow the system light/dark appearance: Ghostty
switches its own theme, then Neovim picks up the new background color from
Ghostty and reloads its colorscheme. They're configured separately, so changing
theme means editing both.

**Ghostty:** set both sides of the `theme` line in
`nvim/.config/ghostty/config.ghostty`, then press `cmd+shift+,`:

```
theme = light:Gruvbox Light,dark:Gruvbox Dark Hard
```

Copy the names from `ghostty +list-themes`, because config validation can miss
a typo on the side that isn't currently active.

**Neovim:** add the colorscheme's `Plug` line to `nvim/.config/nvim/init.vim`
and run `:PlugInstall`. Then set it up in `lua/eraffo/colors.lua` and restart
Neovim. Run `:PlugClean` if you removed the old one.

- Use a colorscheme that picks its light or dark version from `background` and
  doesn't set `background` itself. One that does, like `morhetz/gruvbox`, stops
  Neovim following the terminal. How to set it up varies, so check its README.
  Some colorschemes have a separate name for each version, like
  `kanagawa-dragon`. Naming one starts on that version whatever the system
  appearance is.
- Don't set `background` anywhere in the config, or Neovim stops following the
  terminal.
- The settings in `colors.lua` are specific to Gruvbox, including the ones that
  match its backgrounds to the Ghostty themes, so redo them for the new
  colorscheme.

To check it works, switch the system appearance with Neovim open and run
`:set background?`.
