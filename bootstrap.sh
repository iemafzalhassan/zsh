#!/usr/bin/env bash
# bootstrap.sh — one-shot installer fetched via curl.
#
# Usage (from any fresh macOS/Linux box):
#   curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/zsh/main/bootstrap.sh | bash
#
# What it does:
#   1. Clones the dotfiles repo to ~/Developer/Projects/zsh
#   2. Runs install.sh from the cloned repo
#
# Override the repo URL or target dir:
#   REPO_URL=https://github.com/you/zsh.git TARGET_DIR=~/code/zsh curl -fsSL ... | bash
set -euo pipefail

: "${REPO_URL:=https://github.com/YOUR_GITHUB_USERNAME/zsh.git}"
: "${TARGET_DIR:=$HOME/Developer/Projects/zsh}"
: "${BRANCH:=main}"

# Ensure bash (some defaults are dash/sh)
if [ -z "${BASH_VERSION:-}" ]; then
  echo "This script needs bash. Re-run with: bash <(curl -fsSL ...)" >&2
  exit 1
fi

echo "[bootstrap] target: $TARGET_DIR"
echo "[bootstrap] repo:   $REPO_URL"

if [ -d "$TARGET_DIR/.git" ]; then
  echo "[bootstrap] repo already cloned, pulling latest..."
  git -C "$TARGET_DIR" pull --ff-only || true
else
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

# Now run install.sh from inside the repo
TARGET_DIR="$TARGET_DIR" exec bash "$TARGET_DIR/install.sh"
