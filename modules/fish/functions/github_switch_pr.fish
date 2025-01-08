set -l pr (run_gh pr list --state open --limit 100 2>/dev/null \
| fzf --preview 'run_gh pr view (echo {} | cut -f1)' \
    --bind    'ctrl-e:execute(run_gh pr view --web (echo {} | cut -f1))' \
| cut -f1
)

if ! test -n "$pr"
    commandline --function repaint
    return
end

run_gh pr checkout "$pr"

echo -e '\n'
commandline --function repaint
