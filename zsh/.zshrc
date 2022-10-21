# Terminal colors
export PROMPT="%F{magenta}%n%f:%1~ $ "
export CLICOLOR=1

# zsh aliases
alias zshrc='vi ~/.zshrc'

# python aliases
alias python='python3'

# cd aliases
alias cs='cd ~/Desktop/school/fall22/cse111/'
alias cmpm='cd ~/Desktop/school/fall22/cmpm176'
alias ge='cd ~/Desktop/school/fall22/socy15'
alias ucsc='cd ~/Desktop/school/'

# diff aliases
alias diff='colordiff'

# ls aliases
alias ll="ls -l"
alias lo="ls -lo"
alias lt="ls -lt"
alias la="ls -al"

# VIM aliases
alias vim='nvim'
alias vi='nvim'
alias init.vim="vi ~/.dotfiles/nvim/.config/nvim/init.vim"

# Docker aliases
alias ds='docker start -ai cse111'
alias do='open -a docker'

# Added by Amplify CLI binary installer
export PATH="$HOME/.amplify/bin:$PATH"
