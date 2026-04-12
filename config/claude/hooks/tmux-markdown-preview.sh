#!/bin/bash

# tmux Markdown preview hook for Claude Code
# PostToolUse で .md ファイルの変更を検知し、tmux の右ペインに glow でプレビュー表示する

set -euo pipefail

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# ツール種別に応じてファイルパスを取得
case "$tool_name" in
    "Write")
        file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
        ;;
    "Edit")
        file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')
        ;;
    "MultiEdit")
        file_path=$(echo "$input" | jq -r '.tool_input.files[0].path // empty')
        ;;
    *)
        exit 0
        ;;
esac

if [[ -z "$file_path" || "$file_path" == "null" ]]; then
    exit 0
fi

if [[ ! -f "$file_path" ]]; then
    exit 0
fi

# Markdown ファイルかどうか判定
extension="${file_path##*.}"
extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
case "$extension_lower" in
    md|markdown|mkd|mdx)
        ;;
    *)
        exit 0
        ;;
esac

# tmux 内で実行されているか確認
if [[ -z "${TMUX:-}" ]]; then
    exit 0
fi

# glow が利用可能か確認
if ! command -v glow >/dev/null 2>&1; then
    exit 0
fi

# tmux ウィンドウごとにプレビューペインを管理
state_dir="/tmp/claude-md-preview"
mkdir -p "$state_dir"
current_window=$(tmux display-message -p '#{window_id}')
state_file="${state_dir}/${current_window}"

# プレビューペインが生存しているか確認
pane_alive=false
if [[ -f "$state_file" ]]; then
    preview_pane=$(cat "$state_file")
    if tmux list-panes -F '#{pane_id}' 2>/dev/null | grep -qF "$preview_pane"; then
        pane_alive=true
    fi
fi

escaped_path=$(printf '%q' "$file_path")

if $pane_alive; then
    # 既存ペインを更新（実行中のプロセスを中断してから再描画）
    tmux send-keys -t "$preview_pane" C-c 2>/dev/null || true
    tmux send-keys -t "$preview_pane" " clear && glow ${escaped_path}" Enter
else
    # 右側に新しいプレビューペインを作成（幅40%、フォーカスは移さない）
    preview_pane=$(tmux split-window -h -l '40%' -d -P -F '#{pane_id}')
    echo "$preview_pane" > "$state_file"
    tmux send-keys -t "$preview_pane" " glow ${escaped_path}" Enter
fi

exit 0
