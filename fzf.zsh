# ~/.fzf.zsh — fzf configuration
# Works across all distros; uses fd when available, falls back to find.

# ----- Default command -----
if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'
fi

# ----- UI / look (Catppuccin Mocha palette) -----
export FZF_DEFAULT_OPTS="
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt='  '
  --pointer='  '
  --marker='*'
  --info=inline
  --preview-window='right:65%:wrap:border-left'
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"

# Preview command: prefer bat, fall back to cat
if command -v bat >/dev/null 2>&1; then
  _FZF_PREVIEW='bat --color=always --style=numbers --line-range=:500 {}'
elif command -v batcat >/dev/null 2>&1; then
  _FZF_PREVIEW='batcat --color=always --style=numbers --line-range=:500 {}'
else
  _FZF_PREVIEW='cat {}'
fi
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW'"

# Alt-C (cd into a directory)
if command -v eza >/dev/null 2>&1; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {} | head -200'"
fi

# Ctrl-F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  local result
  result=$(eval "${cmd:-find . -type f}" \
           | fzf --preview "$_FZF_PREVIEW") \
    && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# Source fzf's own keybindings / completion depending on where it is installed.
# (The .zshrc also has this fallback; kept here for safety on custom installs.)
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  source /opt/homebrew/opt/fzf/shell/completion.zsh
elif [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
  source /usr/local/opt/fzf/shell/key-bindings.zsh
  source /usr/local/opt/fzf/shell/completion.zsh
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi

unset _FZF_PREVIEW
