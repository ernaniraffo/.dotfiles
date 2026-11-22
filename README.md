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

This sets up Neovim and Ghostty only. Your shell config and git settings
(name, email) aren't part of these dotfiles, so keep your own.
[Shell (optional)](#shell-optional) describes the zsh setup I use with them.

> [!IMPORTANT]
> **Your shell needs two things on `PATH`** for the editor and its language
> servers to be found:
>
> - **macOS:** Homebrew's binaries. Homebrew's installer tells you to add
>   `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile`. That works;
>   [Homebrew](#homebrew) below shows a faster way to do the same.
> - **Ubuntu with zsh:** `~/.local/bin`, where the script installs `pyright`
>   and Perl Navigator. Bash adds it by default, but zsh doesn't, so add
>   `export PATH="$HOME/.local/bin:$PATH"` to your `~/.zshrc`.
>
> Optionally, `alias vi=nvim` and `alias vim=nvim` open Neovim from the usual
> commands.

> [!WARNING]
> Older versions of these dotfiles linked `~/.zshrc` into the repo. If yours is
> still a link (`ls -l ~/.zshrc` shows `->`), replace it with a copy **before**
> pulling, or your shell config disappears:
> `cp ~/.zshrc ~/.zshrc.copy && mv ~/.zshrc.copy ~/.zshrc`.

Run it as your normal user, **not** as root or with `sudo`. The script calls
`sudo` itself only for package installs, so stow, vim-plug and plugin builds
don't run as root or leave root-owned files in `$HOME`. On Ubuntu the script
refuses to run as root.

### What the script does

**macOS** (uses Homebrew):
1. Installs Neovim and curl, then downloads [vim-plug](https://github.com/junegunn/vim-plug).
2. Installs git and stow, then stows the `nvim` package.
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
1. Installs curl, then the latest Neovim release from
   GitHub into `/opt`, linked as `/usr/local/bin/nvim`. apt and the Neovim PPA
   only have versions older than the 0.12 this config needs. Then it downloads
   vim-plug.
2. Installs git and stow, then stows the `nvim` package.
3. Installs a C compiler (`build-essential`) and the latest `tree-sitter-cli`
   release from GitHub as `/usr/local/bin/tree-sitter`, which nvim-treesitter
   needs to build parsers. apt's version is too old. The release needs Ubuntu
   24.04+, and on older systems the script says so and skips it.
4. Installs the Neovim plugins (`:PlugInstall`).
5. Installs `clangd`, then Node/npm and the `pyright` and Perl Navigator
   language servers (into `~/.local`, so no sudo). These need Node 16+, which
   apt provides from Ubuntu 24.04.

On both, files that already exist where stow wants to link (such as a
`~/.config/nvim`) are moved aside as `<name>.pre-dotfiles` first,
since stow would otherwise skip the whole package.

If the script skipped `tree-sitter-cli` on an older Ubuntu, install a recent
release another way (for example `cargo install tree-sitter-cli`), then run
`:TSUpdate` in Neovim.

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

## Ghostty

Besides the theme (see [Themes](#themes)), `nvim/.config/ghostty/config.ghostty`
sets two things:

- **`command = direct:/bin/zsh -l`** starts zsh as a login shell without the
  bash step Ghostty otherwise adds on macOS, about 2 ms sooner per new window.
  macOS's `login(1)` still runs. This assumes zsh: delete the line if you use
  another shell, or on Ubuntu with bash.
- **A quick terminal on `` cmd+` ``** (macOS): a drop-down terminal you show
  and hide from any app. It keeps its session between toggles, and its
  animation is off so it appears at once. As a global shortcut it needs
  Accessibility permission (System Settings > Privacy & Security >
  Accessibility), which Ghostty asks for when it loads the config. It also
  takes `` cmd+` `` system-wide, so that key no longer cycles through an app's
  windows. If you use that, change or delete the `keybind` line.

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

## Shell (optional)

The repo doesn't manage your shell. This is the zsh setup I use on macOS; copy
what you want into your own `~/.zshrc`, `~/.zimrc` and `~/.zprofile`.

### zimfw

[zimfw](https://zimfw.sh) (Zim Framework) isn't a plugin itself: it's a zsh
framework and plugin manager, like oh-my-zsh, which it replaced here. It
downloads *modules* (plugins): small zsh scripts that add features like tab
completion, key bindings or a prompt theme. It then compiles them into one
static init file that zsh loads at startup. That's why it starts faster than
oh-my-zsh, which runs its loader logic on every shell start.

To set it up:

1. Back up your config with `cp ~/.zshrc ~/.zshrc.bak`. If you use oh-my-zsh,
   remove its lines from `~/.zshrc`, such as `export ZSH=...`, `ZSH_THEME=...`,
   `plugins=(...)` and `source $ZSH/oh-my-zsh.sh`.
2. Create `~/.zimrc` with the modules. `environment` sets zsh options, `input`
   sets key bindings, `utility` adds aliases and colors for `ls`, `grep` and
   `less`, and `completion` sets up tab completion. Keep `completion` last,
   after the modules that add completions.

   ```
   zmodule environment
   zmodule input
   zmodule utility
   zmodule sindresorhus/pure --source async.zsh --source pure.zsh
   zmodule completion
   ```

3. Add this to `~/.zshrc`. The last part is zimfw's install block: it downloads
   zimfw if it's missing, rebuilds the init file when `~/.zimrc` changes, and
   loads it. Put your own aliases after it, so they win over the `utility`
   module's (`ll`, `lt`, ...).

   ```
   # Set editor default keymap to emacs (`-e`) or vi (`-v`)
   bindkey -e

   # pure: don't run `git fetch` in the background
   PURE_GIT_PULL=0

   ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
   # Download zimfw plugin manager if missing.
   if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
     curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
         https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
   fi
   # Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
   if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
     source ${ZIM_HOME}/zimfw.zsh init
   fi
   # Initialize modules.
   source ${ZIM_HOME}/init.zsh
   ```

4. Open a new terminal. The first start downloads zimfw and the modules.
   `zimfw update` updates the modules, and `zimfw upgrade` updates zimfw itself.

### Prompt: pure

[pure](https://github.com/sindresorhus/pure) is a prompt (theme) plugin, which
zimfw installs like any other module. It gets git status in a background
worker, so the prompt never waits for git. zimfw's own themes, such as
asciiship, run git before drawing the prompt. In my measurements, each Enter
inside a git repo cost ~35 ms with asciiship and ~1 ms with pure.

`PURE_GIT_PULL=0` stops pure from running `git fetch` in the background to check
the remote for new commits. Delete it to turn that back on. Other options are in
[pure's README](https://github.com/sindresorhus/pure#options).

### Homebrew

`eval "$(/opt/homebrew/bin/brew shellenv)"` in `~/.zprofile` works, but:

- It runs brew on every login shell (~14 ms).
- It adds Homebrew's completions to `fpath` from `~/.zprofile`, which only
  login shells read. Login and non-login shells (Neovim's `:terminal`, a plain
  `zsh`, shells that editors or AI tools start) then get different `fpath`s,
  and zimfw rebuilds its completion cache (~200 ms) whenever the two kinds
  alternate.

The faster way is to write out the lines `brew shellenv` prints, and add
Homebrew's completions in `~/.zshrc` instead. The prefix is `/opt/homebrew` on
Apple Silicon and `/usr/local` on Intel, so use your own output and prefix,
not someone else's.

1. Print your `brew shellenv` lines, minus the two that set `fpath`
   (`fpath[1,0]=".../share/zsh/site-functions"` and `export FPATH`). On Intel,
   use `/usr/local/bin/brew`:

   ```
   PATH=/usr/bin:/bin /opt/homebrew/bin/brew shellenv zsh | grep -v -e '^fpath' -e '^export FPATH'
   ```

   The plain `PATH` is there because `brew shellenv` prints nothing when
   Homebrew is already first on `PATH`. Replace the `eval` line in
   `~/.zprofile` with the output.
2. Add this to `~/.zshrc`, before the zimfw block. On Intel, use
   `/usr/local/share/zsh/site-functions`.

   ```
   # Keep PATH and fpath free of duplicates
   typeset -U path PATH fpath
   # Homebrew's completions, for every zsh, login or not
   fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
   ```

If Homebrew moves or `brew shellenv` changes what it prints, redo step 1.

### Coming from oh-my-zsh

A few things work differently after the switch:

- `>` won't overwrite an existing file (`NO_CLOBBER`). Use `>|` to overwrite.
- `^`, `#` and `~` are glob operators (`EXTENDED_GLOB`), so quote things like
  `HEAD^`: `git show 'HEAD^'`.
- The up arrow steps through all of history, not only the commands that start
  with what you've typed.
- oh-my-zsh's git aliases are gone, so define the ones you use.
- Reload with `exec zsh`, not `source ~/.zshrc`. Sourcing it again runs
  `compinit` again, and zimfw prints a warning.

### Startup time

On my Mac (Apple Silicon, zsh 5.9, Ghostty 1.4.0), the time from opening a
Ghostty window to the prompt went from ~110 ms with oh-my-zsh to ~77 ms with
this setup. With an empty zsh config it's ~47 ms, most of it macOS's
`login(1)`.

To see where your own startup goes, put `zmodload zsh/zprof` at the top of
`~/.zshrc` and `zprof` at the bottom, then open a new shell. Setup for tools
like nvm, conda or pyenv is common and often slower than oh-my-zsh itself, so
measure before switching frameworks.
