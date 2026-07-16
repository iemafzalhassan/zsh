---
status: investigating
trigger: analyse my zsh repo i want to maintain a clean repo so when i spin up new vm i just need to use curl command and then repo clone and installation of the my go tools and shell change from any to zsh and everything configured in one go it just at the end i need to relogin to the vm or do source ~/.zshrc and boom my tools should be configure installed
created: 2026-07-17
updated: 2026-07-17
---
# Symptoms
- **Expected behavior**: Have a clean bootstrap process for new VMs that clones the repo, installs go tools, changes shell to zsh, and configures everything in one go.
- **Actual behavior**: Currently lacks an automated single-command bootstrap process.
- **Error messages**: N/A
- **Timeline**: New setup request.
- **Reproduction**: Spin up a new VM and attempt to configure it automatically.

# Current Focus
- hypothesis: Needs an automated bootstrap script (e.g. install.sh) that handles cloning, go tool installation, and shell configuration.
- next_action: gather initial evidence
