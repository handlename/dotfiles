#!/bin/bash

set -eux

script_dir=$(cd $(dirname $0); pwd)

if [[ "$CODESPACES" == 'true' ]]; then
    ${script_dir}/codespaces/install.sh
fi
