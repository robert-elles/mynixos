#!/usr/bin/sh
##!/usr/bin/env bash

lock=$HOME/fprint-disabled

if grep -Fq closed /proc/acpi/button/lid/LID/state &&
   grep -Fxq connected /sys/class/drm/card0-[HD]*/status
then
  touch "$lock"
  systemctl stop fprintd
  systemctl mask fprintd
elif [ -f "$lock" ]
then
  systemctl unmask fprintd
  systemctl start fprintd
  rm "$lock"
fi
