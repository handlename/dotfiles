# Prevent nested zellij sessions
if set -q ZELLIJ
    echo 'Already in a zellij session' >&2
    return 1
end

# Collect existing zellij sessions, categorized by status
set -l session_info (zellij list-sessions --no-formatting 2>/dev/null)
set -l active_sessions
set -l exited_sessions

for line in $session_info
    set -l name (echo $line | awk '{print $1}')
    if string match -q '*EXITED*' $line
        set -a exited_sessions $name
    else
        set -a active_sessions $name
    end
end

# Select a repository via fzf with session status indicators
# - Green [active]: has a running zellij session
# - Red [exited]: has an exited zellij session (can be resurrected)
set -l ghq_root (ghq root)
set -l repo (ghq list | while read -l r
    set -l name (basename $r)
    if contains $name $active_sessions
        printf '\033[32m%s [active]\033[0m\n' $r
    else if contains $name $exited_sessions
        printf '\033[31m%s [exited]\033[0m\n' $r
    else
        echo $r
    end
end | fzf --ansi \
    --preview "test -f $ghq_root/{1}/README.md && glow $ghq_root/{1}/README.md || echo 'No README.md'")

if test -z "$repo"
    echo 'canceled'
    return
end

# Strip the status marker from the selected repository
set -l repo (string replace -r ' \[(active|exited)\]' '' $repo)
set -l repo_path (ghq root)/$repo
set -l session_name (basename $repo)

# Attach to existing session or start a new one
set -l existing_session (zellij list-sessions --short 2>/dev/null | grep -E '^'$session_name'$')

if test -n "$existing_session"
    zellij attach $session_name
    return
end

cd $repo_path
zellij -s $session_name
