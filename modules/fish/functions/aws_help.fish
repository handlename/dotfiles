set -l cachedir $XDG_CONFIG_HOME/fish/cache
set -l cmdfile "$cachedir/awscli_commands.txt"

if ! test -f "$cmdfile"
    __init_aws_help "$cmdfile"
end

set -l cmd (cat "$cmdfile" \
| fzf --preview 'aws {1} {2} help' \
      --bind    'ctrl-e:execute(echo {} | pbcopy && open https://docs.aws.amazon.com/cli/latest/reference/{1}/{2}.html)+abort'
)

if ! test -n "$cmd"
    commandline --function repaint
    return
end

commandline --insert "$cmd "
