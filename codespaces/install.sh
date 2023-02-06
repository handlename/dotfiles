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

function setup_awscli {
    # install session-manager-plugin
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
    sudo dpkg -i session-manager-plugin.deb
}

function setup_ecsta {
    local ecsta_version=0.2.0

    if ! which ecsta >/dev/null; then
        cd /tmp
        curl -sL "https://github.com/fujiwara/ecsta/releases/download/v${ecsta_version}/ecsta_${ecsta_version}_linux_amd64.tar.gz" | tar zxf -
        sudo install ecsta /usr/local/bin/ecsta
        rm -rf ecsta
        cd -
    fi

    mkdir -p ~/.config/ecsta
    cat << EOH > ~/.config/ecsta/config.json
{
  "filter_command": "fzf",
  "output": "tsv",
  "task_format_query": ""
}
EOH
}

install_packages
setup_github
setup_fish
setup_awscli
setup_ecsta
