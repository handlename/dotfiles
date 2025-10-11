set -l name (pwd | awk '{gsub(/^.+\//, ""); print}')
zellij -s $name -n ~/.config/zellij/layouts/default.kdl
