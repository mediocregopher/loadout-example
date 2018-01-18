#!/bin/bash

install google-cloud-sdk

$_SKIPINSTALL # rest of this isn't necessary if SKIPINSTALL is set

info "installing gcloud components"
yes | sudo gcloud components install \
    cbt bigtable pubsub-emulator cloud-datastore-emulator kubectl 2>&1 | \
    bgrep -vP '^$' | \
    bgrep -vP 'All components are up to date.'

info "updating gcloud components"
yes | sudo gcloud components update 2>&1 | \
    bgrep -vP '^$' | \
    bgrep -vP 'All components are up to date.'
