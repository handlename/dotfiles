#!/bin/bash

# Simple manual JSON test script for format-code.sh hook
# Tests all supported languages using pre-placed test files

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOOK_SCRIPT="$SCRIPT_DIR/../../format-code.sh"
TEST_FILES_DIR="$SCRIPT_DIR/target-files"
TEST_DIR="$SCRIPT_DIR/tmp"

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Copy pre-placed test files to temporary directory
setup_test_files() {
    mkdir -p "$TEST_DIR"

    if [[ ! -d "$TEST_FILES_DIR" ]]; then
        print_status "$RED" "Error: Test files directory not found at $TEST_FILES_DIR"
        exit 1
    fi

    local files=("test.go" "test.rs" "test.ts" "test.js")

    for file in "${files[@]}"; do
        if [[ -f "$TEST_FILES_DIR/$file" ]]; then
            cp "$TEST_FILES_DIR/$file" "$TEST_DIR/"
            print_status "$GREEN" "✓ Copied $file"
        else
            print_status "$YELLOW" "⚠ Test file not found: $TEST_FILES_DIR/$file"
        fi
    done
}

# Test a single file with JSON input
test_file() {
    local file_path=$1
    local tool_name=$2
    local file_type=$3

    print_status "$BLUE" "Testing $file_type ($file_path)"

    # Check if test file exists
    if [[ ! -f "$file_path" ]]; then
        print_status "$RED" "✗ Test file not found: $file_path"
        return 1
    fi

    # Show file content before
    echo "Before:"
    cat "$file_path" | sed 's/^/  /'

    # Create JSON input
    local json_input
    if [[ "$tool_name" == "Write" ]]; then
        json_input=$(cat <<EOF
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
)
    else
        json_input=$(cat <<EOF
{
  "session_id": "test123",
  "transcript_path": "/tmp/test.jsonl",
  "cwd": "$(pwd)",
  "hook_event_name": "PostToolUse",
  "tool_name": "Edit",
  "tool_input": {
    "path": "$file_path",
    "content": "test content"
  },
  "tool_response": {
    "success": true
  }
}
EOF
)
    fi

    # Run the hook
    local output
    if output=$(echo "$json_input" | bash "$HOOK_SCRIPT" 2>&1); then
        if [[ -n "$output" ]]; then
            print_status "$GREEN" "✓ $output"
        else
            print_status "$YELLOW" "✓ Hook completed (no output)"
        fi
    else
        print_status "$RED" "✗ Hook failed: $output"
    fi

    # Show file content after
    echo "After:"
    cat "$file_path" | sed 's/^/  /'
    echo
}

# Main test function
main() {
    print_status "$BLUE" "=== Manual JSON Test for Format Hook ==="
    echo

    # Check if hook script exists
    if [[ ! -f "$HOOK_SCRIPT" ]]; then
        print_status "$RED" "Error: Hook script not found at $HOOK_SCRIPT"
        exit 1
    fi

    # Make hook script executable
    chmod +x "$HOOK_SCRIPT"

    # Setup test files
    print_status "$BLUE" "Setting up test files..."
    setup_test_files
    echo

    # Test each language (if the test file exists)
    local test_cases=(
        "$TEST_DIR/test.go:Write:Go"
        "$TEST_DIR/test.rs:Edit:Rust"
        "$TEST_DIR/test.ts:Write:TypeScript"
        "$TEST_DIR/test.js:Edit:JavaScript"
    )

    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r file_path tool_name file_type <<< "$test_case"
        if [[ -f "$file_path" ]]; then
            test_file "$file_path" "$tool_name" "$file_type"
        else
            print_status "$YELLOW" "⚠ Skipping $file_type (test file not available)"
            echo
        fi
    done

    print_status "$GREEN" "=== Test Complete ==="
}

# Cleanup function
cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
        print_status "$BLUE" "Cleaned up test files"
    fi
}

# Set up cleanup on exit
trap cleanup EXIT

# Run tests
main "$@"
