#!/bin/sh

scrot -s "/tmp/shot.png"
IMG=$(cat /tmp/shot.png | curl -F "gob=<-" http://gobin.io 2>/dev/null | head -n1 | xsel -bi; xsel -bo)
notify-send "Screenshot uploaded to $IMG !"
chromium "$IMG"
