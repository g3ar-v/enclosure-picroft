export ZSH=$HOME/.config/zsh
export EDITOR="nvim"
export HISTFILE=$HOME/.config/zsh/.zsh_history
setopt extended_glob

# set default prompt if zsh config can't be found   
[[ -z "$ZSH" ]] && export ZSH="${${(%):-%x}:a:h}"

# Set ZSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
if [[ -z "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="$ZSH/cache"
fi

ZSH_CACHE_DIR="$ZSH/cache"

# Make sure $ZSH_CACHE_DIR is writable, otherwise use a directory in $HOME
if [[ ! -w "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
fi

# Create cache and completions dir and add to $fpath
mkdir -p "$ZSH_CACHE_DIR/completions"
(( ${fpath[(Ie)"$ZSH_CACHE_DIR/completions"]} )) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)
# fi

ZSH_THEME="agnoster"

#for autocompletion
#zsh-autocomplete
plugins=(copypath zsh-vi-mode z shrink-path zsh-autosuggestions zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

if ! command -v exa &> /dev/null; then
  echo "Installing exa..."
  sudo apt install exa 
fi

# Aliases 
alias ll="exa -l -g --icons"
alias lla="exa -l -g -a --icons --sort name"
alias tree="tree -C"
alias g="git"
alias gdir='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias ceconfig='core-config edit user'
alias cra='$HOME/Documents/__core__/start-core.sh all restart'
alias crs='$HOME/Documents/__core__/start-core.sh skills restart'
alias craudio='$HOME/Documents/__core__/start-core.sh audio restart'
