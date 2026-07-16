# zsh — unified dotfiles

[![GitHub stars](https://img.shields.io/github/stars/iemafzalhassan/zsh?style=flat-square)](https://github.com/iemafzalhassan/zsh/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/iemafzalhassan/zsh?style=flat-square)](https://github.com/iemafzalhassan/zsh/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

One command on a fresh machine, relogin, done. Same zsh + nvim + tmux + git
on macOS, Ubuntu/Debian, Arch, RHEL/Fedora, openSUSE, and Alpine.

## ✨ What you get

- **Shell:** `zsh` with emacs line editing, fzf, zoxide, autosuggestions, fast-syntax-highlighting, history-substring-search.
- **Prompt:** Starship prompt in Catppuccin Mocha.
- **Editor:** Neovim with Lazy.nvim (LSP, Treesitter, Telescope, Neo-tree, gitsigns, autopairs, conform).
- **Multiplexer:** Tmux with TPM and Catppuccin theme (C-a prefix, vim nav).
- **Git:** configured with delta, sensible defaults, and per-machine identity.
- **Modern CLI:** `eza`, `bat`, `fd`, `ripgrep`, `lazygit`, `lazydocker`.
- **DevOps Ready:** Auto-installs `kubectl`, `helm`, `terraform`, and `multipass`.

## Install (Fresh Machine)

```sh
curl -fsSL https://raw.githubusercontent.com/iemafzalhassan/zsh/main/bootstrap.sh | bash
```

Then:

1. **Log out of your session and log back in** (so the new default shell
   kicks in). SSH: `exit` then `ssh back in`. Desktop: sign out → sign in.
   Opening a new terminal is NOT enough — it inherits the old shell.
2. Confirm you're in zsh: `echo $SHELL` should end in `/zsh`. If it
   doesn't, run `exec $(which zsh)` to switch the current session
   immediately.
3. Open tmux → `Prefix + I` (C-a, then I) to install tmux plugins
4. Open nvim once — Lazy.nvim auto-installs plugins on first launch

## Install (from a local clone)

```sh
git clone https://github.com/iemafzalhassan/zsh ~/Developer/Projects/zsh
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
starship installs via their official curl scripts.

### Arch / Manjaro / CachyOS / EndeavourOS
Everything's in the official repos, including eza, zoxide, starship,
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

## 🍴 Fork & Use as a Base

Want to use this setup as your own base? It's highly encouraged! 
1. **Fork** this repository.
2. Edit `bootstrap.sh` and change the `REPO_URL` and `REPO_RAW_URL` to point to your new GitHub username.
3. Edit `install.sh` and update `REPO_URL` to your fork.
4. Tweak `aliases.zsh`, `install.sh` tools, and `starship.toml` to your own liking.
5. You now have your own one-command bootstrap dotfiles!

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

## Troubleshooting

**`zsh: command not found: eza` after install**
Your shell PATH doesn't include `~/.local/bin`. Open a fresh login shell or
`source ~/.zshrc`.

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
