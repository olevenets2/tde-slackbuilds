#!/bin/sh

export TMPVARS=/tmp/build/vars
if [ ! -d $TMPVARS ]; then
  mkdir -p $TMPVARS
fi

dialog --no-shadow --colors --title " Introduction " --msgbox \
"\n
 This is the set up script for TDE SlackBuilds on Slackware 14.2 for setting user preferences and options.
\n\n
 Source archives can be stored locally or downloaded during the build from a selected TDE mirror site.
\n\n
 A package build list is created and successfully built and installed packages are removed from that list as the build progresses.
\n\n
 US English is the default language and support for additional languages can be added.
\n\n
 There is an option to abort the build on the final setup screen - so just run through the options and familiarize yourself with them before an actual build. " \
21 75


rm -f $TMPVARS/build-new
dialog --yes-label "New" --no-label "Re-use" --no-shadow --colors --title " TDE Build " --yesno \
"\n
Select \Zr\Z4\ZbNew\Zn if:
\n
This is a new build - OR
\n
Additional packages are being built
\n
 'New' will delete any previous build list.
\n\n
Selecting \Z1R\Zb\Z0e-use\Zn avoids having to create the build list again when re-running the build for any SlackBuilds that failed." \
13 75
[[ $(echo $?) == 0 ]] && rm $TMPVARS/TDEbuilds 2> /dev/null
[[ $(echo $?) == 1 ]] && echo no > $TMPVARS/build-new

build_core()
{
# Copyright 2012  Patrick J. Volkerding, Sebeka, Minnesota, USA
# All rights reserved.
#
# Copyright 2014 Willy Sudiarto Raharjo <willysr@slackware-id.org>
# All rights reserved.
#
# Copyright 2015-2016 Thorn Inurcide
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
export INST=1
TMP=${TMP:-/tmp}
ROOT=$(pwd)


###################################################

# set the shell variables needed for the build
#

run_dialog()
{
rm -f $TMPVARS/TDEVERSION
dialog --nocancel --no-shadow --colors --title " TDE Version " --inputbox \
"\n
Set the version of TDE to be built.
\n\n" \
10 75 R14.0.4 \
2> $TMPVARS/TDEVERSION


rm -f $TMPVARS/INSTALL_TDE
dialog --nocancel --no-shadow --colors --title " TDE Installation Directory " --inputbox \
"\n
Set the directory that TDE is to be installed in.
\n\n" \
10 75 /opt/trinity \
2> $TMPVARS/INSTALL_TDE


rm -f $TMPVARS/TDE_MIRROR
dialog --nocancel --no-shadow --colors --title " TDE Source Mirror Site " --menu \
"\n
Source archives can be pre-downloaded and placed in the 'src' directory or downloaded as required during the build from a TDE mirror.
\n
The mirror will only be used if the source is not available in 'src'.
\n\n
[Non-TDE apps are included in \Zb\Z3TDE Packages Selection\Zn options under
\n
 Misc and can also be downloaded during the build from their own
\n
 source URLs which are embedded in the SlackBuild script.]
\n\n
This list of mirrors, which could change, is @
\n
  https://www.trinitydesktop.org/mirrorstatus.php
\n\n" \
23 75 5 \
"tde-mirror.yosemite.net/trinity" "USA" \
"mirrorservice.org/sites/trinitydesktop.org/trinity" "UK" \
"mirror.ntmm.org/trinity" "Sweden" \
"bg1.mirror.trinitydesktop.org/trinity" "Bulgaria" \
"ftp.fau.de/trinity" "Germany" \
2> $TMPVARS/TDE_MIRROR


rm -f $TMPVARS/NUMJOBS
dialog --nocancel --no-shadow --colors --title " Parallel Build " --inputbox \
"\n
Set the number of simultaneous jobs for make to whatever your system will support.
\n\n" \
11 75 -j6 \
2> $TMPVARS/NUMJOBS


rm -f $TMPVARS/I18N
dialog --nocancel --no-shadow --colors --title " Select Additional Languages " --inputbox \
"\n
 Additional language support
\n\n
 This is the complete list for tde-i18n - and will also apply for other packages.
\n
 Other package sources may not have support for all these additional languages, but they will be included in the build for that package when the translations are included in the source.
\n
 If any other translation is included in the package source, it can be added here but won't be supported by TDE.
\n\n
 Multiple selections may be made - space separated.
\n\n
 Build language packages/support for any of:
\n
\Zb\Z6af ar az be bg bn br bs ca cs csb cy da de el en_GB eo es et eu fa fi fr fy ga gl he hi hr hu is it ja kk km ko lt lv mk mn ms nb nds nl nn pa pl pt pt_BR ro ru rw se sk sl sr sr@Latn ss sv ta te tg th tr uk uz uz@cyrillic vi wa zh_CN zh_TW\Zn
\n\n" \
26 75 \
2> $TMPVARS/I18N


rm -f $TMPVARS/TQT_DOCS
dialog --no-shadow --colors --defaultno --title " TQt html Documentation " --yesno \
"\n
TQt html documentation is ~21M.
\n\n
Include it in the package?
\n\n" \
9 75
[[ $(echo $?) == 0 ]] && echo yes > $TMPVARS/TQT_DOCS
[[ $(echo $?) == 1 ]] && echo no > $TMPVARS/TQT_DOCS


rm -f $TMPVARS/EXIT_FAIL
dialog --defaultno --yes-label "Continue" --no-label "Stop" --no-shadow --colors --title " Action on failure " --yesno \
"\n
Do you want the build to \Zr\Z4\ZbStop\Zn at a failure or \Z1C\Zb\Z0ontinue\Zn to the next SlackBuild?
\n\n
Build logs are $TMP/'program'-build-log, and configure/cmake error logs will be in $TMP/build/tmp-'program'.
\n\n
A practical build method could be:
\n\n
 1] build the \Zb\Zr\Z4R\Znequired packages with the \Zr\Z4\ZbStop\Zn option - if any SlackBuild fails, the temporary files for that build will be kept and the problem can be identified and the build restarted.
\n
Any problems with the build environment will also become apparent here.
\n\n
 2] then build other packages with the \Z1C\Zb\Z0ontinue\Zn option which deletes the temporary build files while the successful package builds are completing.
