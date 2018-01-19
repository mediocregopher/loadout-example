# loadout-example

This repo contains a snapshot of my personal loadout scripts (with secrets all
removed), which I use to provision new personal computers and remote development
instances.

The intention of this repo isn't that someone could use it directly, but instead
to provide it as an example someone could learn and gain ideas from.

# Walkthrough

The underlying assumption of my loadout is that it's being run on an
[archlinux](https://archlinux.org) system with essentially nothing done besides
basic installation.

My loadout is primarly comprised of a set of provisioning scripts which are
found in the `loadout.d` directory. Each script can be run individually or all
of them can be run at once. The other bash files in the root of the directory
comprise the framework in which the loadout scripts run.

## General strategy

There's a couple principles I tried to keep to while writing this system:

* Idempotency. All actions in the scripts should be runnable multiple times, and
  only have an effect the first time they are run.

* Symlinks where possible, but only within the `/home` directory. I
  encrypt my home partition and mount it on login, so symlinking from outside of
  it becomes problematic. Apart from that it makes tweaking my configuration
  much simpler, since I don't have to perform a change in two places (once on
  the system, once in the loadout repo).

* Use colored text to make it easy to see both progress of the scripts and when
  something has actually been changed on the system. All progress messages are
  written out in blue, and everything else in the default (usually white). When
  running I can see at a glance if any changes have been made to the system by
  looking for white text.

## util.sh

This file contains the functions and macros which each loadout script can use,
and form a kind of DSL.

When writing these functions I didn't attempt to copy the functionality of any
existing provisioning system (like ansible or chef), but instead grew the
functions as I wrote the loadout scripts depending on what was actually needed.

## root.sh

This is a small script which is intended to be run as the root user, but which
does as little as possible for that reason. When run this script will:

* Create my non-root user, mediocregopher.
* Install sudo and yaourt (I know pacaur is supposedly better, I haven't
  bothered switching yet).
* Give mediocregopher sudo privileges.
* Copy the loadout repo into mediocregopher's home directory.

At this stage the rest of the loadout can be run via the `main.sh` script as my
non-root user.

## main.sh

This script is also itself small, as it is primarly used to launch one or more
of the scripts in `loadout.d`, and so only contains logic for source-ing
`util.sh` and handing off execution to those loadout scripts.

It can be run in one of two ways. Run without arguments, `./main.sh`, it will
run through all loadout scripts in sequence. Alternatively, one or more specific
loadout scripts can be given to it, `./main.sh loadout.d/{1-base.sh,4-net.sh} to
run those specifically.

# remote-dev

In addition to being used to set up my physical machines this repo is also
equipped to set up docker images containing my loadout. These docker images
don't have all aspects of my loadout set up on them (for example they don't need
network configuration or desktop applications).

I then use the docker image when running my remote development environment,
which is interacted with using the `remote-dev.sh` script. See my [blog
post](TODO) for more on that.
