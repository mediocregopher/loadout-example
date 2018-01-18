#!/bin/bash

install zsh
lonk zsh/aliases ~/.shell_aliases
lonk zsh/gcloud ~/.shell_gcloud
lonk zsh/env ~/.shell_env
lonk zsh/dircolors ~/.dircolors
lonk zsh/oh-my-zsh ~/.oh-my-zsh
lonk zsh/zshrc ~/.zshrc

# ensure that, if this is a first-run of the loadout, all of the PATH stuff gets
# sourced for the rest of the run. This is especially important for the go stuff
# later on
source zsh/env

info "checking shell"
if [ ! "$(getent passwd $LOGNAME | cut -d: -f7)" = "/bin/zsh" ]; then
    notice "setting shell to zsh"
    sudo chsh -s /bin/zsh mediocregopher
fi
