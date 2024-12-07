set -l image (docker images | fzf | awk '{print $1":"$2}')
commandline --insert "$image"
