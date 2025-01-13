# zsh-customs <!-- omit in toc -->

---

- [Layout](#layout)
- [Usage](#usage)

Handle easily multiple ZSH_CUSTOM projects at once.

## Layout

The minimal layout for a ZSH_CUSTOM project with `zsh-customs` is:

├── custom
│   ├── plugins (Oh My Zsh custom plugins)
│   ├── themes (Oh My Zsh custom themes)
│   └── example.zsh (additional .zsh file to be sourced by Oh My Zsh on startup)
├── .user.zshrc (custom zshrc to source for the current project)
├── .zshrc (optional, since it's the above file that's sourced)
└── install.sh (optional with +x rights, will be run when cloned)

When using `zsh-customs`, make sure to not setup `ZSH_CUSTOM` directly like `ZSH_CUSTOM="path/to/custom/zsh"` 
but with the appropriate shell instruction: `: "${ZSH_CUSTOM:="path/to/custom/zsh}"`.

By doing that, it won't break your project when using it without `zsh-customs` but will let `ZSH_CUSTOM` to default when using it 😉.

## Usage

In any terminal (SSH or HTTPS depending on your needs), of course, clone can be made anywhere:

```sh
git clone --recurse-submodules git@github.com:kilianpaquier/zsh-customs.git "$HOME/.zsh-customs"
"$HOME/.zsh-customs/install.sh"
```

```sh
git clone --recurse-submodules https://github.com/kilianpaquier/dotfiles.git "$HOME/.zsh-customs"
"$HOME/.zsh-customs/install.sh"
```

Input variable `DOTFILES` can be given on the first run if wanted, however, not giving it won't exit in error.
After the first run, a file `.env` is written with either an empty list `DOTFILES=""` or the one that was given in input.

Example:

```sh
DOTFILES="git@github.com:kilianpaquier/zsh-customs.git" \
  "$HOME/.zsh-customs/install.sh"
```