\n
Any failures here are likely to be related to dependencies not found.
\n\n
 3] re-run the build for the failed programs from [2] by re-using the build list and with the \Zr\Z4\ZbStop\Zn option ...
\n " \
26 75
[[ $(echo $?) == 0 ]] && 2> $TMPVARS/EXIT_FAIL
[[ $(echo $?) == 1 ]] && echo "exit 1" > $TMPVARS/EXIT_FAIL


rm -f $TMPVARS/KEEP_BUILD
dialog --no-shadow --colors --defaultno --title " Temporary Build Files " --yesno \
"\n
'tmp' & 'package' files from a previous package build are removed at the start of building the next package to keep the build area clear.
\n\n
If following the build method on the previous screen, the answer here should probably be \Zr\Z4\ZbNo\Zn.
\n\n
Keep \ZuALL\ZU the temporary files, including for successfully built packages?" \
14 75
[[ $(echo $?) == 0 ]] && echo yes > $TMPVARS/KEEP_BUILD
[[ $(echo $?) == 1 ]] && echo no > $TMPVARS/KEEP_BUILD


rm -f $TMPVARS/SELECT
dialog --no-shadow --colors --defaultno --title " Required dependencies " --yesno \
"\n
Pre-select TDE core modules and required dependencies for the build list?
\n\n
Select \Zr\Zb\Z4No\Zn here if they have already been built and installed and you are building additional packages.
\n\n" \
11 75
[[ $(echo $?) == 0 ]] && echo on > $TMPVARS/SELECT
[[ $(echo $?) == 1 ]] && echo off > $TMPVARS/SELECT
export SELECT=$(cat $TMPVARS/SELECT)


