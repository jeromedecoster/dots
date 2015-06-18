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
