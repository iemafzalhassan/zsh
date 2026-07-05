# zsh — unified dotfiles

One command on a fresh machine, relogin, done. Same zsh + nvim + tmux + git
on macOS, Ubuntu/Debian, Arch, RHEL/Fedora, openSUSE, and Alpine.

## What you get

- **zsh** with emacs line editing (no vi-mode), Atuin history, fzf, zoxide,
  autosuggestions, fast-syntax-highlighting, history-substring-search.
- **Starship** prompt in Catppuccin Mocha.
- **Neovim** with Lazy.nvim — LSP, Treesitter, Catppuccin, Telescope,
  Neo-tree, gitsigns, autopairs, conform, none-ls, Comment.
- **Tmux** with TPM and Catppuccin theme (C-a prefix, vim nav).
- **Git** with delta, sensible defaults, per-machine identity.
- **Modern CLI**: eza, bat, fd, fzf, zoxide, ripgrep, lazygit, lazydocker.

## Install (fresh machine)

```sh
curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/zsh/main/bootstrap.sh | bash
```

Then:

1. Relogin (so the new default shell kicks in)
2. Open tmux → `Prefix + I` (C-a, then I) to install tmux plugins
3. Open nvim once — Lazy.nvim auto-installs plugins on first launch
4. (Optional) `atuin register` then `atuin login` to sync history

## Install (from a local clone)

```sh
git clone https://github.com/YOUR_GITHUB_USERNAME/zsh ~/Developer/Projects/zsh
cd ~/Developer/Projects/zsh
./install.sh
```

## Repository layout

    zsh/
    ├── .zshenv                  # sourced by every zsh (env, paths, EDITOR)
    ├── .zshrc                   # interactive only (modules loaded here)
    ├── aliases.zsh              # ls/cat/git/docker/k8s/tf/python aliases
    ├── bindings.zsh             # emacs keybindings
    ├── fzf.zsh                  # fzf + Catppuccin palette
    ├── plugins.zsh              # plugin manager (no third-party tool)
    ├── prompt.zsh               # starship init
    ├── starship.toml            # Catppuccin Mocha prompt
    ├── nvim/.config/nvim/       # nvim config (Lazy.nvim)
    │   ├── init.lua
    │   ├── lua/options.lua
    │   ├── lua/keymaps.lua
    │   └── lua/plugins/init.lua
    ├── tmux/.tmux.conf          # tmux config (C-a prefix, Catppuccin)
    ├── git/.gitconfig           # git base config
    ├── install.sh               # the actual installer
    ├── bootstrap.sh             # curl-pipeable one-shot wrapper
    └── README.md

## How the symlinks work

`install.sh` links each file/dir from the repo into `$HOME`:

    ~/Developer/Projects/zsh/.zshrc          -> ~/.zshrc
    ~/Developer/Projects/zsh/.zshenv         -> ~/.zshenv
    ~/Developer/Projects/zsh/aliases.zsh     -> ~/.aliases.zsh
    ... (one symlink per module)
    ~/Developer/Projects/zsh/starship.toml   -> ~/.config/starship.toml
    ~/Developer/Projects/zsh/nvim/.config/nvim -> ~/.config/nvim
    ~/Developer/Projects/zsh/tmux/.tmux.conf -> ~/.tmux.conf
    ~/Developer/Projects/zsh/git/.gitconfig  -> ~/.gitconfig

Edit the files in the repo, then `source ~/.zshrc` or relogin.

## Per-distro install notes

### macOS
Needs Homebrew (`https://brew.sh`). All packages via `brew install`.

### Ubuntu / Debian / Pop!_OS
`bat` and `fd` install as `batcat` and `fdfind`. `install.sh` creates
`~/.local/bin/bat` and `~/.local/bin/fd` symlinks for you. eza, zoxide,
starship, atuin install via their official curl scripts.

### Arch / Manjaro / CachyOS / EndeavourOS
Everything's in the official repos, including eza, zoxide, starship, atuin,
lazygit, lazydocker.

### RHEL / Fedora / Rocky / AlmaLinux / Nobara
Same as Debian — most things via curl scripts. Enable EPEL if `fd-find` is
missing in dnf.

### openSUSE / Alpine
Supported via `zypper` and `apk` respectively. Curl scripts fill the gaps.

## Customization

- Edit files in the repo, then `source ~/.zshrc`
- Add a new alias: append to `aliases.zsh`
- Add a new keybinding: append to `bindings.zsh`
- Add a new nvim plugin: edit `nvim/.config/nvim/lua/plugins/init.lua`,
  then `:Lazy sync` inside nvim
- Add a new tmux plugin: append `set -g @plugin '...'` to `tmux/.tmux.conf`,
  then `Prefix + I`

## Plugin management (no third-party tool)

The zsh plugins are cloned into `~/.config/zsh/plugins/` on first shell
launch by `plugins.zsh`. To update them all:

```sh
zplugin-update
```

To list what's installed:

```sh
zplugin-list
```

## Development

After editing any of the zsh modules, validate the install path in a sandbox:

```sh
./test-install.sh
```

This builds a fake `$HOME`, runs the symlink dance, and boots zsh against
the result. It does NOT touch your real `$HOME`.

**`zsh: command not found: eza` after install**
Your shell PATH doesn't include `~/.local/bin`. Open a fresh login shell or
`source ~/.zshrc`.

**Atuin asks for a key on first Ctrl+R**
`atuin register` (creates a new account) or `atuin login` (existing account).
Optional — Ctrl+R still works locally without sync.

**Tmux: `catppuccin/tmux` plugin not loading**
Inside tmux: `Prefix + I` (capital i) to install. Then `Prefix + r` to
reload the config.

**Neovim: `catppuccin/nvim` not active**
`:colorscheme catppuccin-mocha` inside nvim. Lazy will install on first
launch; you may need `:Lazy sync` to force.

**`chsh: Permission denied`**
Run `chsh -s $(which zsh)` manually after adding it to `/etc/shells`:
`echo $(which zsh) | sudo tee -a /etc/shells`.

## Design decisions

- **Emacs keybindings in shell, vim only inside nvim** — per your preference,
  the shell uses `bindkey -e` and `WORDCHARS=''`. No zsh-vi-mode. nvim uses
  vanilla vim keybindings.
- **No third-party plugin manager** — zsh plugins are cloned by a small
  shell function in `plugins.zsh`. One less thing to install.
- **Symlinks, not ZDOTDIR** — files live as `~/.zshrc`, `~/.aliases.zsh`,
  etc., so a quick `cat ~/.zshrc` works for new contributors.
- **Modular zsh config** — `aliases.zsh`, `bindings.zsh`, `fzf.zsh`,
  `plugins.zsh`, `prompt.zsh` are loaded from `.zshrc`. Easy to swap any
  module out.
- **Per-machine git identity** — `install.sh` prompts for `user.name` and
  `user.email` on first run. Override `PROMPT_FOR_GIT_IDENTITY=false` to
  skip.
- **Catppuccin Mocha everywhere** — fzf palette, starship, nvim, tmux, all
  pulled from the same palette.

## License

MIT.
