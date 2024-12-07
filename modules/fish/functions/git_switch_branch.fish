set branch (git branch --all \
| grep -v HEAD \
| string trim \
| fzf --preview="git log --first-parent {}" \
        --no-multi \
)

if test -z "$branch"
    commandline -f repaint
    return
end

git switch (echo "$branch" \
| sed "s/.* //" \
| sed "s#remotes/[^/]*/##" \
)

echo -e '\n'
commandline -f repaint
