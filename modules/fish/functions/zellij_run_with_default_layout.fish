set -l name (pwd | awk '{gsub(/^.+\//, ""); print}')
zellij -n $name --layout ~/.config/zellij/layouts/default.kdl
