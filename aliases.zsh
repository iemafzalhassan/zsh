# =========================================================
# Aliases — modern CLI replacements
# =========================================================

# ls -> eza (icons + git status)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lh --icons --git --group-directories-first'
  alias la='eza -lah --icons --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons'         # shallow tree
  alias lT='eza --tree --icons'                   # full tree
  compdef eza=ls
else
  alias ll='ls -lh'
  alias la='ls -lah'
fi

# cat -> bat (with paging)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=auto'
  alias less='bat --paging=auto'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=auto'
  alias less='batcat --paging=auto'
fi

# grep -> ripgrep
if command -v rg >/dev/null 2>&1; then
  alias grep='rg --color=auto'
fi

# diff with color
alias diff='diff --color=auto'
alias df='df -h'
alias du='du -h'

# =========================================================
# Navigation
# =========================================================
alias -- -='cd -'         # cd - jumps to previous dir
alias ..='cd ..'
alias ...='../..'
alias ....='../../..'

# zoxide shortcuts (init'd in .zshrc — these bind zi/za/zt/z aliases)
alias zc='zoxide create'   # add current dir to zoxide db
alias zl='zi'             # interactive picker

# =========================================================
# Editor
# =========================================================
# Pure emacs in the shell, vim only inside vim. The shell aliases below
# are for interactive sessions; install.sh also drops ~/.local/bin/vi
# and ~/.local/bin/vim -> nvim shims so non-interactive callers
# (git commit, crontab -e, scripts) get nvim too.
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'
fi

# =========================================================
# Git
# =========================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gl='git log --oneline --decorate -20'
alias glog='git log --oneline --graph --decorate'
alias gadog='git log --all --decorate --oneline --graph'
alias gd='git diff'
alias gds='git diff --staged'
alias gsta='git stash push -m'
alias gstp='git stash pop'

# delta for diffs if installed
if command -v delta >/dev/null 2>&1; then
  export GIT_PAGER='delta'
fi

# =========================================================
# Docker
# =========================================================
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dps='docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"'
alias dlogs='docker logs -f'

# =========================================================
# Kubernetes
# =========================================================
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'
alias ktail='kubectl logs -f --tail=100'

# =========================================================
# Terraform / Ansible
# =========================================================
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tff='terraform fmt -recursive'
alias tgv='terragrunt'

# =========================================================
# Python / venv
# =========================================================
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source .venv/bin/activate 2>/dev/null || source venv/bin/activate'

# =========================================================
# Networking quickies
# =========================================================
alias myip='curl -s https://ifconfig.me && echo'
alias localip='ipconfig getifaddr en0 2>/dev/null || hostname -I'
alias ports='lsof -i -P -n | grep LISTEN'
alias pingg='ping -c 5 google.com'

# =========================================================
# Misc quality-of-life
# =========================================================
alias reload='source ~/.zshrc && echo "zshrc reloaded"'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias zshaliases='${EDITOR:-nvim} ~/.aliases.zsh'
alias llg='lazygit'
alias lg='lazygit'
alias ldk='lazydocker'

# A tmux sessionizer pattern (project jumper). Customize PROJECT_DIRS to your taste.
if command -v fzf >/dev/null 2>&1; then
  proj() {
    local dir
    dir=$(find ~/Developer -mindepth 1 -maxdepth 4 -type d 2>/dev/null \
      | fzf --prompt="project> " --preview 'eza --tree --level=2 --icons {}') \
      && cd "$dir" && z
  }
fi
