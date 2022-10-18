# Terminal colors
export PROMPT="%F{magenta}%n%f:%1~ $ "
export CLICOLOR=1

# python aliases
alias python='python3'

# cd aliases
alias cse111='cd ~/Desktop/school/fall22/cse111/'
alias school='cd ~/Desktop/school/'

# diff aliases
alias diff='colordiff'

# ls aliases
alias ll="ls -l"
alias lo="ls -lo"
alias lt="ls -lt"
alias la="ls -a"

# VIM aliases
alias vim='nvim'
alias vi='nvim'
alias init.vim="vi ~/.dotfiles/nvim/.config/nvim/init.vim"

# Docker aliases
alias ds='docker start -ai cse111'
alias do='open -a docker'

# Added by Amplify CLI binary installer
export PATH="$HOME/.amplify/bin:$PATH"
