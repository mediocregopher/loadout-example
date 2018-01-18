#!/bin/bash

$_SKIPDOCKERBUILD
$_SKIPDOCKERRUN

# use wicd-patched, wicd-curses isn't broke af supposedly with it
# Also install NetworkManager, since I switch back and forth between the two
install wicd-patched wicd-gtk
install networkmanager network-manager-applet

# ntpd is important I guess
service ntpd
