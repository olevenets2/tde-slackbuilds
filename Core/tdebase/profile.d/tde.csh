#!/bin/csh
# TDE additions:
if ( ! $?TDEDIR ) then
    setenv TDEDIR {INSTALL_TDE}
endif
if ( $?XDG_CONFIG_DIRS ) then
    setenv XDG_CONFIG_DIRS $XDG_CONFIG_DIRS:{SYS_CNF_DIR}/xdg
else
    setenv XDG_CONFIG_DIRS /etc/xdg:{SYS_CNF_DIR}/xdg
endif
