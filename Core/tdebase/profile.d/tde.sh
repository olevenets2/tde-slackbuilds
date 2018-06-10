#!/bin/sh
# TDE additions:
TDEDIR={INSTALL_TDE}
export TDEDIR
if [ ! "$XDG_CONFIG_DIRS" = "" ]; then
  XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:{SYS_CNF_DIR}/xdg
else
  XDG_CONFIG_DIRS=/etc/xdg:{SYS_CNF_DIR}/xdg
fi
export XDG_CONFIG_DIRS
