#!/usr/bin/env bash
# install.sh — unified zsh+nvim+tmux+git dotfiles installer.
# Run from the dotfiles repo root: ./install.sh
# Or fetch and run via: curl -fsSL https://raw.githubusercontent.com/iemafzalhassan/zsh/main/bootstrap.sh | bash

set -euo pipefail

# =========================================================
# Paths & config
# =========================================================
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
LOG_PREFIX="[zsh-dotfiles]"

# Tweakable defaults
: "${REPO_URL:=https://github.com/iemafzalhassan/zsh.git}"
: "${TARGET_DIR:=$HOME/Developer/Projects/zsh}"
: "${CHANGE_SHELL:=true}"
: "${INSTALL_ATUIN:=true}"
: "${INSTALL_STARSHIP:=true}"
: "${INSTALL_TPM:=true}"
: "${PROMPT_FOR_GIT_IDENTITY:=true}"

# =========================================================
# Helpers
# =========================================================
log()  { printf "%b\n" "$LOG_PREFIX $*"; }
warn() { printf "%b\n" "$LOG_PREFIX \033[33mwarn:\033[0m $*" >&2; }
err()  { printf "%b\n" "$LOG_PREFIX \033[31merror:\033[0m $*" >&2; }
ask()  {
  local prompt="$1" default="${2:-n}" reply
  read -r -p "$(printf '%b' "$LOG_PREFIX $prompt [$default/Y/n] ")" reply || true
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

confirm() {
  local reply
  read -r -p "$(printf '%b' "$LOG_PREFIX $* [y/N] ")" reply || true
  [[ "$reply" =~ ^[Yy]$ ]]
}

require() {
  command -v "$1" >/dev/null 2>&1 || { err "required: $1"; return 1; }
}

backup() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/$(basename "$target")"
    log "backed up $target -> $BACKUP_DIR/"
  elif [[ -L "$target" ]]; then
    rm -f "$target"
  fi
}

symlink() {
  local src="$1" dst="$2"
  if [[ ! -e "$src" ]]; then
    err "symlink source missing: $src"
    return 1
  fi
  backup "$dst"
  ln -s "$src" "$dst"
  log "linked $dst -> $src"
}

# =========================================================
# OS + package manager detection
# =========================================================
detect_os() {
  if   [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case "$ID" in
      ubuntu|debian|pop|linuxmint|elementary) OS="debian" ;;
      arch|manjaro|endeavouros|artix|cachyos) OS="arch" ;;
      fedora|rhel|centos|rocky|almalinux|nobara) OS="rhel" ;;
      opensuse*|sles) OS="suse" ;;
      alpine) OS="alpine" ;;
      *) OS="linux-unknown" ;;
    esac
  else
    OS="unknown"
  fi
  log "detected OS: $OS"
}

pkg_install() {
  case "$OS" in
    macos)
      require brew || { err "install Homebrew first: https://brew.sh"; return 1; }
      brew install "$@"
      ;;
    debian)
      sudo apt-get update
      sudo apt-get install -y "$@"
      ;;
    arch)
      sudo pacman -Syu --noconfirm "$@"
      ;;
    rhel)
      sudo dnf install -y "$@"
      ;;
    suse)
      sudo zypper install -y "$@"
      ;;
    alpine)
      sudo apk add "$@"
      ;;
    *)
      err "unknown OS — install packages manually: $*"
      return 1
      ;;
  esac
}