rm -f $TMPVARS/TDEbuilds
dialog --nocancel --no-shadow --colors --title " TDE Packages Selection " --item-help --checklist \
"\n
Required builds for a basic working TDE are marked \Zb\Zr\Z4R\Zn.
\n\n
The packages selected form the build list and so dependencies are listed before the packages that need them.
\n\n
Look out for messages in the bottom line of the screen, especially relating to dependencies.
\n\n
Non-TDE apps are in the Misc category and don't need the \Zb\Zr\Z4R\Znequired TDE packages." \
35 95 19 \
"Deps/tqt3" "\Zb\Zr\Z4R\Zn The Qt package for TDE" ${SELECT:-off} "\Zb\Z6  \Zn" \
"Deps/tqtinterface" "\Zb\Zr\Z4R\Zn TDE bindings to tqt3." ${SELECT:-off} "\Zb\Z6  \Zn" \
"Deps/arts" "\Zb\Zr\Z4R\Zn Sound server for TDE" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Deps/dbus-tqt" "\Zb\Zr\Z4R\Zn A simple IPC library" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Deps/dbus-1-tqt" "\Zb\Zr\Z4R\Zn D-Bus bindings" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Deps/libart_lgpl" "\Zb\Zr\Z4R\Zn The LGPL'd component of libart" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Deps/tqca-tls" "\Zb\Zr\Z4R\Zn Plugin to provide SSL/TLS capability" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Core/tdelibs" "\Zb\Zr\Z4R\Zn TDE libraries" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Core/tdebase" "\Zb\Zr\Z4R\Zn TDE base" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Core/tdeutils" "Collection of utilities including ark" off "\Zb\Z6   \Zn" \
"Core/tdemultimedia" "Multimedia packages for TDE" off "\Zb\Z6   \Zn" \
"Core/tdeartwork" "Extra artwork/themes/wallpapers for TDE" off "\Zb\Z6   \Zn" \
"Core/tdegraphics" "Misc graphics apps" off "\Zb\Z6   \Zn" \
"Core/tdeaddons" "Additional plugins and scripts" off "\Zb\Z6   \Zn" \
"Core/tdegames" "Games for TDE - atlantik, kasteroids, katomic, etc." off "\Zb\Z6   \Zn" \
"Deps/libcaldav" "Calendaring Extensions to WebDAV" off "\Zb\Z6 Optional dependency for korganizer [tdepim] \Zn" \
"Core/tdepim" "Personal Information Management" off "\Zb\Z6   \Zn" \
"Core/tdesdk" "Tools used by TDE developers" off "\Zb\Z6 Requires tdepim \Zn" \
"Core/tdevelop" "TDE development programs" off "\Zb\Z6 Requires tdesdk  \Zn" \
"Core/tdetoys" "TDE Amusements" off "\Zb\Z6   \Zn" \
"Core/tdewebdev" "Quanta Plus and other applications" off "\Zb\Z6   \Zn" \
" Misc/speex" "Audio compression format designed for speech" off "\Zb\Z6 Requires l/speexdsp  \Zn" \
"Core/tdenetwork" "Networking applications for TDE" off "\Zb\Z6 Optional dependency - speex \Zn" \
"Core/tde-i18n" "Additional language support for TDE" off "\Zb\Z6 Required when \Zb\Z3Additional language support\Zb\Z6 has been selected \Zn" \
"Libs/tdelibkdcraw" "Decode RAW picture files" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel \Zn" \
"Libs/tdelibkexiv2" "Library to manipulate picture metadata" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel. Needs l/exiv2... \Zn" \
"Libs/tdelibkipi" "A common plugin structure" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel \Zn" \
"Libs/kipi-plugins" "Additional functions for digiKam, ksquirrel and gwenview" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel. Requires tdelibkdcraw tdelibkexiv2 tdelibkipi. \Zn" \
"Libs/libksquirrel" "A set of image codecs for KSquirrel" off "\Zb\Z6 Required for ksquirrel \Zn" \
"Apps/digikam" "A digital photo management application + Showfoto viewer" off "\Zb\Z6 Requires kipi-plugins tdelibkdcraw tdelibkexiv2 tdelibkipi.  \Zn" \
"Apps/ksquirrel" "An image viewer with OpenGL and KIPI support." off "\Zb\Z6 Requires kipi-plugins tdelibkdcraw tdelibkexiv2 tdelibkipi libksquirrel. \Zn" \
"Apps/tdegwenview" "An image viewer" off "\Zb\Z6 Requires kipi-plugins tdelibkdcraw tdelibkexiv2 tdelibkipi.  \Zn" \
"Apps/tdegwenview-i18n" "Internationalization files for gwenview." off "\Zb\Z6 Required for tdegwenview when \Zb\Z3Additional language support\Zb\Z6 has been selected  \Zn" \
" Misc/libmp4v2" "Create and modify mp4 files" off "\Zb\Z6   \Zn" \
"Apps/tdeamarok" "A Music Player" off "\Zb\Z6  Optional dependencies - libmp4v2, speex \Zn" \
"Apps/tdek3b" "The CD Creator" off "\Zb\Z6   \Zn" \
"Apps/tdek3b-i18n" "Internationalization files for tdek3b." off "\Zb\Z6 Required for tdek3b when \Zb\Z3Additional language support\Zb\Z6 has been selected  \Zn" \
"Apps/k9copy" "A DVD backup utility" off "\Zb\Z6 Requires tdek3b and ffmpeg \Zn" \
"Apps/knemo" "The TDE Network Monitor" off "\Zb\Z6   \Zn" \
"Apps/knights" "A graphical chess interface" off "\Zb\Z6   \Zn" \
"Apps/dolphin" "Dolphin file manager for TDE" off "\Zb\Z6   \Zn" \
"Apps/gtk-qt-engine" "A GTK+2 theme engine" off "\Zb\Z6   \Zn" \
"Apps/gtk3-tqt-engine" "A GTK+3 theme engine" off "\Zb\Z6   \Zn" \
"Apps/kbookreader" "Twin-panel text files viewer esp. for reading e-books." off "\Zb\Z6   \Zn" \
"Apps/tde-style-qtcurve" "QtCurve theme" off "\Zb\Z6   \Zn" \
"Apps/tde-style-lipstik" "lipstik theme" off "\Zb\Z6   \Zn" \
"Apps/twin-style-crystal" "twin theme" off "\Zb\Z6   \Zn" \
"Apps/tdeio-locate" "TDE frontend for the locate command" off "\Zb\Z6   \Zn" \
"Apps/kile" "A TEX and LATEX source editor and shell" off "\Zb\Z6   \Zn" \
"Apps/kshutdown" "Shutdown utility for TDE" off "\Zb\Z6   \Zn" \
" Misc/potrace" "For tracing bitmaps to a vector graphics format" off "\Zb\Z6 Required for potracegui \Zn" \
"Apps/potracegui" "A GUI for potrace" off "\Zb\Z6 Requires potrace \Zn" \
" Misc/GraphicsMagick" "Swiss army knife of image processing" off "\Zb\Z6   \Zn" \
" Misc/tidy-html5" "Corrects and cleans up HTML and XML documents" off "\Zb\Z6 Optional for Quanta+ [tdewebdev] \Zn" \
" Misc/inkscape" "SVG editor" off "\Zb\Z6 Requires lxml if online help facility is required. \Zn" \
" Misc/lxml" "Python bindings for libxml2 and libxslt" off "\Zb\Z6 Required to use Inkscape online help \Zn" \
2> $TMPVARS/TDEbuilds
# successful builds are removed from the TDEbuilds list by '$dir ' so add a space to the last entry
# and the " needs to be removed because the Misc entries are double-quoted
sed -i -e 's|$| |' -e 's|"||g' $TMPVARS/TDEbuilds
}

