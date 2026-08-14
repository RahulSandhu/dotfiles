# Powerlevel10k instant prompt (keep near the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Exports
export EDITOR=nvim
export BROWSER=firefox

export GOPATH="$HOME/.local/share/go"
export GOMODCACHE="$GOPATH/pkg/mod"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

export PYTHONDONTWRITEBYTECODE=1

export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export _JAVA_AWT_WM_NONREPARENTING=1

# Zinit plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugin configuration
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

autoload -U compinit && compinit
autoload -Uz zmv
zinit cdreplay -q

# Snippets (OMZP)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux

# History settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups
setopt hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Key bindings
bindkey -e
unsetopt vi
bindkey '^ ' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
zle_highlight+=(paste:none)

# Completion & FZF styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias bw='sudo bandwhich'
alias htop='btop'
alias cat='bat'
alias ls='exa --icons=always'
alias neofetch='fastfetch'
alias tree='exa --icons=always --tree'

# Gtrash integrations
rm() { gtrash put "$@"; }
rm-list() { gtrash summary | sort; }
rm-clean() { gtrash prune --day 0; }
rm-find() { gtrash find; }
rm-restore() { gtrash restore; }
rm-restore-group() { gtrash restore-group; }
rm-metafix() { gtrash metafix; }

# Rbenv
eval "$(rbenv init - zsh)"

# FZF
export FZF_CTRL_R_OPTS="--exact"
eval "$(fzf --zsh)"

# Zoxide 
eval "$(zoxide init --cmd cd zsh)"

# Direnv
eval "$(direnv hook zsh)"

# Powerlevel10k prompt configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
