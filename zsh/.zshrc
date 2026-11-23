typeset -U path fpath

path=($HOME/.local/bin(N) $path)

# Must be on fpath before zimfw runs compinit.
[[ -n $HOMEBREW_PREFIX ]] && fpath=($HOMEBREW_PREFIX/share/zsh/site-functions(N) $fpath)

bindkey -e

PURE_GIT_PULL=0

ZIM_HOME=${ZDOTDIR:-$HOME}/.zim
if [[ ! -e $ZIM_HOME/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o $ZIM_HOME/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! $ZIM_HOME/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-$HOME}/.zimrc} ]]; then
  source $ZIM_HOME/zimfw.zsh init
fi
source $ZIM_HOME/init.zsh

# zimfw's input module makes Page Up/Down walk history. Ghostty can't scroll on
# them at the prompt and still pass them to programs like Neovim (ghostty#9901),
# so at the prompt zsh asks Ghostty to scroll. Ghostty jumps to the bottom on
# every key it passes on, so count the presses in a row and scroll that far.
if [[ $TERM_PROGRAM == ghostty && $OSTYPE == darwin* ]]; then
  typeset -gi _ghostty_pages=0
  _ghostty_scroll() {
    if [[ $LASTWIDGET == ghostty-page-* ]]; then
      (( _ghostty_pages = _ghostty_pages + $1 < 0 ? 0 : _ghostty_pages + $1 ))
    else
      (( _ghostty_pages = $1 > 0 ? 1 : 0 ))
    fi
    (( _ghostty_pages )) || return 0
    osascript -e "tell application \"Ghostty\" to perform action \"scroll_page_fractional:-$_ghostty_pages\" on (first terminal whose tty is \"$TTY\")" </dev/null &>/dev/null &!
  }
  ghostty-page-up() { _ghostty_scroll 1 }
  ghostty-page-down() { _ghostty_scroll -1 }
  zle -N ghostty-page-up
  zle -N ghostty-page-down
  bindkey $key_info[PageUp] ghostty-page-up
  bindkey $key_info[PageDown] ghostty-page-down
else
  bindkey $key_info[PageUp] redisplay
  bindkey $key_info[PageDown] redisplay
fi

[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
