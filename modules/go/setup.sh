#!/bin/bash

set -eux

tools=(
    'golang.org/x/tools/cmd/goimports@latest'
    'golang.org/x/tools/gopls@latest'
    'gotest.tools/gotestsum@latest'
)

for tool in "${tools[@]}"; do
    go install "$tool"
done
