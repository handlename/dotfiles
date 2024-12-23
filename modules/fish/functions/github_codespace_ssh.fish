set -f space (__github_select_codespace)

if ! test -n "$space"
    commandline --function repaint
    return
end

run_gh codespace ssh -c $space