# =========================================================
# Install system packages
# =========================================================
install_packages() {
  log "installing system packages..."

  case "$OS" in
    macos)
      # All tools via brew
      brew install \
        zsh neovim eza bat fd fzf zoxide starship ripgrep git \
        lazygit lazydocker jq yq gum tree-sitter-cli stylua
      if $INSTALL_ATUIN; then brew install atuin; fi
      ;;
    debian)
      pkg_install zsh neovim ripgrep fd-find fzf bat git curl wget
      # eza, zoxide, starship, atuin, lazygit, lazydocker — not in apt
      install_via_curl "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh" "zoxide"
      install_via_curl "https://starship.rs/install.sh" "starship" -y
      if $INSTALL_ATUIN; then install_via_curl "https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh" "atuin"; fi
      install_via_github_release jesseduffield/lazygit lazygit
      install_via_github_release jesseduffield/lazydocker lazydocker
      # eza: GitHub release
      install_via_github_release eza-community/eza eza
      ;;
    arch)
      pkg_install zsh neovim eza bat fd fzf zoxide starship ripgrep git \
        lazygit lazydocker jq gum tree-sitter-cli stylua
      if $INSTALL_ATUIN; then pkg_install atuin; fi
      ;;
    rhel)
      pkg_install zsh neovim ripgrep fd-find fzf bat git curl wget
      # dnf-EPEL may be needed for some; if dnf fails, try fallback names
      install_via_curl "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh" "zoxide"
      install_via_curl "https://starship.rs/install.sh" "starship" -y
      if $INSTALL_ATUIN; then install_via_curl "https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh" "atuin"; fi
      install_via_github_release jesseduffield/lazygit lazygit
      install_via_github_release jesseduffield/lazydocker lazydocker
      install_via_github_release eza-community/eza eza
      ;;
    suse)
      pkg_install zsh neovim ripgrep fd fzf bat git curl wget
      install_via_curl "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh" "zoxide"
      install_via_curl "https://starship.rs/install.sh" "starship" -y
      if $INSTALL_ATUIN; then install_via_curl "https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh" "atuin"; fi
      ;;
    alpine)
      pkg_install zsh neovim ripgrep fd fzf bat git curl wget sudo bash
      install_via_curl "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh" "zoxide"
      install_via_curl "https://starship.rs/install.sh" "starship" -y
      if $INSTALL_ATUIN; then install_via_curl "https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh" "atuin"; fi
      install_via_github_release eza-community/eza eza
      ;;
    *)
      warn "could not auto-install packages for $OS"
      warn "please install manually: zsh neovim eza bat fd fzf zoxide starship ripgrep git"
      ;;
  esac
}

install_via_curl() {
  local url="$1" name="$2"; shift 2
  log "installing $name via curl..."
  local script
  script="$(mktemp)"
  if ! curl -fsSL "$url" -o "$script"; then
    warn "failed to download $url"
    rm -f "$script"
    return 1
  fi
  # Run with sh — most installer scripts are POSIX sh and some (e.g. starship)
  # explicitly refuse to run under bash.
  if sh "$script" "$@"; then
    rm -f "$script"
  else
    warn "$name installer exited non-zero — continuing anyway"
    rm -f "$script"
    return 0
  fi
}

install_via_github_release() {
  local repo="$1" name="$2"
  log "downloading $name from GitHub releases..."
  local url
  url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | grep -oE '"browser_download_url":\s*"[^"]*linux[^"]*amd64[^"]*tar\.gz"' \
    | head -n1 | sed 's/.*"//;s/"$//')
  if [[ -z "$url" ]]; then
    warn "no linux/amd64 release found for $name — skipping"
    return 0
  fi
  local tmp
  tmp=$(mktemp -d)
  curl -fsSL "$url" -o "$tmp/$name.tar.gz"
  tar -xzf "$tmp/$name.tar.gz" -C "$tmp"
  install -m 755 "$(find "$tmp" -type f -name "$name" -executable | head -n1)" \
    "$HOME/.local/bin/$name"
  rm -rf "$tmp"
}

# =========================================================
# Linux-only shims (Debian/Ubuntu split-package names)
# =========================================================
fix_linux_alt_names() {
  if [[ "$OS" == "macos" || "$OS" == "arch" || "$OS" == "suse" ]]; then
    return 0
  fi
  mkdir -p "$HOME/.local/bin"
  if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    log "linked bat -> batcat (Debian split package)"
  fi
  if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    log "linked fd -> fdfind (Debian split package)"
  fi
}

