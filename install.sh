#!/bin/bash

set -eux

if [[ "$CODESPACES" == 'true' ]]; then
    ./codespaces/install.sh
fi
