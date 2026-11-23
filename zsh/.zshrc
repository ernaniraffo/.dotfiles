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

# Page Up/Down: scroll Ghostty at the prompt, reach Neovim etc. (ghostty#9901).
# Ghostty jumps to the bottom on each key, so count presses in a row.
_ghostty_page() {
  [[ $LASTWIDGET == ghostty-page-* ]] || _gp=0
  [[ $WIDGET == *up ]] && (( ++_gp )) || (( _gp && _gp-- ))
  [[ $TERM_PROGRAM == ghostty ]] && (( _gp )) && osascript -e "tell application \"Ghostty\" to perform action \"scroll_page_fractional:-$_gp\" on (first terminal whose tty is \"$TTY\")" &>/dev/null </dev/null &!
}
zle -N ghostty-page-up _ghostty_page && bindkey $key_info[PageUp] ghostty-page-up
zle -N ghostty-page-down _ghostty_page && bindkey $key_info[PageDown] ghostty-page-down

[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