# =========================================================
# Symlink dotfiles into $HOME
# =========================================================
link_dotfiles() {
  log "linking dotfiles into $HOME..."

  # zsh modules — symlinked as ~/.zshrc, ~/.aliases.zsh, etc.
  local zsh_files=(zshrc zshenv aliases.zsh bindings.zsh fzf.zsh plugins.zsh prompt.zsh)
  for f in "${zsh_files[@]}"; do
    symlink "$DOTFILES_DIR/.$f" "$HOME/.$f"
  done

  # starship config
  mkdir -p "$XDG_CONFIG_HOME"
  [[ -z "${XDG_CONFIG_HOME:-}" ]] && XDG_CONFIG_HOME="$HOME/.config"
  export XDG_CONFIG_HOME
  mkdir -p "$XDG_CONFIG_HOME"
  symlink "$DOTFILES_DIR/starship.toml" "$XDG_CONFIG_HOME/starship.toml"

  # gitconfig
  if [[ -f "$DOTFILES_DIR/git/.gitconfig" ]]; then
    symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
  fi

  # tmux
  if [[ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]]; then
    symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  fi

  # nvim
  if [[ -d "$DOTFILES_DIR/nvim/.config/nvim" ]]; then
    symlink "$DOTFILES_DIR/nvim/.config/nvim" "$XDG_CONFIG_HOME/nvim"
    log "linked nvim config -> $XDG_CONFIG_HOME/nvim"
  fi
}

# =========================================================
# TPM (Tmux Plugin Manager) install
# =========================================================
install_tpm() {
  if ! $INSTALL_TPM; then return 0; fi
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    log "tpm already installed"
    return 0
  fi
  log "installing TPM..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm \
    "$HOME/.tmux/plugins/tpm"
}

# =========================================================
# Git identity
# =========================================================
configure_git_identity() {
  $PROMPT_FOR_GIT_IDENTITY || return 0
  if git config --global user.name >/dev/null && git config --global user.email >/dev/null; then
    log "git identity already set: $(git config --global user.name) <$(git config --global user.email)>"
    return 0
  fi
  local name email
  read -r -p "$(printf '%b' "$LOG_PREFIX git user.name: ")" name
  read -r -p "$(printf '%b' "$LOG_PREFIX git user.email: ")" email
  if [[ -n "$name" && -n "$email" ]]; then
    git config --global user.name "$name"
    git config --global user.email "$email"
    log "git identity configured: $name <$email>"
  else
    warn "skipped git identity (set later with: git config --global user.{name,email})"
  fi
}

# =========================================================
# Change default shell to zsh
# =========================================================
change_shell() {
  $CHANGE_SHELL || return 0
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    warn "zsh not found — skipping chsh"
    return 0
  fi
  if grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    :
  else
    log "adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" == "$zsh_path" ]]; then
    log "default shell already zsh"
    return 0
  fi
  log "changing default shell to $zsh_path (will prompt for password)"
  chsh -s "$zsh_path" || warn "chsh failed — run it manually"
}

# =========================================================
# Create required state directories
# =========================================================
make_state_dirs() {
  mkdir -p "$HOME/.local/state/zsh" \
           "$HOME/.cache/zsh" \
           "$XDG_CONFIG_HOME/zsh/plugins" \
           "$HOME/.local/bin" \
           "$HOME/.config"
}

# =========================================================
# Main
# =========================================================
main() {
  echo
  log "unified zsh+nvim+tmux+git dotfiles installer"
  log "dotfiles dir: $DOTFILES_DIR"
  echo

  detect_os
  install_packages
  fix_linux_alt_names
  make_state_dirs
  install_tpm
  link_dotfiles
  configure_git_identity
  change_shell

  echo
  log "✔ install complete"
  log "next:"
  log "  - relogin (so the new default shell takes effect)"
  log "  - open tmux and press Prefix + I to install tmux plugins"
  log "  - open nvim once (Lazy.nvim will auto-install plugins on first launch)"
  log "  - starship: should work immediately"
  log "  - atuin: run 'atuin register' then 'atuin login' if you want sync"
  echo
  log "any issues? read README.md or open an issue on $REPO_URL"
}

main "$@"
