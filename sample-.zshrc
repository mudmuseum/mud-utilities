alias ll='ls -lasthG'

export COLORLIST=(21 22 57 94 165 166)
export COLORSCHEME=$((RANDOM % 6 + 1))
export COLORSET=${COLORLIST[$COLORSCHEME]}
export PS1="[ %F{$((COLORSET))}%n%f ] %F{$((COLORSET + 6))}%w - %t %f| %F{$((COLORSET + 12))}%d%f |%F{$((COLORSET + 18))} MBP %f| (%F{$((COLORSET + 24))}%h%f) > "

### Utility Aliases

alias history="history -f 0"
alias find="noglob find"

### Reference Document Aliases

alias iterm2help="echo 'New Tab: cmd + t
Vertical Pane Split: cmd + d
Horizontal Pane Split: cmd + shift + d
Tab Backward: cmd + shift + [  OR cmd + left-arrow
Tab Forward: cmd + shift + ]  OR cmd + right-arrow
Swap to Tab #: cmd + #
Swap to Pane: cmd + option + left/right-arrow'"

HISTSIZE=999999999
HISTTIMEFORMAT="%F %T "

PATH=${PATH}:/usr/local/bin
