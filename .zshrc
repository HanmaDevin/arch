#  _________  _   _    ____ ___  _   _ _____ ___ ____
# |__  / ___|| | | |  / ___/ _ \| \ | |  ___|_ _/ ___|
#   / /\___ \| |_| | | |  | | | |  \| | |_   | | |  _
#  / /_ ___) |  _  | | |__| |_| | |\  |  _|  | | |_| |
# /____|____/|_| |_|  \____\___/|_| \_|_|   |___\____|

# Set environment for plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# check if already installed, if not install it - useful for new machines
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Add plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add snippets
zinit snippet OMZP::sudo

autoload -Uz compinit && compinit
zinit cdreplay -q

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath' 
zstyle ':completion:*' fzf-search-display true

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]] ; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source <(fzf --zsh)

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"export FZF_COMPLETION_TRIGGER='**'

# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

export FZF_COMPLETION_PATH_OPTS="--walker file,dir,follow,hidden"
export FZF_COMPLETION_DIR_OPTS="--walker dir,follow"

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.cargo/bin"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview "--preview 'bat -n --color=always --line-range :500'" "$@" ;;
  esac
}

fastfetch

# Helpful aliases
alias  c='clear' 
alias ls='eza -lh --icons=always --color=always --sort=name --group-directories-first'  
alias la='eza -lha --icons=always --color=always --sort=name --group-directories-first'  
alias lt='eza --icons=always --color=always --tree --level=3' 
alias cd="z"
alias refresh="source ~/.zshrc"

alias gclone="gh repo clone"
alias repolist="gh repo list"

alias v="nvim"
alias vim="nvim"

# pacman
alias remove="yay -Rns --noconfirm"
alias update="yay -Syu --noconfirm"
alias search="yay -Slq | fzf --multi --preview 'yay -Sii {1}'"

alias copy="wl-copy"
alias paste="wl-paste"

alias editzsh="nvim ~/.zshrc"
alias lg="lazygit"

alias rm="rm -I"

# visual
alias open="xdg-open"
alias bat='bat -p --color=always --theme="Dracula"'
alias q="exit"

alias ..='z ..'

# you may also use the following one
bindkey -s '^o' 'nvim $(fzf)\n'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

export EDITOR="nvim"
export VISUAL="nvim"

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

setopt correct
setopt notify
setopt numericglobsort

get() {
  if [[ -z "$1" ]]; then
    local pkg_names

    fzf_args=(
    --multi
    --preview 'yay -Sii {1}'
    --preview-label='alt-p: toggle description, alt-b/B: toggle PKGBUILD, alt-j/k: scroll, tab: multi-select'
    --preview-label-pos='bottom'
    --preview-window 'down:65%:wrap'
    --bind 'alt-p:toggle-preview'
    --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
    --bind 'alt-k:preview-up,alt-j:preview-down'
    --bind 'alt-b:change-preview:yay -Gpa {1} | tail -n +5'
    --bind 'alt-B:change-preview:yay -Siia {1}'
    --color 'pointer:green,marker:green'
    )

    pkg_names=$(yay -Slq | fzf "${fzf_args[@]}")

    if [[ -n "$pkg_names" ]]; then
      # Convert newline-separated selections to space-separated for yay
      echo "$pkg_names" | tr '\n' ' ' | xargs yay -S --noconfirm
      echo
      gum spin --spinner "globe" --title "Done! Press any key to close..." -- bash -c 'read -n 1 -s'
    fi
  else
    yay -S --noconfirm "$@"
  fi
}

extract() {
  local arch="$1"
  local dest="$PWD"
  if [ -n "$2" ]; then
    dest="$2"
  fi
  if [ -f "$arch" ]; then
    case $arch in 
      *.tar.bz2) tar xvjf $arch -C "$dest" ;;
      *.tar.gz) tar xvzf $arch -C "$dest" ;;
      *.rar) rar x $arch "$dest";;
      *.tar) tar xvf $arch -C "$dest" ;;
      *.tbz2) tar xvjf $arch -C "$dest" ;;
      *.tgz) tar xvzf $arch -C "$dest" ;;
      *.zip) unzip $arch -d "$dest" ;;
      *.gz) gunizp $arch ;;
      *) echo "Do not know how to extract for now :(" ;;
    esac
  else
    echo "'$arch' is not a file!"
  fi
}
