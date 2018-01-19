# loadout-example

This repo contains a snapshot of my personal loadout scripts (with secrets all
removed), which I use to provision new personal computers and remote development
instances.

The intention of this repo isn't that someone could use it directly, but instead
to provide it as an example someone could learn and gain ideas from.

# Walkthrough

The underlying assumption of my loadout is that it's being run on an archlinux
(TODO link) system with essentially nothing done besides basic installation.

My loadout is primarly comprised of a set of provisioning scripts which are
found in the `loadout.d` directory. Each script can be run individually or all
of them can be run at once. The other bash files in the root of the directory
comprise the framework in which the loadout scripts run.

## util.sh

### Functions

### Macros

## root.sh

## main.sh

## General strategy

* Link within home directory only
* Use colors to help indicate changes have happened
* Don't allow docker to mess with things inside `/home`

# remote-dev

(refer to blog post)
