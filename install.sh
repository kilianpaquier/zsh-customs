#!/bin/sh

log() {
  echo "$1"
}

log_success() {
  fg="\033[0;32m"
  reset="\033[0m"
  echo "${fg}$1${reset}"
}

log_info() {
  fg="\033[0;34m"
  reset="\033[0m"
  echo "${fg}$1${reset}"
}

log_warn() {
  fg="\033[0;33m"
  reset="\033[0m"
  echo "${fg}$1${reset}" >&2
}

log_error() {
  fg="\033[0;31m"
  reset="\033[0m"
  echo "${fg}$1${reset}" >&2
}

has() {
  which "$1" >/dev/null 2>&1
}

download() {
  if has curl; then curl -fsSL "$1"; else wget -qO- "$1"; fi
}

set -e
dir="$(realpath "$(dirname "$0")")"

##############################################
# Updating zsh-customs
##############################################

log_info "Updating zsh-customs ..."
(
  cd "$dir" || exit 1
  if [ "$(git status --porcelain | wc -l)" = "0" ]; then git pull; else log_warn "Changes detected in $(pwd) not pulling zsh-customs ..."; fi
)

##############################################
# Set up Z4H
##############################################

if [ -n "$Z4H" ]; then
  download https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install | sh
fi

##############################################
# Set up default .env file and source it
##############################################

# shellcheck disable=SC1091
[ -f "$dir/.env" ] && . "$dir/.env"

log_success "Using following dotfiles configuration:"
log "DOTFILES=$DOTFILES"

if [ -z "$DOTFILES" ]; then
  log_warn "Empty dotfiles, skipping installation, please provide your dotfiles path (local) in .env file"
  exit
fi

##############################################
# Iterate over $DOTFILES (defined in .env)
# and run installation script
# and then run customs links sync
##############################################

custom="$dir/custom"
mkdir -p "$custom" "$custom/plugins" "$custom/themes"
# shellcheck disable=SC2154
for dotfile in $DOTFILES; do
  dotfile_name="$(basename "$dotfile")"
  log_info "Setting up $dotfile_name custom ..."

  if [ ! -d "$dotfile" ]; then
    log_warn "$dotfile_name provided dir $dotfile isn't a directory"
    continue
  fi

  # run installation script
  [ -x "$dotfile/install.sh" ] && "$dotfile/install.sh"

  # setup temporary .env.zsh
  [ ! -f "$dir/.env.zsh" ] && [ -f "$dotfile/.env.zsh" ] && cat < "$dotfile/.env.zsh" >> "$dir/temp.env.zsh"

  # create symbolic links between dotfile custom and global dir custom
  if [ -d "$dotfile/custom" ]; then
    log_info "Creating symbolic links for $dotfile_name ..."
    for item in "$dotfile/custom"/*; do
      # handle symbolic links between subdirs
      if [ -d "$item" ]; then
        for subitem in "$item"/*; do
          target="$custom/$(basename "$item")/$(basename "$subitem")"
          log "Setting up $subitem symbolic link with $target ..."
          { [ -L "$target" ] && [ -e "$target" ]; } || ln -sf "$subitem" "$target"
        done
      fi

      # handle symbolic links between files
      if [ -f "$item" ]; then
        target="$custom/$(basename "$item")"
        log "Setting up $item symbolic link with $target ..."
        { [ -L "$target" ] && [ -e "$target" ]; } || ln -sf "$item" "$custom/$(basename "$item")"
      fi
    done
  fi

  log_success "Ended $dotfile_name setup ..."
done

##############################################
# Set up default .env.zsh file and source it
##############################################

if [ -f "$dir/temp.env.zsh" ]; then
  mv "$dir/temp.env.zsh" "$dir/.env.zsh"
else
cat << 'EOF' > "$dir/.env.zsh"
# some more ls aliases
alias ll='ls -l'
alias lla='ls -lart'
alias l='ls -CF'

alias k="kubectl"

read zenv < <(readlink -f "$0")
read dir < <(dirname "$zenv")
EOF
fi
ln -sf "$dir/.env.zsh" "$HOME/.env.zsh"

log_success "Installation done, close your terminal and reload it with zsh"
unset custom
unset dir