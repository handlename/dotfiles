set -l candidates (run_gh codespace list \
    --json 'repository,gitStatus,name,state,createdAt' \
    --jq '
        ["Repository", "Branch", "Name", "State", "CreatedAt"],
        (sort_by(.createdAt)
        | reverse
        | .[]
        | [.repository, .gitStatus.ref, .name, .state, .createdAt])
        | @csv
    ' \
    | mlr --csv --opprint cat \
)

if test -z $candidates
    echo "No codespaces found" >&2
    return
end

echo $candidates \
    | fzf --header-lines=1 \
    | perl -nE 'print [split(/ *\| */)]->[2]'
