#!/bin/bash

set -eux

script_dir=$(cd $(dirname $0); pwd)

function install_packages {
    sudo apt update
    sudo apt-get install -y \
        direnv \
        fzf \
        ripgrep \
        tmux
}

function setup_github {
    cat "${script_dir}/gitconfig" > ~/.gitconfig

    # install gh
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
}

function setup_fish {
    echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_10/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
    curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
    sudo apt update
    sudo apt-get install -y fish

    if [[ ! -e ~/.config/fish ]]; then
        mkdir -p ~/.config
        git clone https://github.com/handlename/config-fish.git ~/.config/fish
    fi

    cat ~/.config/fish/fisher/fishfile | xargs -n1 -I{} fish -c 'fisher install {}'
}

function setup_actionlint {
    local version=1.6.23
    local workdir=/tmp/actionlint

    if which actionlint >/dev/null && actionlint -version | grep "$version" >/dev/null; then
        echo "actionlint v${version} is already installed" >&2
        return
    fi

    mkdir -p "$workdir"
    cd "$workdir"
    curl -sL "https://github.com/rhysd/actionlint/releases/download/v${version}/actionlint_${version}_linux_amd64.tar.gz" | tar xzf -
    sudo install actionlint /usr/local/bin/actionlint
    rm -rf "$workdir"
}

function setup_awscli {
    local workdir=/tmp/awscli
    mkdir -p "$workdir"

    # install session-manager-plugin
    if ! which sesion-manager-plugin >/dev/null; then
        cd "$workdir"
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
        sudo dpkg -i session-manager-plugin.deb
    fi

    rm -rf "$workdir"
}

function setup_ecsta {
    local ecsta_version=0.2.0
    local workdir=/tmp/ecsta
    mkdir -p "$workdir"

    if ! which ecsta >/dev/null; then
        cd "$workdir"
        curl -sL "https://github.com/fujiwara/ecsta/releases/download/v${ecsta_version}/ecsta_${ecsta_version}_linux_amd64.tar.gz" | tar zxf -
        sudo install ecsta /usr/local/bin/ecsta
    fi

    mkdir -p ~/.config/ecsta
    cat << EOH > ~/.config/ecsta/config.json
{
  "filter_command": "fzf",
  "output": "tsv",
  "task_format_query": ""
}
EOH

    rm -rf "$workdir"
}

function setup_zellij {
    local zellij_version=0.40.1
    local workdir=/tmp/zellij
    mkdir -p "$workdir"

    if ! which zellij >/dev/null; then
        cd "$workdir"
        curl -sL "https://github.com/zellij-org/zellij/releases/download/v${zellij_version}/zellij-x86_64-unknown-linux-musl.tar.gz" | tar zxf -
        sudo install zellij /usr/local/bin/zellij
    fi

    mkdir -p ~/.config/zellij
    cp "${script_dir}/../config/zellij/config.kdl" ~/.config/zellij/config.kdl

    rm -rf "$workdir"
}

install_packages
setup_github
setup_fish
setup_actionlint
setup_awscli
setup_ecsta
setup_zellij
