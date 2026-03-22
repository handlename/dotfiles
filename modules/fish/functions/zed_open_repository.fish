set -l ghq_root (ghq root)

set -l repo (ghq list \
    | fzf --preview "test -f $ghq_root/{1}/README.md && glow $ghq_root/{1}/README.md || echo 'No README.md'")

if test -z "$repo"
    commandline --function repaint
    return
end

cd "$ghq_root/$repo"

if test -x .zed.local
    ./.zed.local
else
    zed .
end

commandline --function repaint
