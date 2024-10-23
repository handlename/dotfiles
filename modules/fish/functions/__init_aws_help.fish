set -l cmdfile $argv[1]

echo "aws command list will be created at $cmdfile"

set -l tmpdir (mktemp -d)
rm -f "$cmdfile"

git clone --depth 1 git@github.com:boto/botocore.git "$tmpdir"

set -l services (
find "$tmpdir/botocore/data" -maxdepth 1 -type d \
| perl -nE '@parts=split "/"; print $parts[-1]' \
| sort \
)

for service in $services
    set -l file (find "$tmpdir/botocore/data/$service" -name 'service-2.json' | tail -1)
    set -l operations (
    cat "$file" \
    | jq -r '.operations | keys | .[]' \
    | perl -pnE 's/([A-Z])/-\l\1/g; s/-//' \
    | sort \
    )

    for operation in $operations
        echo "$service $operation" >>"$cmdfile"
    end
end

echo "aws command list has been created at $cmdfile"

rm -rf "$tmpdir"
