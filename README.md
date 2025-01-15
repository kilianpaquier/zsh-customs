# zsh-customs <!-- omit in toc -->

---

- [Layout](#layout)
- [Usage](#usage)

Handle easily multiple ZSH_CUSTOM projects at once.

## Layout

The minimal layout for a ZSH_CUSTOM project with `zsh-customs` is:

```tree
├── custom
│   ├── plugins (Oh My Zsh custom plugins)
│   ├── themes (Oh My Zsh custom themes)
│   └── example.zsh (additional .zsh file to be sourced by Oh My Zsh on startup)
├── .env.zsh (custom zshrc to source for the current project)
└── install.sh (optional with +x rights, will be run when cloned)
```

## Usage

In any terminal (SSH or HTTPS depending on your needs), of course, clone can be made anywhere:

```sh
git clone --recurse-submodules git@github.com:kilianpaquier/zsh-customs.git "$HOME/.zsh-customs"
echo "DOTFILES=\"path/to/local/dotfile/directory path/to/another/local/dotfile/directory\"" > "$HOME/.zsh-customs/.env"
"$HOME/.zsh-customs/install.sh"
```

```sh
git clone --recurse-submodules https://github.com/kilianpaquier/dotfiles.git "$HOME/.zsh-customs"
echo "DOTFILES=\"path/to/local/dotfile/directory path/to/another/local/dotfile/directory\"" > "$HOME/.zsh-customs/.env"
"$HOME/.zsh-customs/install.sh"
```
