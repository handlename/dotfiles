#!/bin/bash

set -eux

tools=(
    'github.com/go-delve/delve/cmd/dlv@latest'
    'golang.org/x/tools/cmd/goimports@latest'
    'golang.org/x/tools/gopls@latest'
    'gotest.tools/gotestsum@latest'
)

for tool in "${tools[@]}"; do
    go install "$tool"
done
