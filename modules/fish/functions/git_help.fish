set -l cmd (git help -a \
| egrep '^  \S' \
| xargs -n1 echo \
| sort \
| fzf --preview 'git help {} | head -20' \
        --bind    'ctrl-e:execute-silent(open dash://manpages:git-{})+abort' \
)

if ! test -n "$cmd"
    commandline --function repaint
    return
end

commandline --insert "$cmd "
