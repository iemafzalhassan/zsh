---
status: resolved
trigger: "Fresh Ubuntu install via curl|bash errors: zmodload command not found, -bash: unexpected argument `(` to conditional binary operator, -bash: syntax error near `(['"
created: 2026-07-06
updated: 2026-07-06
---

# Debug: fresh-ubuntu-install-fail

## Symptoms
- Repo: `~/Developer/Projects/zsh` (iemafzalhassan)
- Machine: Ubuntu (apt), user `ubuntu`, no sudo password set initially
- Command: `curl -fsSL https://raw.githubusercontent.com/iemafzalhassan/zsh/main/bootstrap.sh | bash`
- **1st run** (no password): starship installer hung on `[sudo: authenticate] Password:`
  because it tried to install to `/usr/local/bin` and needs sudo.
  User backgrounded it, set a password via `sudo su -`, retried.
- **2nd run**: apt install OK, zoxide OK, starship OK (`✓ Starship latest installed`),
  started downloading lazygit then prompt returned.
- User then typed `eval "$(starship init zsh)"` and got:
  - `zmodload: command not found`
  - `-bash: unexpected argument \`(\` to conditional binary operator`
  - `-bash: syntax error near \`(['`

## Root cause

**Two bugs working together:**

1. **starship installer prompts for sudo interactively when /usr/local/bin is
   not writable.** Our `install_via_curl` calls starship's installer with
   `sh "$script" -y`, but `-y` only auto-confirms the post-install welcome
   message — it does NOT bypass the sudo prompt for `/usr/local/bin`.
   The installer blocks forever on the password prompt, which kills
   the automated flow. First-run users without a sudo password get
   stuck.

2. **chsh requires a full logout/login to take effect, and the README
   only says "relogin".** The user ran the install, the install tried
   `chsh -s $(which zsh)`, but they never logged out. The next terminal
   still opened bash. When they manually tried `eval "$(starship init zsh)"`
   from bash, the zsh-syntax (`zmodload`, `[[ ... ]]`) blew up with
   those exact bash errors.

**Secondary issue:** zoxide installs to `~/.local/bin` and warns
"is not on your $PATH" — but our `.zshenv` does export PATH. The
warning is shown during install before .zshenv is sourced, so it's
just noise. Confirmed not a real bug.

## Fix

A. **Force starship (and all curl installers) to install to `~/.local/bin`**
   instead of `/usr/local/bin`. This avoids sudo entirely.
   `install_via_curl` becomes `install_via_curl <url> <name> [args...]` and
   we pipe `XDG_BIN_HOME=$HOME/.local/bin` to the starship installer
   so it picks a user-writable path.

B. **When `chsh` is run, instruct the user to actually log out.**
   The current message "relogin (so the new default shell takes effect)"
   is ambiguous. Replace with explicit "log out of your SSH/desktop
   session and log back in" and verify `/etc/shells` contains zsh.

C. **Add a post-install sanity check** that warns if `$SHELL` is still
   bash after `change_shell` ran. Catches the "still in bash" case
   before the user types something that breaks.

D. **starship installer exit code on sudo failure should be tolerated**
   (already done — `install_via_curl` continues on non-zero). Good.

## Files changed
- install.sh — install_via_curl: accept env, force XDG_BIN_HOME for
  starship; change_shell: explicit relogin instructions, $SHELL sanity check
- README.md — replace vague "relogin" with concrete instructions
- install.sh — debian/rhel/suse/alpine: same change propagates automatically