[[ ! -e $TMPVARS/TDEbuilds ]] && run_dialog


## These are changes to the default SlackBuild where an optional dependency is selected
# If libcaldav is installed, or if building libcaldav for korganizer,
# change option in tdepim.SlackBuild to "ON"
[[ $(ls /var/log/packages/libcaldav*) || $(grep libcaldav $TMPVARS/TDEbuilds) ]] && \
export LCALDAV="ON"


# option to change to stop the build when it fails
if [[ $(cat $TMPVARS/build-new) == no ]] 2> /dev/null ; then
if [[ $(cat $TMPVARS/EXIT_FAIL) == "" ]] ; then
if [[ $(cat $TMPVARS/KEEP_BUILD) == no ]] ; then
dialog --defaultno --yes-label "Continue" --no-label "Stop" --no-shadow --colors --title " Action on failure - 2 " --yesno \
"\n
You have chosen to re-use the TDE build list, which now contains only those programs that failed to build.
\n\n
But this script is set to Continue in the event of a failure, which will delete all but the last build record. Each failure should now be investigated which requires that the build be stopped when it fails.
\n\n
Do you still want the build to \Z1C\Zb\Z0ontinue\Zn at a failure
\n
 or change to \Zr\Z4\ZbStop\Zn ?
\n " \
15 75
[[ $(echo $?) == 1 ]] && echo "exit 1" > $TMPVARS/EXIT_FAIL
fi;fi;fi


dialog --yes-label "Start" --no-label "Abort" --no-shadow --defaultno --colors --title " Start TDE Build " --yesno \
"\n
Setup is complete.
\n\n
 \Z1S\Zb\Z0tart\Zn building the packages or \Zr\Z4\ZbAbort\Zn" \
9 75
[[ $(echo $?) == 1 ]] && echo && echo && echo "Build aborted" && echo && exit 1
echo

