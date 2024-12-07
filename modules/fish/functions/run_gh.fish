if which op >/dev/null
    op run -- gh $argv
else
    gh $argv
end
