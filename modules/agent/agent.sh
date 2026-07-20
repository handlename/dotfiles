#!/usr/bin/env bash
#
# Launcher that starts an AI agent based on the current context.
# It checks whether claude is logged in and whether a resumable session
# exists for the current working directory, then runs the command for the
# first matching condition via ztx.
#
#   1. claude logged in     + claude session exists -> claude --continue
#   2. claude logged in     + no claude session     -> claude
#   3. claude not logged in + agy session exists    -> agy --continue
#   4. claude not logged in + no agy session        -> agy
#
set -euo pipefail

readonly CLAUDE_KEYCHAIN_SERVICE="Claude Code-credentials"
readonly CLAUDE_PROJECTS_DIR="${HOME}/.claude/projects"
readonly AGY_LAST_CONVERSATIONS="${HOME}/.gemini/antigravity-cli/cache/last_conversations.json"

# claude stores its login credentials in the macOS Keychain.
claude_has_login() {
  security find-generic-password -s "${CLAUDE_KEYCHAIN_SERVICE}" >/dev/null 2>&1
}

# claude stores per-directory sessions as
# ~/.claude/projects/<encoded>/*.jsonl, where <encoded> is the absolute path
# with "/" and "." replaced by "-".
claude_has_resumable_session() {
  local encoded
  encoded="$(printf '%s' "${PWD}" | sed 's#[/.]#-#g')"
  compgen -G "${CLAUDE_PROJECTS_DIR}/${encoded}/*.jsonl" >/dev/null
}

# agy (Antigravity) keeps a cwd -> conversation ID map in
# last_conversations.json. If the cwd is a key, --continue can resume it.
agy_has_resumable_session() {
  [[ -f "${AGY_LAST_CONVERSATIONS}" ]] || return 1
  grep -qF "\"${PWD}\"" "${AGY_LAST_CONVERSATIONS}"
}

main() {
  if claude_has_login; then
    if claude_has_resumable_session; then
      exec ztx run -- claude --continue
    fi
    exec ztx run -- claude
  fi

  if agy_has_resumable_session; then
    exec ztx run -- agy --continue
  fi
  exec ztx run -- agy
}

main "$@"
