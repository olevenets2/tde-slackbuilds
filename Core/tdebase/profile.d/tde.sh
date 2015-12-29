#!/bin/sh
# TDE additions:
TDEDIR=/usr
export TDEDIR
if [ ! "$XDG_CONFIG_DIRS" = "" ]; then
  XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:/etc/tde/xdg
else
  XDG_CONFIG_DIRS=/etc/xdg:/etc/tde/xdg
fi
export XDG_CONFIG_DIRS 
