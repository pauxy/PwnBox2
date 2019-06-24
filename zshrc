# 256 colour support
export TERM="xterm-256color"

# Path to oh-my-zsh installation.
export ZSH="$(echo ~$USER)/.oh-my-zsh"

DISABLE_UNTRACKED_FILES_DIRTY="true"

ZSH_THEME="agnoster-dracula"

# Plugins
plugins=(
    git
    vi-mode
    zsh-syntax-highlighting
    extract
    tmux
    sudo
    colored-man-pages
    autojump
)

source $ZSH/oh-my-zsh.sh

## Syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[arg0]='fg=10,bold'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=44,bold'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=81,bold'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=226,bold'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=226,bold'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=white'
ZSH_HIGHLIGHT_STYLES[path]='fg=117'
ZSH_HIGHLIGHT_STYLES[assign]='fg=192,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=135,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=220,bold'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=220,bold'

## Autosuggestions config
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true

## Python configs
ve() {
    if [[ -z ${VIRTUAL_ENV} ]]; then
        if [[ ! -d venv ]]; then
            virtualenv -p python3 venv
            source venv/bin/activate
        else
            source venv/bin/activate
        fi
        echo "python:  $(which python)"
        echo "pip:     $(which pip)"
    else
        echo "You are already in a virtual environment"
        return 1
    fi
}

alias de='deactivate'

## Ulimate cheat sheet
howdafak() {
    if [[ -z ${1} || "${1}" == "-h" ]] then
        echo "Usage:    ${0} [-l] <topic> [query]"
        echo "Example:  ${0} c \"get string length\""
        echo "          ${0} python \"~file\" # Uses keyword \"file\""
        echo "          ${0} -l # Shows list of all topics"
        return 1
    elif [ ${1} = "-l" ]; then
        curl -s "https://cht.sh/:list" | grep -v '[/:]' | xargs -s 100 | tr " " "\t"
    else
        topic=${1}
        shift
        time curl -s "https://cht.sh/${topic}/${*}/i"
    fi
}

## FZF functions
f() {
    MYPATH="$HOME"
    if [ ! -z $1 ]
    then
        MYPATH="${1}"
    fi

    rg ${MYPATH} --files --hidden --no-ignore-vcs 2> /dev/null | fzf -m --ansi --preview '[[ $(file --mime {}) =~ binary ]] && echo $(basename {}) is a binary file \($(file --mime-type {} | cut -d ":" -f 2 | cut -c 2-)\) || (bat --color=always --style=header,grid --line-range :200 {})'
}

ff() {
    MYPATH="$(pwd)"
    if [ ! -z $1 ]
    then
        MYPATH="${1}"
    fi

        FILE=$(rg ${MYPATH} --files --hidden --no-ignore-vcs -g '!.git/*' 2> /dev/null | fzf --ansi --preview '[[ $(file --mime {}) =~ binary ]] && echo $(basename {}) is a binary file \($(file --mime-type {} | cut -d ":" -f 2 | cut -c 2-)\) || (bat --color=always --style=header,grid --line-range :200 {})')

    if [ ! -z $FILE ]
    then
        nvim "${FILE}"
    fi
}

fd() {
    MYPATH="$(pwd)"
    if [ ! -z $1 ]
    then
        MYPATH="${1}"
    fi

    DIR="$(find ${MYPATH} -type d -name ".git" -prune -o -type d -print 2> /dev/null | fzf --ansi --preview 'exa -T --level 1 --color always {}')"

    if [ ! -z $DIR ]
    then
        cd "${DIR}"
    fi
}

ft(){
    if [ -z ${1} ]
    then
        echo "Usage: ${0} <search term>"
        return
    fi
    local match=$(
      rg --trim --vimgrep --color=never --line-number "$1" 2> /dev/null |
        fzf --no-multi --delimiter : \
            --preview "bat --color=always --line-range {2}: {1}"
      )
    local file=$(echo "$match" | cut -d':' -f1)
    if [[ -n $file ]]; then
        nvim $file +$(echo "$match" | cut -d':' -f2)
    fi
}

## Aliases
alias vi="nvim -O 2> /dev/null"
alias :q='exit'
alias cls='clear'
alias ls='exa --git'
alias cat='bat'

## Vi-Mode
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search

KEYTIMEOUT=5

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}

zle -N zle-keymap-select

echo -ne '\e[5 q'

_fix_cursor() {
   echo -ne '\e[5 q'
}

precmd_functions+=(_fix_cursor)

export FZF_DEFAULT_COMMAND='rg $(pwd) --files --hidden --no-ignore-vcs -g "!.git/*" 2> /dev/null'
