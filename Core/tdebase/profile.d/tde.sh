#!/bin/sh
# TDE additions:
TDEDIR=$INSTALL_TDE
export TDEDIR
if [ ! "$XDG_CONFIG_DIRS" = "" ]; then
  XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:/etc/trinity/xdg
else
  XDG_CONFIG_DIRS=/etc/xdg:/etc/trinity/xdg
fi
export XDG_CONFIG_DIRS