######################
# there should be no need to make any changes below

export TDEVERSION=$(cat $TMPVARS/TDEVERSION)
export INSTALL_TDE=$(cat $TMPVARS/INSTALL_TDE)
export TDE_MIRROR=$(cat $TMPVARS/TDE_MIRROR)
export NUMJOBS=$(cat $TMPVARS/NUMJOBS)
export I18N=$(cat $TMPVARS/I18N)
export TQT_DOCS=$(cat $TMPVARS/TQT_DOCS)
export EXIT_FAIL=$(cat $TMPVARS/EXIT_FAIL)
export KEEP_BUILD=$(cat $TMPVARS/KEEP_BUILD)

LIBDIRSUFFIX=""
# Is this a 64 bit system?
# 'uname -m' won't identify a 32 bit system with a 64 bit kernel
[[ -d /lib64 ]] && LIBDIRSUFFIX="64"

TQTDIR=$INSTALL_TDE/lib$LIBDIRSUFFIX/tqt3

CPLUS_INCLUDE_PATH=$TQTDIR/include:${CPLUS_INCLUDE_PATH:-}

PKG_CONFIG_PATH=$INSTALL_TDE/lib$LIBDIRSUFFIX/pkgconfig:${PKG_CONFIG_PATH:-}

PATH=$TQTDIR/bin:$INSTALL_TDE/bin:$PATH

# needed for CMAKE_C_FLAGS
# and used for CFLAGS instead of 'configure --with-qt-includes=' option which doesn't always work
TQT_INCLUDE_PATH="-I$TQTDIR/include"

export LIBDIRSUFFIX
export TQTDIR
export CPLUS_INCLUDE_PATH
export PKG_CONFIG_PATH
export PATH
export TQT_INCLUDE_PATH

######################################################
# package(s) build starts here

# Loop for all packages
for dir in $(cat $TMPVARS/TDEbuilds)
do
   { [[ $dir == Deps* ]] && export TDEMIR_SUBDIR="/dependencies"; } \
|| { [[ $dir == Core* ]] && export TDEMIR_SUBDIR=""; } \
|| { [[ $dir == Libs* ]] && export TDEMIR_SUBDIR="/libraries"; } \
|| { [[ $dir == Apps* ]] && export TDEMIR_SUBDIR="/applications"; }

  # Get the package name
  package=$(echo $dir | cut -f2- -d /)

  # Change to package directory
  cd $ROOT/$dir || ${EXIT_FAIL:-"true"}

  # Get the version
  version=$(cat ${package}.SlackBuild | grep "VERSION:" | head -n1 | cut -d "-" -f2 | rev | cut -c 2- | rev)

  # Get the build
  build=$(cat ${package}.SlackBuild | grep "BUILD:" | cut -d "-" -f2 | rev | cut -c 2- | rev)

  # The real build starts here
  script -c "sh ${package}.SlackBuild" $TMP/${package}-build-log || ${EXIT_FAIL:-"true"}
# remove colorizing escape sequences from build-log
# Re: http://serverfault.com/questions/71285/in-centos-4-4-how-can-i-strip-escape-sequences-from-a-text-file
  sed -ri "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" $TMP/${package}-build-log || ${EXIT_FAIL:-"true"}

# tde-i18n package installation is handled in tde-i18n.SlackBuild because if more than one i18n package is being built, only the last one will be installed by upgradepkg
# Note to self: this alteration appears to fix the problem (Erroing and refusing to compile) BUT makes the script recomnpile it if you run the
# script with re-use even though it is installed
if [[ $INST == 1 ]] && [[ ${package} != tde-i18n ]]; then upgradepkg --install-new --reinstall $TMP/${package}-$(eval echo $version)-*-${build}*.txz
if [[ $(ls /var/log/packages/${package}-*$(eval echo $version)-*-${build}*) ]]; then
sed -i "s|$dir ||" $TMPVARS/TDEbuilds
else
echo "
      Error:  ${package} package build failed
      Check the build log $TMP/${package}-build-log
      "
${EXIT_FAIL:-":"}
fi;fi

  # back to original directory
  cd $ROOT
done
}

build_core || ${EXIT_FAIL:-"true"}

