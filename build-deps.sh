#!/bin/sh

# Copyright 2012  Patrick J. Volkerding, Sebeka, Minnesota, USA
# All rights reserved.
#
# Copyright 2014 Willy Sudiarto Raharjo <willysr@slackware-id.org>
# All rights reserved.
#
# Copyright 2015-2016 Thorn Inurcide thorninurcide@gmail.com
#
# Based on the xfce-build-all.sh script by Patrick J. Volkerding
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# These need to be set here:
INST=1
TMP=${TMP:-/tmp}
ROOT=$(pwd)

## Allow a rebuild of all dependencies,
## even if they are already installed.
##
## Run:
##   REBUILD=yes ./build-deps.sh
REBUILD=${REBUILD:-no}

# Loop for all packages
for dir in \
  Deps/GraphicsMagick \
  Deps/mp4v2 \
  Deps/speex \
  Deps/tqt3 \
  Deps/tqtinterface \
  Deps/arts \
  Deps/dbus-tqt \
  Deps/dbus-1-tqt \
  Deps/tqca-tls \
  Deps/libart_lgpl \
  ; do
  # Get the package name
  package=$(echo $dir | cut -f2- -d /)

  if [ -z "`find /var/log/packages/ -name *$package-*`" ] || [ "${REBUILD}" = "yes" ]; then
    # Change to package directory
    cd $ROOT/$dir || exit 1

    # Get the version
    version=$(cat ${package}.SlackBuild | grep "VERSION:" | head -n1 | cut -d "-" -f2 | rev | cut -c 2- | rev)

    # Get the build
    build=$(cat ${package}.SlackBuild | grep "BUILD:" | cut -d "-" -f2 | rev | cut -c 2- | rev)

    # The real build starts here
    sh ${package}.SlackBuild || exit 1
    if [ "$INST" = "1" ]; then
      PACKAGE=`ls --color=never $TMP/${package}-${version}-*-${build}*.txz`
      if [ -f "$PACKAGE" ]; then
        upgradepkg --install-new --reinstall "$PACKAGE"
      else
        echo "Error:  package to upgrade "$PACKAGE" not found in $TMP"
        exit 1
      fi
    fi

    # back to original directory
    cd $ROOT
  else
    echo "$package already installed."
  fi
done
