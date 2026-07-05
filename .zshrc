# ~/.zshrc — interactive zsh config.
# Sourced only for interactive shells. Keep heavy stuff here, not in .zshenv.
#
# Modules are sourced from $ZDOTDIR-style layout, but the actual files are
# symlinked into $HOME so the canonical source-of-truth lives in the dotfiles
# repo. The symlinks are managed by install.sh — do not edit the symlinks,
# edit the files in the repo.

# =========================================================
# Module loader
# =========================================================
# Resolve the absolute path of the dotfiles repo from this file's location,
# so things work whether the repo is at ~/Developer/Projects/zsh, ~/.dotfiles/zsh,
# or anywhere else. Used by `zshconfig`/`reload` and to find the plugin
# loader; safe to fail silently if the repo isn't there.
ZSH_DOTFILES_DIR="${ZSH_DOTFILES_DIR:-$(cd "$(dirname "${(%):-%x}")" 2>/dev/null && pwd)}"
export ZSH_DOTFILES_DIR

# =========================================================
# History (Atuin replaces the default history widget)
# =========================================================
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# =========================================================
# Shell behaviour
# =========================================================
setopt AUTOCD                # typing a dir name cd's into it
setopt NOBEEP                # no bell on tab-ambiguous
setopt NUMERIC_GLOB_SORT     # file10 sorts after file9
setopt INTERACTIVE_COMMENTS # allow # comments in interactive prompts
setopt PROMPT_SUBST         # enable $(...) in prompt strings

# Pure emacs keybindings in the shell. Vim lives inside nvim only.
bindkey -e

# =========================================================
# Completion system
# =========================================================
autoload -Uz compinit

# Per-host cache file, regenerated daily. Faster than always recompiling.
_compdump_file="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
# Ensure cache dir exists
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
if [[ -n "$ZSH_COMPDUMP" ]]; then
    compinit -d "${_compdump_file}" -u
else
    compinit -d "${_compdump_file}"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:git-checkout:*' sort false  # 'git checkout <Tab>' shows branches in order
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh"

# =========================================================
# Load modular config files
# =========================================================
# Each file is small and focused. They live in the dotfiles repo and are
# symlinked into $HOME by install.sh.
for _mod in \
  aliases.zsh \
  bindings.zsh \
  fzf.zsh \
  plugins.zsh \
  prompt.zsh
do
  if [[ -f "$HOME/.${_mod}" ]]; then
    source "$HOME/.${_mod}"
  else
    echo "zsh: missing module ~/.${_mod} (run install.sh)" >&2
  fi
done
unset _mod _compdump_file

# =========================================================
# Tool integrations (post-prompt)
# =========================================================
# direnv per-project env vars (only loaded if installed)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# zoxide (smarter cd) — initialized in aliases/prompt.zsh
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
