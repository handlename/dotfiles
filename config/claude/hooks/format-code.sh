#!/bin/bash

# Code formatter hook for Claude Code
# Formats edited files using appropriate tools based on file extension

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract tool name and file path from the JSON input
tool_name=$(echo "$input" | jq -r '.tool_name // empty')
file_path=""

# Handle different tool types that might edit files
case "$tool_name" in
    "Write"|"Edit"|"MultiEdit")
        if [[ "$tool_name" == "Write" ]]; then
            file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
        elif [[ "$tool_name" == "Edit" ]]; then
            file_path=$(echo "$input" | jq -r '.tool_input.path // empty')
        elif [[ "$tool_name" == "MultiEdit" ]]; then
            # MultiEdit might have multiple files, we'll process the first one for now
            file_path=$(echo "$input" | jq -r '.tool_input.files[0].path // empty')
        fi
        ;;
    *)
        # Not a file editing tool, exit silently
        exit 0
        ;;
esac

# Skip if no file path was found
if [[ -z "$file_path" || "$file_path" == "null" ]]; then
    exit 0
fi

# Skip if file doesn't exist
if [[ ! -f "$file_path" ]]; then
    exit 0
fi

# Get file extension
extension="${file_path##*.}"
extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Format based on file extension
case "$extension_lower" in
    "go")
        # Try goimports first (better than gofmt as it also manages imports)
        if command_exists "go"; then
            if go run golang.org/x/tools/cmd/goimports@latest -w "$file_path"; then
                echo "Formatted $file_path with goimports"
            else
                echo "Error: Failed to format $file_path with goimports" >&2
                exit 1
            fi
        else
            echo "Warning: go not found, skipping Go formatting" >&2
        fi
        ;;

    "rs")
        if command_exists "rustfmt"; then
            if rustfmt "$file_path"; then
                echo "Formatted $file_path with rustfmt"
            else
                echo "Error: Failed to format $file_path with rustfmt" >&2
                exit 1
            fi
        else
            echo "Warning: rustfmt not found, skipping Rust formatting" >&2
        fi
        ;;

    "ts"|"js"|"jsx"|"tsx")
        # Use Biome for JavaScript/TypeScript formatting
        if command_exists "npx"; then
            if npx @biomejs/biome format --write "$file_path"; then
                echo "Formatted $file_path with biome"
            else
                echo "Error: Failed to format $file_path with biome" >&2
                exit 1
            fi
        else
            echo "Warning: npx not found, skipping JavaScript/TypeScript formatting" >&2
        fi
        ;;

    *)
        # Unsupported file type, exit silently
        exit 0
        ;;
esac

exit 0
