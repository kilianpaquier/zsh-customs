export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_CUSTOM="$ZSH/custom" # keep default $ZSH_CUSTOM

plugins=()

dir="$(dirname $(readlink -f "$HOME/.zshrc"))"
for custom in "$dir/customs"/*; do source "$custom/.user.zshrc"; done
unset dir

source $ZSH/oh-my-zsh.sh