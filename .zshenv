# ~/.zshenv — sourced by ALL zsh invocations (login, interactive, scripts)
# Keep this file tiny and side-effect-free. Anything heavy goes in .zshrc.

# ---------- XDG base directories ----------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
# Prefer `bat` (real name) but fall back to `batcat` (Debian/Ubuntu split package)
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
  export BAT_THEME="Catppuccin Mocha"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
  export BAT_THEME="Catppuccin Mocha"
fi
export PAGER="${MANPAGER:-less -F -X}"

# ---------- GPG (for git commit signing) ----------
export GPG_TTY=$(tty)

# ---------- Starship prompt config ----------
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

# ---------- PATH ----------
# Personal scripts and shims (used by install.sh to drop bat->batcat symlinks, etc.)
export PATH="$HOME/.local/bin:$PATH"
