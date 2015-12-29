#!/bin/csh
# TDE additions:
if ( ! $?TDEDIR ) then
    setenv TDEDIR /usr
endif
if ( $?XDG_CONFIG_DIRS ) then
    setenv XDG_CONFIG_DIRS ${XDG_CONFIG_DIRS}:/etc/tde/xdg
else
    setenv XDG_CONFIG_DIRS /etc/xdg:/etc/tde/xdg
endif
