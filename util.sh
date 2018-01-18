#!/bin/bash

_SKIPDOCKERBUILD='eval if [ ! -z "$DOCKERBUILD" ]; then info "(skip because docker build)"; return; fi'
_SKIPDOCKERRUN='eval if [ ! -z "$DOCKERRUN" ]; then info "(skip because docker run)"; return; fi'
_SKIPINSTALL='eval if [ ! -z "$SKIPINSTALL" ]; then info "(skip install)"; return; fi'

function _startcolor {
    echo -en "\e[$1m"
}

function _endcolor {
    echo -en "\e[39m"
}

function _echocolor {
    _startcolor $1
    shift
    echo $@
    _endcolor
}

function info {
    _echocolor 34 $@
}

function notice {
    echo $@
}

function bail {
    code=$1
    shift
    _echocolor 31 $@
    exit $code
}

function bgrep {
    # The --line-buffered's are needed because I guess yaourt never flushes on
    # its own, so grep never would until the input ends
    #
    # The cat is a hack so that the pipe can't exit with 1 if the grep doesn't
    # match
    grep --line-buffered "$@" | cat
}

function bak {
    notice "Backing up $1"
    mv "$1" "$1.bak.$(date +%s)"
}

function lonk {
    info "lonk $1 to $2"
    $_SKIPDOCKERBUILD
    if [ ! -e "$1" ]; then bail 1 "$1 doesn't exist dummy"; fi

    dir=$(dirname "$2")
    mkdir -p "$dir"

    if [ -h "$2" ]; then
        dst=$(readlink "$2")
        if [ "$dst" = "$(pwd)/$1" ]; then return 0; fi
    fi

    # -e might be false for a symlink which is broken, but -h will still be
    # true. If -h is true then the above case covers if it's already the correct
    # destination
    if [ -h "$2" ] || [ -e "$2" ]; then bak "$2"; fi
    notice "linking $(pwd)/$1 to $2"
    ln -s "$(pwd)/$1" "$2"
}

function kp {
    info "kp $1 to $2"
    $_SKIPDOCKERBUILD
    if [ ! -e "$1" ]; then bail 1 "$1 doesn't exist dummy"; fi
    if [ ! -f "$1" ]; then bail 1 "kp only supports files"; fi

    dir=$(dirname "$2")
    mkdir -p "$dir"

    srcHash=$(md5sum "$1" | awk '{print $1}')
    if [ -f "$2" ]; then
        dstHash=$(md5sum "$2" | awk '{print $1}')
    fi

    if [ "$srcHash" != "$dstHash" ]; then
        if [ -e "$2" ]; then bak "$2"; fi
        notice "copying $(pwd)/$1 to $2"
        cp "$1" "$2"
    fi
}

function gut {
    info "gut $1 at $2"
    $_SKIPDOCKERBUILD
    if [ -e "$2" ]; then
        if [ -e "$2/.git" ] && \
           [ "$(cd $2 && git remote get-url origin)" = "$1" ]; \
        then
            (cd $2 && git pull | bgrep -vP '^Already up to date.$')
            return 0
        fi
        bak "$2"
    fi

    notice "cloning $1"
    git clone "$1" "$2"
}

function install {
    info "installing $@"
    $_SKIPINSTALL
    $_SKIPDOCKERRUN

    _installcmd=yaourt
    if [ ! -z "$PACMAN" ]; then _installcmd=pacman; fi
    $_installcmd -Sy --noconfirm --needed "$@" 2>&1 | \
        bgrep -vP 'Synchronizing package databases' | \
        bgrep -vP '^.+is up to date$' | \
        bgrep -vP '^warning:.+skipping$' | \
        bgrep -vP 'there is nothing to do'

    # it'd be nice if we could come up with a bgrep implementation which
    # forwarded the exit status and didn't just always return 0, but until then
    # we have to use PIPESTATUS to retrieve the status from the pipe here
    info "(install returning ${PIPESTATUS[0]})"
    return ${PIPESTATUS[0]}
}

function duso {
    info "sudo $@"
    args="source ./util.sh; $@"
    sudo su -c "$args"
}

# enables and starts a service
function service {
    info "service $1"
    $_SKIPDOCKERBUILD
    $_SKIPDOCKERRUN
    _en_dis=enable
    if [ ! -z "$DISABLED" ]; then _en_dis=disable; fi
    sudo systemctl daemon-reload
    sudo systemctl $_en_dis "$1"
    sudo systemctl start "$1"
}

# links the given service file in, enables the service, and starts it
function service_file {
    info "service_file $1"
    $_SKIPDOCKERBUILD
    $_SKIPDOCKERRUN
    name=$(basename "$1")
    duso kp "$1" "/etc/systemd/system/$name"
    service "$name"
}
