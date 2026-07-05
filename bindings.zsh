# ~/.bindings.zsh — emacs-style keybindings (no zsh-vi-mode).
# Pure emacs in the shell, vim lives only inside nvim.

# Word boundaries: treat - and . as part of words for shell-friendly nav.
# This makes `cd ~/pr<Ctrl+W>` delete "pr" not "~/pr".
WORDCHARS=''

# Fuzzy file picker (no hidden) — defined in fzf.zsh, but bind it here.
# Use ^F (^[[15;5~) and ^T (default fzf)
if (( ${+widgets[_fzf_file_no_hidden]} )); then
  bindkey '^F' _fzf_file_no_hidden
fi

# Toggle autosuggestions
if (( ${+widgets[autosuggest-toggle]} )); then
  bindkey '^\\' autosuggest-toggle
fi

# History substring search (up/down arrow filters by what you've typed)
# The two history-substring-search plugins expose these widgets.
if (( ${+widgets[history-substring-search-up]} )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# Word-wise delete: keep stock emacs but make ^W respect WORDCHARS above.
# (No binding needed — zsh respects $WORDCHARS by default in emacs mode.)

# Quick "open in editor" — Ctrl-X Ctrl-E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Ctrl-X Ctrl-K to kill the whole line buffer cleanly
bindkey '^X^K' kill-buffer

# Alt-. (insert last arg of previous command, fish-style)
bindkey '^[.' insert-last-word

# Accept autosuggestion with End / right-arrow when suggestion is shown
bindkey '^[[F' autosuggest-accept
bindkey '^[[C' autosuggest-accept
