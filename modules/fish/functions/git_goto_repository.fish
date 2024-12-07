set -l root (ghq root)

set -l path (ghq list \
    | fzf --preview="git -C $root/{1} status")

if test -n "$path"
    cd "$root/$path"
end

commandline --function repaint
