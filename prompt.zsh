# ~/.prompt.zsh — Starship prompt.
# The actual starship.toml lives at ~/.config/starship.toml (symlinked
# from this repo's starship.toml) and is loaded via STARSHIP_CONFIG in .zshenv.

# Don't let python venv's default "(venv)" prefix mess with the prompt.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Tune function-call nesting to allow complex prompt evaluations
FUNCNEST=100

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  # Fallback prompt if starship somehow isn't installed.
  PROMPT='%F{cyan}%~%f %F{green}❯%f '
  RPROMPT='%F{yellow}%T%f'
fi
