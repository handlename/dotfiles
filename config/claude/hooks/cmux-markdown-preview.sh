#!/bin/bash

# cmux Markdown preview hook for Claude Code
# PostToolUse で .md ファイルの変更を検知し、cmux の右ペインに glow でプレビュー表示する

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

# cmux 内で実行されているか確認
if [[ -z "${CMUX_SOCKET_PATH:-}" ]]; then
    exit 0
fi

# cmux CLI が利用可能か確認
if ! command -v cmux >/dev/null 2>&1; then
    exit 0
fi

# glow が利用可能か確認
if ! command -v glow >/dev/null 2>&1; then
    exit 0
fi

# ワークスペースごとにプレビュー surface を管理
state_dir="/tmp/claude-md-preview"
mkdir -p "$state_dir"
workspace_id="${CMUX_WORKSPACE_ID:-default}"
state_file="${state_dir}/${workspace_id}"

# プレビュー surface が生存しているか確認
surface_alive=false
if [[ -f "$state_file" ]]; then
    preview_surface=$(cat "$state_file")
    if cmux list-panels 2>/dev/null | grep -qF "$preview_surface"; then
        surface_alive=true
    fi
fi

escaped_path=$(printf '%q' "$file_path")

if $surface_alive; then
    # 既存ペインを更新（実行中のプロセスを中断してから再描画）
    cmux send-key --surface "$preview_surface" ctrl-c 2>/dev/null || true
    cmux send --surface "$preview_surface" "clear && glow ${escaped_path}\n"
else
    # 右側に新しいプレビューペインを作成
    preview_surface=$(cmux new-split right | awk '{print $2}')
    echo "$preview_surface" > "$state_file"
    cmux send --surface "$preview_surface" "glow ${escaped_path}\n"
fi

exit 0
