# remove $1 from the $PATH
path_remove() {
  # convert path to an array
  local tmp=$IFS
  IFS=:
  local t=($PATH)
  # remove paths found from the array
  unset IFS
  t=(${t[@]%%$1})
  # echo the result, an array joined with ':'
  IFS=:
  echo "${t[*]}"
  IFS=$tmp
}

# set /usr/local/bin before /usr/bin in the $PATH
PATH=/usr/local/bin:`path_remove /usr/local/bin`
# add /usr/local/homebrew/bin then ~/.dotfiles/osx/bin to the $PATH
PATH=/usr/local/homebrew/bin:$PATH
PATH=~/.dotfiles/osx/bin:$PATH
export PATH
unset -f path_remove

