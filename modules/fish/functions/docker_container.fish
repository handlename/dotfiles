set -l id (docker container ls | fzf --header-lines=1 | awk '{print $1}')
commandline --insert "$id"
