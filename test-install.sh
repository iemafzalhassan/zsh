#!/usr/bin/env bash
# install-test.sh — sandboxed end-to-end test of install.sh.
# Builds a fake $HOME, runs the install's symlink dance, then boots zsh
# against the symlinked config to verify it starts cleanly.

set -euo pipefail

FAKE_HOME="$(mktemp -d)/fakehome"
mkdir -p "$FAKE_HOME/Developer/Projects"
export FAKE_HOME HOME="$FAKE_HOME"
export XDG_CONFIG_HOME="$FAKE_HOME/.config"
export XDG_CACHE_HOME="$FAKE_HOME/.cache"
export XDG_DATA_HOME="$FAKE_HOME/.local/share"
export XDG_STATE_HOME="$FAKE_HOME/.local/state"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

TMPDOT="$(mktemp -d)"
cp -R /Users/iemafzal-mac/Developer/Projects/zsh/. "$TMPDOT/"
chmod +x "$TMPDOT/install.sh"

export CHANGE_SHELL=false INSTALL_TPM=false
export PROMPT_FOR_GIT_IDENTITY=false INSTALL_ATUIN=false
export DOTFILES_DIR="$TMPDOT"

WRAP="$TMPDOT/install-test.sh"
ORIG="$TMPDOT/install.sh"
TOTAL=$(wc -l < "$ORIG")
HEAD=$((TOTAL - 1))

cat > "$WRAP" <<WRAP_EOF
#!/usr/bin/env bash
set -euo pipefail
export DOTFILES_DIR="$TMPDOT"
export HOME="$FAKE_HOME"
export XDG_CONFIG_HOME="$FAKE_HOME/.config"
export XDG_CACHE_HOME="$FAKE_HOME/.cache"
export XDG_DATA_HOME="$FAKE_HOME/.local/share"
export XDG_STATE_HOME="$FAKE_HOME/.local/state"
export CHANGE_SHELL=false INSTALL_TPM=false
export PROMPT_FOR_GIT_IDENTITY=false INSTALL_ATUIN=false
install_packages() { :; }
fix_linux_alt_names() { :; }
install_tpm() { :; }
change_shell() { :; }
configure_git_identity() { :; }
sed -n "1,${HEAD}p" "$ORIG" > "$TMPDOT/_sourced.sh"
source "$TMPDOT/_sourced.sh"
make_state_dirs
link_dotfiles
# link_vim_shims needs a real nvim; symlink a fake one into PATH so the
# shim-creation logic runs in the sandbox.
mkdir -p "$TMPDOT/fakebin"
cat > "$TMPDOT/fakebin/nvim" <<'NVIM_EOF'
#!/usr/bin/env bash
exit 0
NVIM_EOF
chmod +x "$TMPDOT/fakebin/nvim"
PATH="$TMPDOT/fakebin:$PATH" link_vim_shims
WRAP_EOF
chmod +x "$WRAP"
bash "$WRAP"

echo
echo "==== AUDIT: $FAKE_HOME ===="
ok=0; bad=0
for f in .zshrc .zshenv .aliases.zsh .bindings.zsh .fzf.zsh .plugins.zsh .prompt.zsh .gitconfig .tmux.conf; do
  if [[ -L "$FAKE_HOME/$f" ]] && [[ -e "$FAKE_HOME/$f" ]]; then
    echo "  [OK]  $f -> $(readlink "$FAKE_HOME/$f")"
    ok=$((ok+1))
  else
    echo "  [BAD] $f"
    bad=$((bad+1))
  fi
done
[[ -L "$FAKE_HOME/.config/starship.toml" ]] && { echo "  [OK]  .config/starship.toml"; ok=$((ok+1)); } || { echo "  [BAD] .config/starship.toml"; bad=$((bad+1)); }
[[ -L "$FAKE_HOME/.config/nvim" ]] && { echo "  [OK]  .config/nvim"; ok=$((ok+1)); } || { echo "  [BAD] .config/nvim"; bad=$((bad+1)); }
for s in vi vim v; do
  if [[ -L "$FAKE_HOME/.local/bin/$s" ]] && [[ -e "$FAKE_HOME/.local/bin/$s" ]]; then
    echo "  [OK]  .local/bin/$s -> $(readlink "$FAKE_HOME/.local/bin/$s")"
    ok=$((ok+1))
  else
    echo "  [BAD] .local/bin/$s"
    bad=$((bad+1))
  fi
done
echo "==== SYMLINK SUMMARY: $ok OK, $bad BAD ===="

echo
echo "==== ZSH STARTUP TEST ===="
HOME="$FAKE_HOME" XDG_CONFIG_HOME="$FAKE_HOME/.config" XDG_CACHE_HOME="$FAKE_HOME/.cache" \
  XDG_DATA_HOME="$FAKE_HOME/.local/share" XDG_STATE_HOME="$FAKE_HOME/.local/state" \
  zsh -i -c '
    echo "  --- modules loaded ---"
    for m in aliases bindings fzf plugins prompt; do
      [[ -f "$HOME/.$m.zsh" ]] && echo "    [OK]  $m.zsh sourced"
    done
    echo "  --- editor: $EDITOR ---"
    echo "  --- bindkey -e (emacs) test ---"
    bindkey "^A" 2>&1 | head -1
    bindkey "^E" 2>&1 | head -1
    bindkey "^W" 2>&1 | head -1
    echo "  --- zsh-vi-mode absent (should fail) ---"
    bindkey "^X^V" 2>&1 | head -1
    echo "  --- aliases ---"
    alias ls 2>&1 | head -1
    alias g 2>&1 | head -1
    alias k 2>&1 | head -1
  ' 2>&1 | tail -20
