#!/bin/sh
# Environment variables for the Qt package.
#
# It's best to use the generic directory to avoid
# compiling in a version-containing path:
if [ -d $TQTDIR ]; then
  QTDIR=$TQTDIR
else
  # Find the newest Qt directory and set $QTDIR to that:
  for qtd in $TQTDIR-* ; do
    if [ -d $qtd ]; then
      QTDIR=$qtd
    fi
  done
fi
export QTDIR
