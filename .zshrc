source /usr/share/zsh/share/antigen.zsh

antigen use oh-my-zsh
antigen bundles <<EOBUNDLES
archlinux
chucknorris
colored-man-pages
colorize
command-not-found
last-working-dir
git
tmux
EOBUNDLES
antigen theme afowler
antigen apply

alias | grep chuck_cow &>/dev/null && chuck_cow
