#!/bin/bash

install neovim python-neovim powerline-fonts
lonk nvim ~/.config/nvim

$_SKIPINSTALL
$_SKIPDOCKERBUILD

# neovim plugins
nvim +PlugUpgrade +PlugUpdate +qa

# Go-specific linter stuff
nvim --headless '+setf go' '+GoInstallBinaries' +qa
go get -u -v github.com/alecthomas/gometalinter
gometalinter -i # first install any linters which are missing
gometalinter -u # then update the rest
