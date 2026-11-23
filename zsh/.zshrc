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

# Ghostty scrolls on Page Up/Down; stop zimfw's input module from also
# stepping through history on them.
bindkey $key_info[PageUp] redisplay
bindkey $key_info[PageDown] redisplay

[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
