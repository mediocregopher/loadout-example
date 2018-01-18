#!/bin/bash

install docker

info "ensuring $USER is in docker group"
if [ "$(groups | grep docker)" = "" ] ; then
    notice "adding $USER to docker group"
    duso usermod -G docker "$USER"
fi
