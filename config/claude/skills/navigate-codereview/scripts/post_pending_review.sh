#!/usr/bin/env bash
# Create a pending PR review with inline comments.
#
# Why a script: the GitHub REST contract is fiddly — omitting `event` is what
# keeps the review in draft state, only one pending review per PR per user is
# allowed, and head SHA must match HEAD. Centralizing this prevents accidental
# submissions and duplicate-review errors.
#
# Usage: post_pending_review.sh <OWNER/REPO> <PR_NUMBER> <comments_json_file> [body]
#   comments_json_file: JSON array of comment objects
#     (see https://docs.github.com/rest/pulls/reviews#create-a-review-for-a-pull-request)
#
# Exit codes: 0 = created (prints HTML URL), 3 = existing pending review blocks creation,
#             other non-zero = API error.
set -euo pipefail

repo="${1:?OWNER/REPO required}"
pr="${2:?PR number required}"
comments_file="${3:?comments JSON file required}"
body="${4:-}"

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: $tool is required." >&2; exit 1; }
done
[[ -f "$comments_file" ]] || { echo "ERROR: comments file not found: $comments_file" >&2; exit 1; }

pending="$(gh api "repos/${repo}/pulls/${pr}/reviews" \
  --jq '[.[] | select(.state == "PENDING" and .user.login == (env.GH_USER // ""))] | length' 2>/dev/null || echo 0)"
# GH_USER may be empty; also fall back to "any pending review" check since GitHub
# enforces the limit per-user and we can't always know our login from env.
if [[ "$pending" == "0" ]]; then
  pending="$(gh api "repos/${repo}/pulls/${pr}/reviews" --jq '[.[] | select(.state == "PENDING")] | length')"
fi
if [[ "$pending" != "0" ]]; then
  echo "ERROR: A pending review already exists on this PR. Discard it or append to it before creating a new one." >&2
  gh api "repos/${repo}/pulls/${pr}/reviews" --jq '.[] | select(.state == "PENDING") | {id, user: .user.login, html_url}' >&2
  exit 3
fi

commit_sha="$(gh api "repos/${repo}/pulls/${pr}" --jq '.head.sha')"

# Omit `event` so GitHub stores the review as pending (draft) rather than publishing it.
payload="$(jq -n \
  --arg commit_id "$commit_sha" \
  --arg body "$body" \
  --slurpfile comments "$comments_file" \
  '{commit_id: $commit_id, body: $body, comments: $comments[0]}')"

gh api "repos/${repo}/pulls/${pr}/reviews" \
  --method POST \
  --input - <<< "$payload" \
  --jq '.html_url'
