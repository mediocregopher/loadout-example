#!/bin/bash

# yaourt config for the user
lonk base/yaourtrc ~/.yaourtrc

# Super basics
install base-devel git mercurial bzr \
    make cmake clang \
    curl wget rsync gnu-netcat nmap dnsutils openssh networkmanager ntp elinks \
    tmux mlocate htop unzip unrar gzip jq \
    go ruby python python-virtualenv python2 python2-virtualenv \
    jre9-openjdk jre8-openjdk jre7-openjdk \
    the_silver_searcher keybase-bin
lonk base/gitconfig ~/.gitconfig

# ssh
lonk base/id_rsa ~/.ssh/id_rsa
lonk base/id_rsa.pub ~/.ssh/id_rsa.pub
lonk base/ssh_config ~/.ssh/config

# Home directories
info "making home directories"
mkdir -p ~/Downloads
mkdir -p ~/src

# bin directory
install curl xsel
lonk bin ~/bin
