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
# Set up default .env file and source it
##############################################

if [ -n "$DOTFILES" ]; then
  echo "DOTFILES=\"$DOTFILES\"" > "$dir/.env"
elif [ ! -f "$dir/.env" ]; then
  log_info "Setting up default zsh-customs config in $dir/.env ..."
  cp "$dir/default.env" "$dir/.env"
fi
log_success "Using following zsh-customs configuration:"
log "$(cat "$dir/.env")"
# shellcheck disable=SC1091
. "$dir/.env"

##############################################
# Set up Oh My Zsh
##############################################

ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

if [ ! -d "$ZSH" ]; then
  log_info "Installing oh-my-zsh ..."
  download https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | ZSH="$ZSH" sh
fi

##############################################
# Iterate over $DOTFILES (defined in .env)
# and run installation script
# and then run customs links sync
##############################################

mkdir -p "$dir/customs"
# shellcheck disable=SC2154
for dotfile in $DOTFILES; do
  dotfile_name="$(basename "$dotfile" .git)"
  dotfile_dir="$dir/customs/$dotfile_name"
  log_info "Setting up $dotfile_name custom ..."

  (
    [ -d "$dotfile_dir" ] || git submodule add "$dotfile" "$dotfile_dir"

    [ -x "$dotfile_dir/install.sh" ] && "$dotfile_dir/install.sh"

    if [ -d "$dotfile_dir/custom" ]; then
      log_info "Creating symbolic links for $dotfile_name ..."
      for item in "$dotfile_dir/custom"/*; do
        # handle symbolic links between subdirs
        if [ -d "$item" ]; then
          for subitem in "$item"/*; do
            target="$ZSH_CUSTOM/$(basename "$item")/$(basename "$subitem")"
            log "Setting up $subitem symbolic link with $target ..."
            { [ -L "$target" ] && [ -e "$target" ]; } || ln -sf "$subitem" "$target"
          done
        fi

        # handle symbolic links between files
        if [ -f "$item" ]; then
          target="$ZSH_CUSTOM/$(basename "$item")"
          log "Setting up $item symbolic link with $target ..."
          { [ -L "$target" ] && [ -e "$target" ]; } || ln -sf "$item" "$ZSH_CUSTOM/$(basename "$item")"
        fi
      done
    fi
  )

  log_success "Ended $dotfile_name setup ..."
done

##############################################
# Override any symbolic link with .zshrc
# made by a dotfile
##############################################

log_info "Setting up .zshrc symbolic link ..."
ln -sf "$dir/.zshrc" "$HOME/.zshrc"

log_success "Installation done, close your terminal and reload it or run 'omz reload'"