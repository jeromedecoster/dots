
#
# Update the $PATH
#

# convert the $PATH to an array
tmp=$IFS
IFS=:
t=($PATH)
# remove /usr/local/bin from the array
unset IFS
t=(${t[@]%%/usr/local/bin})
# reset the $PATH with the array updated joined by ':'
IFS=:
PATH="${t[*]}"
IFS=$tmp
unset tmp
unset t

# set local/bin and homebrew/bin at start
PATH=/usr/local/bin:/usr/local/homebrew/bin:$PATH
export PATH

#
# Set the prompt
#

prompt_git() {
  # abort if not inside a git repo
  [[ `git rev-parse --is-inside-work-tree 2>/dev/null` != 'true' ]] && return

  local BLU='\033[0;34m'
  local GRE='\033[0;32m'
  local RED='\033[0;31m'
  local YEL='\033[0;33m'
  local RES='\033[0m'

  local branch="${BLU}`git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///'`\[${RES}\]"

  # check for staged, modified or untracked files
  local sta mod unt
  [[ -n `git diff --cached --name-only` ]] && sta=1
  [[ -n `git ls-files --modified --exclude-standard` ]] && mod=1
  [[ -n `git ls-files --others --directory --exclude-standard` ]] && unt=1

  # if no staged, modified or untracked files
  if [[ -z $sta && -z $mod && -z $unt ]]; then
    echo -n " [$branch]"
  # otherwise, more complex prompt with warn
  else
    local warn
    [[ -n $sta ]] && warn="${GRE}sta\[${RES}\]"
    [[ -n $mod ]] && warn="${warn}-${RED}mod\[${RES}\]"
    [[ -n $unt ]] && warn="${warn}-${YEL}unt\[${RES}\]"
    # if warn starts with a dash, remove it
    [[ ${warn:0:1} == "-" ]] && warn=${warn:1}
    echo -n " [$branch:$warn]"
  fi
}

# the current directory path displayed in the advanced prompt
prompt_path() {
  local tmp inside
  local BLU='\033[0;34m'
  local RES='\033[0m'

  # pwd is ~
  if [[ $PWD == $HOME ]]; then
    echo "[${BLU}~\[${RES}\]]" && return
  elif [[ $PWD == '/' ]]; then
    echo "[${BLU}/\[${RES}\]]" && return
  # pwd is inside ~
  elif [[ $HOME == ${PWD:0:${#HOME}} ]]; then
    inside=1
    tmp="~${PWD:${#HOME}}"
  else
    # remove first /
    tmp=${PWD:1}
  fi

  # '$' must be escaped
  tmp=$(echo "$tmp" | sed -e 's/\$/\\\\$/g')

  local ti=$IFS
  IFS='/'
  local arr=($tmp)
  IFS=$ti

  local lng=${#arr[@]}
  local path
  if [[ -n $inside ]]; then
    [[ $lng -le 3 ]] && path=$tmp || path="~/../${arr[$lng - 2]}/${arr[$lng - 1]}"
  else
    [[ $lng -le 3 ]] && path=/$tmp || path="/${arr[0]}/../${arr[$lng - 2]}/${arr[$lng - 1]}"
  fi

  echo "[${BLU}$path\[${RES}\]]"
}

# exit code of previous command
prompt_exitcode() {
  if [[ $1 != 0 ]]; then
    local RED='\033[0;31m'
    local RES='\033[0m'
    echo " ${RED}($1)\[${RES}\]"
  fi
}

prompt() {
  local exit_code=$?
  # fix an important problem with long command overlap
  # for the prompt, the reset color must be included within '\[' and '\]'
  # http://stackoverflow.com/a/706872/1503073
  PS1=""
  PS1="$PS1`prompt_path`"
  PS1="$PS1`prompt_git`"
  PS1="$PS1`prompt_exitcode "$exit_code"`"
  PS1="$PS1\n$ "
}

PROMPT_COMMAND=prompt

#
# Alias
#

alias ..='cd ..'
alias ...='cd ../..'
# git aliases...
alias ga='git add'
alias gs='git status'
alias gc='git commit -m'
alias gco='git co'
