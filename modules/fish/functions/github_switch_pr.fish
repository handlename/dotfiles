set -l pr (run-gh pr list --state open --limit 100 2>/dev/null \
| fzf --preview 'run-gh pr view (echo {} | cut -f1)' \
        --bind    'ctrl-e:execute(run-gh pr view --web (echo {} | cut -f1))' \
| cut -f1
)

if ! test -n "$pr"
    commandline --function repaint
    return
end

run-gh pr checkout "$pr"

echo -e '\n'
commandline --function repaint
