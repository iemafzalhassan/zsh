# ~/.plugins.zsh — zsh plugin management without a third-party manager.
# Plugins are cloned into ~/.config/zsh/plugins/ on first launch.
# Update with: zplugin-update

ZPLUGINDIR="$XDG_CONFIG_HOME/zsh/plugins"

_zplugin_load() {
  local plugin_path="$ZPLUGINDIR/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    print -P "%F{yellow}installing%f ${2}..."
    git clone --depth=1 --quiet "https://github.com/${1}/${2}.git" "$plugin_path" \
      || { print -P "%F{red}failed%f to install ${2}" >&2; return 1 }
  fi
  source "${plugin_path}/${2}.plugin.zsh" 2>/dev/null \
    || source "${plugin_path}/${2}.zsh" 2>/dev/null \
    || source "${plugin_path}/init.zsh" 2>/dev/null \
    || print -P "%F{red}could not source%f ${2}"
}

# Update all installed plugins
zplugin-update() {
  emulate -L zsh
  local dir
  if [[ ! -d "$ZPLUGINDIR" ]]; then
    print -P "%F{red}no plugins installed%f at $ZPLUGINDIR"
    return 1
  fi
  for dir in "$ZPLUGINDIR"/*(/N); do
    print -P "%F{cyan}updating%f ${dir:t}..."
    git -C "$dir" pull --ff-only --quiet \
      && print -P "  %F{green}ok%f" \
      || print -P "  %F{red}failed%f"
  done
}

# List installed plugins
zplugin-list() {
  emulate -L zsh
  if [[ -d "$ZPLUGINDIR" ]]; then
    print -l "$ZPLUGINDIR"/*(/N:t)
  fi
}

# Core plugins — load in this order (some depend on others)
_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load zdharma-continuum fast-syntax-highlighting
