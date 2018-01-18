#!/bin/bash

# This installs everything needed to get the mediocregopher user up and running,
# including the mediocregopher user itself, but absolutely nothing else. It
# should be run as root

cd "$(dirname $0)"
set -e
source ./util.sh

# first thing's first
info "updating EVERYTHING"
PACMAN=1 install -u

info "create user mediocregopher"
if [ ! -e /home/mediocregopher ]; then
    notice "creating user mediocregopher"
    useradd -m mediocregopher
fi

PACMAN=1 install sudo
notice "creating mediocregopher sudoers"
echo 'mediocregopher ALL=(ALL) ALL' > /etc/sudoers.d/mediocregopher

# yaourt, yajl is needed to install it, but yaourt.repo doesn't have it
PACMAN=1 install yajl
PACMAN=1 install --config base/yaourt.repo yaourt

# copy loadout into mediocregopher's src
src=/home/mediocregopher/src
if [ ! -d $src ]; then
    notice "creating $src"
    mkdir -p $src
    chown -R mediocregopher:mediocregopher $src
fi
if [ ! -e $src/loadout ]; then
    notice "copying loadout to $src/loadout"
    cp -r "$(dirname $0)" $src/loadout
    chown -R mediocregopher:mediocregopher $src/loadout
fi
