gibo list \
    | fzf -m \
    --preview 'gibo dump {}' \
    | xargs gibo dump
