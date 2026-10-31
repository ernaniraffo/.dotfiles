# To profile startup: uncomment the line below and `zprof` at the bottom.
# zmodload zsh/zprof

# Keep PATH free of duplicates (several installers prepend the same dirs)
typeset -U path PATH

export CLICOLOR=1

# using homebrew llvm
export MallocNanoZone=0

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
path=(
  $HOME/.local/bin
  $HOME/.antigravity-ide/antigravity-ide/bin
  $HOME/.unity/bin            # Unity CLI (was: . ~/.unity/env)
  $path
)

# ---------------------------------------------------------------------------
# chruby
# `chruby ruby-x.y.z` spawns a ruby process on every shell start (~40-60ms).
# Run it once, cache the resulting env, and rebuild the cache only when the
# ruby binary changes. Change RUBY_DEFAULT to switch versions.
# ---------------------------------------------------------------------------
RUBY_DEFAULT=ruby-3.4.1
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh

() {
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/chruby-$RUBY_DEFAULT.zsh
  local ruby_bin=$HOME/.rubies/$RUBY_DEFAULT/bin/ruby
  if [[ ! -s $cache || $ruby_bin -nt $cache ]]; then
    mkdir -p ${cache:h}
    chruby $RUBY_DEFAULT || return
    typeset -p RUBY_ROOT RUBY_ENGINE RUBY_VERSION RUBYOPT GEM_ROOT GEM_HOME GEM_PATH 2>/dev/null >| $cache
  else
    source $cache
    # Same PATH order chruby_use produces
    path=(${GEM_HOME:+$GEM_HOME/bin} ${GEM_ROOT:+$GEM_ROOT/bin} $RUBY_ROOT/bin $path)
  fi
}

# ---------------------------------------------------------------------------
# oh-my-zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="nanotech"
plugins=(git)

# Skip compaudit's permission scan of every fpath dir on each startup
ZSH_DISABLE_COMPFIX=true
# Check for updates without blocking the prompt
zstyle ':omz:update' mode reminder

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------------------------
# Aliases. These are defined after oh-my-zsh so the git plugin can't
# override them (it redefines gc, gcm, ga, gb, gp, ...).
# ---------------------------------------------------------------------------

# python
alias python='python3'

# cd
alias c='cd ~/Documents/code'

# diff
alias diff='colordiff'

# ls
alias ll="ls -l"
alias lo="ls -o"
alias lt="ls -t"
alias la="ls -a"

# vim
alias vim="nvim"
alias vi="nvim"
alias init.vim="vi ~/.dotfiles/nvim/.config/nvim/init.vim"

# zshrc
alias zshrc="vi ~/.zshrc"
alias szshrc="source ~/.zshrc"

# git
alias g="git"
alias ga="git add"
alias gs="git status"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gb="git branch"

# grep
alias grep="grep --color=auto"

# docker
alias ds='docker start elegant_solomon -i'

# zprof
