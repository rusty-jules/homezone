#!/bin/sh

if ! [[ "$1" > 0  ||  "$1" -le 10000 ]]; then
  echo "brightness must be between 1 and 10000"
  exit 1
fi

pssh -h hosts.txt "echo $1 > /sys/class/backlight/intel_backlight/brightness || echo $1 > /sys/class/backlight/gmux_backlight/brightness"
