#!/usr/bin/env bash
# Launch the user's editor at a specific file:line in a non-blocking way.
#
# Why a script: editors differ in line-number syntax, and TUI editors cannot be
# launched from Claude Code's non-interactive bash subprocess (no tty control).
# Centralizing the mapping prevents Claude from constructing wrong commands.
#
# Usage: open_editor.sh <editor> <filepath> <line>
# Exit codes: 0 = launched, 2 = editor is TUI-only, 1 = usage error.
set -euo pipefail

editor="${1:?editor required}"
filepath="${2:?filepath required}"
line="${3:?line required}"

case "$editor" in
  zed|subl|cursor)
    cmd=("$editor" "${filepath}:${line}") ;;
  code|code-insiders|windsurf)
    cmd=("$editor" -g "${filepath}:${line}") ;;
  emacs)
    # GUI emacs only; emacs -nw falls into the TUI bucket below.
    cmd=(emacs "+${line}" "$filepath") ;;
  vim|nvim|nano|"emacs -nw")
    echo "ERROR: $editor is a TUI editor and cannot be launched from a non-interactive shell." >&2
    echo "Tell the user to open manually: $editor +$line $filepath" >&2
    exit 2 ;;
  *)
    # Unknown editor: fall back to the most common syntax and let it fail loudly.
    cmd=("$editor" "${filepath}:${line}") ;;
esac

echo "Running: ${cmd[*]}" >&2
"${cmd[@]}" &
disown 2>/dev/null || true
