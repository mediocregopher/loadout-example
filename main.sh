#!/bin/bash

# This is to be run by the user (not root) in order for the user to provision
# themself

cd "$(dirname $0)"
set -e
source ./util.sh

loadouts=$@
if [ "$loadouts" = "" ]; then
    loadouts=$(ls -1 ./loadout.d | grep -P '.sh$' | sort -n)
fi

for script in $loadouts; do
    # remove both "./loadout.d/" and "loadout.d/" prefices
    script=${script#./}
    script=${script#loadout.d/}
    info -e "\n---- inlining $script ----"
    source "./loadout.d/$script"
done
