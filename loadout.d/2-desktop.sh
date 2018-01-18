#!/bin/bash

$_SKIPDOCKERBUILD
$_SKIPDOCKERRUN

# Bootloader related (weird place for it, but this only gets used on a full
# desktop install so it kinda makes sense)
install grub efibootmgr syslinux

# Most common video drivers
install xf86-video-ati xf86-video-intel xf86-video-nouveau xf86-video-vesa

# Touchpad driver
install xf86-input-synaptics

# Battery state driver
install acpi

# X
install xorg-server xorg-xinit xorg-xmodmap xorg-xset xorg-xbacklight xterm
install xdg-utils udiskie
lonk X/xinitrc ~/.xinitrc

# Pulseaudio
install pulseaudio pavucontrol

# Slim login manager
install slim
service slim

# Fonts
install ttf-ms-fonts font-bh-ttf sdl2_ttf sdl_ttf ttf-arphic-ukai \
    ttf-arphic-uming ttf-baekmuk ttf-bitstream-vera ttf-cheapskate ttf-dejavu \
    ttf-freebanglafont ttf-freefont ttf-hannom ttf-indic-otf ttf-junicode \
    ttf-khmer ttf-linux-libertine ttf-mph-2b-damase ttf-sazanami \
    ttf-tibetan-machine ttf-tlwg ttf-ubraille opendesktop-fonts ttf-droid \
    ttf-gentium ttf-hanazono ttf-inconsolata ttf-liberation \
    ttf-linux-libertine-g ttf-symbola ttf-ubuntu-font-family
lonk fonts ~/.fonts

# Konsole
lonk konsole/shell-dark.profile ~/.local/share/konsole/shell-dark.profile
lonk konsole/shell-light.profile ~/.local/share/konsole/shell-light.profile
lonk konsole/SolarizedDark.colorscheme ~/.local/share/konsole/SolarizedDark.colorscheme
lonk konsole/SolarizedLight.colorscheme ~/.local/share/konsole/SolarizedLight.colorscheme
install konsole

# Awesome
install awesome vicious i3lock scrot xsel
lonk awesome ~/.config/awesome
service_file awesome/mediocregopher-sysstats.service
gut git@bitbucket.org:mediocregopher/wallpapers.git ~/Wallpapers

# Apps
install chromium vlc eog evince wireshark-gtk slack-desktop
