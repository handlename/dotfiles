#!/bin/bash

# Test script for cmux-markdown-preview.sh hook
# cmux 外でも入力パースと判定ロジックをテストできる

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/../../cmux-markdown-preview.sh"
TEST_FILES_DIR="$SCRIPT_DIR/target-files"
TEST_DIR="$SCRIPT_DIR/tmp"

passed=0
failed=0

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

setup_test_files() {
    mkdir -p "$TEST_DIR"
    cp "$TEST_FILES_DIR/test.md" "$TEST_DIR/"
    echo "not markdown" > "$TEST_DIR/test.txt"
    echo "package main" > "$TEST_DIR/test.go"
}

# フックを実行して終了コードを返す
# cmux 外で実行するため、Markdown ファイルでも exit 0（CMUX_SOCKET_PATH チェックで早期終了）になる
run_hook() {
    local json_input=$1
    echo "$json_input" | bash "$HOOK_SCRIPT" 2>/dev/null
    return $?
}

build_json() {
    local tool_name=$1
    local file_path=$2

    if [[ "$tool_name" == "Write" ]]; then
        cat <<EOF
{
  "session_id": "test123",
  "transcript_path": "/tmp/test.jsonl",
  "cwd": "$(pwd)",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "$file_path",
    "content": "test content"
  },
  "tool_response": {
    "filePath": "$file_path",
    "success": true
  }
}
EOF
    elif [[ "$tool_name" == "Edit" ]]; then
        cat <<EOF
{
  "session_id": "test123",
  "transcript_path": "/tmp/test.jsonl",
  "cwd": "$(pwd)",
  "hook_event_name": "PostToolUse",
  "tool_name": "Edit",
  "tool_input": {
    "path": "$file_path",
    "old_string": "old",
    "new_string": "new"
  },
  "tool_response": {
    "success": true
  }
}
EOF
    elif [[ "$tool_name" == "Bash" ]]; then
        cat <<EOF
{
  "session_id": "test123",
  "transcript_path": "/tmp/test.jsonl",
  "cwd": "$(pwd)",
  "hook_event_name": "PostToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "echo hello"
  },
  "tool_response": {
    "stdout": "hello"
  }
}
EOF
    fi
}

assert_exit_code() {
    local description=$1
    local expected=$2
    local actual=$3

    if [[ "$actual" -eq "$expected" ]]; then
        print_status "$GREEN" "  PASS: $description (exit=$actual)"
        passed=$((passed + 1))
    else
        print_status "$RED" "  FAIL: $description (expected exit=$expected, got exit=$actual)"
        failed=$((failed + 1))
    fi
}

test_non_markdown_file_skipped() {
    print_status "$BLUE" "Test: non-markdown file is skipped"

    local json
    json=$(build_json "Write" "$TEST_DIR/test.txt")
    run_hook "$json"
    assert_exit_code "Write .txt file" 0 $?

    json=$(build_json "Write" "$TEST_DIR/test.go")
    run_hook "$json"
    assert_exit_code "Write .go file" 0 $?
}

test_unsupported_tool_skipped() {
    print_status "$BLUE" "Test: unsupported tool is skipped"

    local json
    json=$(build_json "Bash" "$TEST_DIR/test.md")
    run_hook "$json"
    assert_exit_code "Bash tool" 0 $?
}

test_nonexistent_file_skipped() {
    print_status "$BLUE" "Test: nonexistent file is skipped"

    local json
    json=$(build_json "Write" "$TEST_DIR/nonexistent.md")
    run_hook "$json"
    assert_exit_code "nonexistent .md file" 0 $?
}

test_markdown_without_cmux_skipped() {
    print_status "$BLUE" "Test: markdown file without cmux is skipped"

    # CMUX_SOCKET_PATH を未設定にして実行
    local json
    json=$(build_json "Write" "$TEST_DIR/test.md")
    CMUX_SOCKET_PATH="" run_hook "$json"
    assert_exit_code "Write .md without CMUX_SOCKET_PATH" 0 $?

    json=$(build_json "Edit" "$TEST_DIR/test.md")
    CMUX_SOCKET_PATH="" run_hook "$json"
    assert_exit_code "Edit .md without CMUX_SOCKET_PATH" 0 $?
}

test_empty_input_skipped() {
    print_status "$BLUE" "Test: empty/null file path is skipped"

    local json
    json=$(cat <<'EOF'
{
  "session_id": "test123",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {}
}
EOF
)
    run_hook "$json"
    assert_exit_code "empty tool_input" 0 $?
}

main() {
    print_status "$BLUE" "=== cmux-markdown-preview hook tests ==="
    echo

    if [[ ! -f "$HOOK_SCRIPT" ]]; then
        print_status "$RED" "Error: Hook script not found at $HOOK_SCRIPT"
        exit 1
    fi

    chmod +x "$HOOK_SCRIPT"

    print_status "$BLUE" "Setting up test files..."
    setup_test_files
    echo

    test_non_markdown_file_skipped
    echo
    test_unsupported_tool_skipped
    echo
    test_nonexistent_file_skipped
    echo
    test_markdown_without_cmux_skipped
    echo
    test_empty_input_skipped
    echo

    print_status "$BLUE" "=== Results: ${passed} passed, ${failed} failed ==="

    if [[ "$failed" -gt 0 ]]; then
        exit 1
    fi
}

cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

trap cleanup EXIT

main "$@"
