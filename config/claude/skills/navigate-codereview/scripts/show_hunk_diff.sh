#!/usr/bin/env bash
# Print a syntax-highlighted diff hunk for one file from origin/<base>..HEAD.
#
# Why a script:
# - origin/<base> (not local <base>) avoids stale-base false positives.
# - Tool selection (diff.tool -> bat -> plain colored diff) is tedious and
#   easy to get wrong with interactive tools like vimdiff/meld that reject pipes.
# - `--no-pager` is mandatory; core.pager can otherwise block the subprocess.
#
# Usage: show_hunk_diff.sh <base-ref> <path> [start-line] [end-line]
#   start/end are line numbers in the diff output, not in the file.
set -euo pipefail

base="${1:?base ref required}"
path="${2:?path required}"
start="${3:-1}"
end="${4:-9999}"

diff_tool="$(git config --get diff.tool || true)"
# Reject tools that need a tty or don't consume stdin.
case "$diff_tool" in
  vimdiff|gvimdiff|nvimdiff|meld|bcompare|kdiff3|opendiff|araxis) diff_tool="" ;;
esac

if [[ -n "$diff_tool" ]] && command -v "$diff_tool" >/dev/null 2>&1; then
  git --no-pager diff "origin/${base}...HEAD" -- "$path" | sed -n "${start},${end}p" | "$diff_tool"
elif command -v bat >/dev/null 2>&1; then
  git --no-pager diff "origin/${base}...HEAD" -- "$path" \
    | sed -n "${start},${end}p" \
    | bat --language=diff --style=plain --color=always --paging=never
else
  # Apply git's own color before sed; ANSI escapes survive line-range extraction.
  git --no-pager diff --color=always "origin/${base}...HEAD" -- "$path" | sed -n "${start},${end}p"
fi
