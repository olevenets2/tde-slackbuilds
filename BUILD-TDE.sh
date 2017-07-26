#!/bin/sh

export TMPVARS=/tmp/build/vars
if [ ! -d $TMPVARS ]; then
  mkdir -p $TMPVARS
fi

dialog --no-shadow --colors --title " Introduction " --msgbox \
"\n
 This is the set up script for TDE SlackBuilds on Slackware 14.2 for setting user preferences and options.
\n\n
 Source archives must be placed in the 'src' directory or will be downloaded during the build from a geoIP located mirror site.
\n\n
 A package build list is created and successfully built and installed packages are removed from that list as the build progresses.
\n\n
 US English is the default language and support for additional languages can be added.
\n\n
 There is an option to abort the build on the final setup screen - so just run through the options and familiarize yourself with them before an actual build. " \
21 75


rm -f $TMPVARS/build-new
dialog --yes-label "Re-use" --no-label "New" --defaultno --no-shadow --colors --title " TDE Build " --yesno \
"\n
Select \Zr\Z4\ZbNew\Zn if:
\n
               This is a new build - OR
\n
               Additional packages are being built
\n
\Zr\Z4\ZbNew\Zn will delete any previous build list.
\n\n
Selecting \Z1R\Zb\Z0e-use\Zn avoids having to create the build list again when re-running the build for any SlackBuilds that failed." \
13 75
[[ $(echo $?) == 0 ]] && echo no > $TMPVARS/build-new
[[ $(echo $?) == 1 ]] && rm $TMPVARS/TDEbuilds 2> /dev/null


build_core()
{
# Copyright 2012  Patrick J. Volkerding, Sebeka, Minnesota, USA
# All rights reserved.
#
# Copyright 2014 Willy Sudiarto Raharjo <willysr@slackware-id.org>
# All rights reserved.
#
# Copyright 2015-2017 Thorn Inurcide
# Copyright 2015-2017 tde-slackbuilds project on GitHub
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
export LIBPNG_TMP=$TMP
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


rm -f $TMPVARS/COMPILER
dialog --nocancel --no-shadow --colors --title " Select The Compiler You Wish To Use " --menu \
"\n
Here you can select the compiler you wish to use to compile TDE. 
\n
Your choices are \Zb\Z3GCC\Zn and \Zb\Z3Clang\Zn
\n\n
This is a matter of personal preference and not a necessity, but the option exist.
\n\n
If you're not sure which to select, you should probably just use \Zb\Z3GCC\Zn.
\n\n
Please note: the corresponding \Zb\Z3C++\Zn compiler will be chosen for you based on your \Zb\Z3C\Zn compiler selection.
\n\n	
So if you choose \Zb\Z3GCC\Zn, the \Zb\Z3g++\Zn compiler will be used. And if you choose \Zb\Z3Clang\Zn then \Zb\Z3clang++\Zn will be used.
\n\n" \
25 77 2 \
"gcc" "GCC" \
"clang" "Clang" \
2> $TMPVARS/COMPILER

# Lets try redirector
#rm -f $TMPVARS/TDE_MIRROR
#dialog --nocancel --no-shadow --colors --title " TDE Source Mirror Site " --menu \
#"\n
#Source archives can be pre-downloaded and placed in the 'src' directory or downloaded as required during the build from a TDE mirror.
#\n
#The mirror will only be used if the source is not available in 'src'.
#\n\n
#[Non-TDE apps are included in \Zb\Z3TDE Packages Selection\Zn options under
#\n
# Misc and can also be downloaded during the build from their own
#\n
# source URLs which are embedded in the SlackBuild script.]
#\n\n
#This list of mirrors, which could change, is @
#\n
#  https://www.trinitydesktop.org/mirrorstatus.php
#\n\n" \
#23 75 5 \
#"tde-mirror.yosemite.net/trinity" "USA" \
#"mirrorservice.org/sites/trinitydesktop.org/trinity" "UK" \
#"mirror.ntmm.org/trinity" "Sweden" \
#"bg1.mirror.trinitydesktop.org/trinity" "Bulgaria" \
#"ftp.fau.de/trinity" "Germany" \
#2> $TMPVARS/TDE_MIRROR


rm -f $TMPVARS/NUMJOBS
dialog --nocancel --no-shadow --colors --title " Parallel Build " --inputbox \
"\n
Set the number of simultaneous jobs for make to whatever your system will support.
\n\n" \
11 75 -j6 \
2> $TMPVARS/NUMJOBS


rm -f $TMPVARS/I18N
EXITVAL=2
until [[ $EXITVAL -lt 2 ]] ; do
dialog --nocancel --no-shadow --colors --help-button --help-label "README" --title " Select Additional Languages " --inputbox \
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
2> $TMPVARS/I18N && break
[[ $EXITVAL == 2 ]] && dialog --defaultno --yes-label "Ascii" --no-label "Continue" --no-shadow --colors --no-collapse --yesno \
"\n
If you can see the two 'y' like characters, then you've probably got
\na suitable terminal font installed and can choose \Zr\Z4\ZbContinue\Zn,
\notherwise choose \Z1A\Zb\Z0scii\Zn.
\n\n
                            <<\Z3\Zb ҷ ɣ \Zn>>
\n\n
$(echo -e "\Zb\Z0A suitable font in a utf8 enabled terminal is needed to display all the extended characters in this list. Liberation Mono in an 'xterm' is known to work. Setting up a 'tty' is not worth the effort.\Zn")
\n\n" \
15 75
EXVAL=$?
[[ $EXVAL == 1 ]] && dialog --no-shadow --colors --no-collapse --msgbox \
"\n
\Zb\Z2PgDn/PgUp to scroll\Zn
\n\n
$(xzless Core/tde-i18n/langcodes.xz | tr "\n" X | sed 's|X|\\n|g;s|Latn\t|Latn|g')
\n\n" \
26 75
[[ $EXVAL == 0 ]] && dialog --no-shadow --colors --no-collapse --msgbox \
"\n
\Zb\Z2PgDn/PgUp to scroll\Zn
\n\n
$(xzless Core/tde-i18n/langcodes.xz |sed 's|\t\+|\t|g'|cut -f 1,3-| tr "\n" X | sed 's|X|\\n|g;s|\t|\t\t|g;s|cyrillic\t|cyrillic|g;s|Latn\t|Latn|g')
\n\n" \
26 75
done


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


rm $TMPVARS/PREPEND
EXITVAL=2
until [[ $EXITVAL -lt 2 ]] ; do
dialog --no-shadow --yes-label "Prepend" --help-button --help-label "README" --no-label "Default" --colors --defaultno --title " Libraries Search Path " --yesno \
"\n
Select \Z1P\Zb\Z0repend\Zn to add the TDE libs paths to the beginning of the search path.
\n\n
Try \Zr\Zb\Z4Default\Zn first - in most cases this will work.
\n\n" \
10 75
EXITVAL=$?
[[ $EXITVAL == 0 ]] && echo yes > $TMPVARS/PREPEND
[[ $EXITVAL == 1 ]] && 2> $TMPVARS/PREPEND
[[ $EXITVAL == 2 ]] && dialog --no-shadow --colors --msgbox \
"\n
The default with the tqt3 build is to append the TDE lib paths to /etc/ld.so.conf.
\n\n
This means that TDE libs will be at the end of the search path. If the package configuration sets up the search path without using the shell variables set up in this script, those TDE libs will not be used if a library of the same name exists - a conflict which could arise if another DE is installed.
\n\n
If you experience any problems of this nature, then try the \Z1P\Zb\Z0repend\Zn option, which will set up doinst.sh for tqt3 to add the TDE libs paths to the beginning of the search path.
\n\n
 Then \Zb\Z2rebuild tqt3\Zn. This build option only applies to that package.
\n\n" \
 20 75
done
export PREPEND=$(cat $TMPVARS/PREPEND)


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
"Deps/avahi-tqt" "Avahi support" off "\Zb\Z6 Requires Avahi  \Zn" \
"Core/tdelibs" "\Zb\Zr\Z4R\Zn TDE libraries" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Core/tdebase" "\Zb\Zr\Z4R\Zn TDE base" ${SELECT:-off} "\Zb\Z6   \Zn" \
"Core/tdeutils" "Collection of utilities including ark" off "\Zb\Z6   \Zn" \
"Core/tdemultimedia" "Multimedia packages for TDE" off "\Zb\Z6   \Zn" \
"Core/tdeartwork" "Extra artwork/themes/wallpapers for TDE" off "\Zb\Z6   \Zn" \
"Core/tdegraphics" "Misc graphics apps" off "\Zb\Z6   \Zn" \
"Core/tdegames" "Games for TDE - atlantik, kasteroids, katomic, etc." off "\Zb\Z6   \Zn" \
"Deps/libcaldav" "Calendaring Extensions to WebDAV" off "\Zb\Z6 Optional dependency for korganizer [tdepim] \Zn" \
"Deps/libcarddav" "Online address support" off "\Zb\Z6 Optional dependency for korganizer [tdepim] \Zn" \
"Core/tdepim" "Personal Information Management" off "\Zb\Z6   \Zn" \
"Core/tdeaddons" "Additional plugins and scripts" off "\Zb\Z6   \Zn" \
"Core/tdesdk" "Tools used by TDE developers" off "\Zb\Z6 Requires tdepim \Zn" \
"Core/tdevelop" "TDE development programs" off "\Zb\Z6 Requires tdesdk  \Zn" \
"Core/tdetoys" "TDE Amusements" off "\Zb\Z6   \Zn" \
"Core/tdeedu" "Educational software" off "\Zb\Z6   \Zn" \
"Core/tdewebdev" "Quanta Plus and other applications" off "\Zb\Z6   \Zn" \
" Misc/tidy-html5" "Corrects and cleans up HTML and XML documents" off "\Zb\Z6 Runtime option for Quanta+ [tdewebdev] \Zn" \
" Misc/speex" "Audio compression format designed for speech" off "\Zb\Z6 Buildtime option for tdenetwork and amarok. Requires l/speexdsp  \Zn" \
"Core/tdenetwork" "Networking applications for TDE" off "\Zb\Z6 Optional build-time dependency - speex \Zn" \
"Core/tdeadmin" "System admin packages" off "\Zb\Z6  \Zn" \
"Core/tdeaccessibility" "Accessibility programs" off "\Zb\Z6  \Zn" \
"Core/tde-i18n" "Additional language support for TDE" off "\Zb\Z6 Required when \Zb\Z3Additional language support\Zb\Z6 has been selected \Zn" \
"Libs/tdelibkdcraw" "Decode RAW picture files" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel \Zn" \
"Libs/tdelibkexiv2" "Library to manipulate picture metadata" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel. Needs l/exiv2... \Zn" \
"Libs/tdelibkipi" "A common plugin structure" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel \Zn" \
"Libs/kipi-plugins" "Additional functions for digiKam, ksquirrel and gwenview" off "\Zb\Z6 Required for digikam, tdegwenview and ksquirrel. Requires tdelibkdcraw tdelibkexiv2 tdelibkipi. \Zn" \
" Misc/xmedcon" "A medical image conversion utility & library" off "\Zb\Z6 Buildtime option for libksquirrel \Zn" \
"Libs/libksquirrel" "A set of image codecs for KSquirrel" off "\Zb\Z6 Required for ksquirrel. Buildtime options include l/netpbm, t/transfig [fig2dev], Misc/xmedcon \Zn" \
"Apps/abakus" "PC calculator" off "\Zb\Z6 optional dependency l/mpfr which requires l/gmp \Zn" \
" Misc/libmp4v2" "Create and modify mp4 files" off "\Zb\Z6 Buildtime option for Amarok  \Zn" \
" Misc/yauap" "simple commandline audio player" off "\Zb\Z6 Provides an optional engine for Amarok \Zn" \
"Apps/tdeamarok" "A Music Player" off "\Zb\Z6 Optional dependencies - xine-lib, libmp4v2, speex, moodbar \Zn" \
" Misc/moodbar" "GStreamer plugin for Amarok for moodbar feature" off "\Zb\Z6 Runtime option for Amarok \Zn" \
"Apps/digikam" "A digital photo management application + Showfoto viewer" off "\Zb\Z6 Requires kipi-plugins tdelibkdcraw tdelibkexiv2 tdelibkipi.  \Zn" \
"Apps/dolphin" "Dolphin file manager for TDE" off "\Zb\Z6 A d3lphin.desktop file is included - see dolphin.SlackBuild.  \Zn" \
"Apps/tdefilelight" "Graphical diskspace display" off "\Zb\Z6 Runtime requirement x/xdpyinfo \Zn" \
"Apps/gtk-qt-engine" "A GTK+2 theme engine" off "\Zb\Z6   \Zn" \
"Apps/gtk3-tqt-engine" "A GTK+3 theme engine" off "\Zb\Z6   \Zn" \
"Apps/tdegwenview" "An image viewer" off "\Zb\Z6 Requires kipi-plugins tdelibkdcraw tdelibkexiv2 tdelibkipi.  \Zn" \
"Apps/tdegwenview-i18n" "Internationalization files for gwenview." off "\Zb\Z6 Required for tdegwenview when \Zb\Z3Additional language support\Zb\Z6 has been selected  \Zn" \
"Apps/tdek3b" "The CD Creator" off "\Zb\Z6   \Zn" \
"Apps/tdek3b-i18n" "Internationalization files for tdek3b." off "\Zb\Z6 Required for tdek3b when \Zb\Z3Additional language support\Zb\Z6 has been selected  \Zn" \
"Apps/k9copy" "A DVD backup utility" off "\Zb\Z6 Requires tdek3b and ffmpeg \Zn" \
"Apps/kbookreader" "Twin-panel text files viewer esp. for reading e-books." off "\Zb\Z6   \Zn" \
"Apps/kile" "A TEX and LATEX source editor and shell" off "\Zb\Z6   \Zn" \
"Apps/knemo" "The TDE Network Monitor" off "\Zb\Z6   \Zn" \
"Apps/knights" "A graphical chess interface" off "\Zb\Z6   \Zn" \
"Apps/knmap" "A graphical nmap interface" off "\Zb\Z6 Might need tdesudo \Zn" \
" Misc/GraphicsMagick" "Swiss army knife of image processing" off "\Zb\Z6 Buildtime option for chalk[krita]  \Zn" \
"Apps/koffice" "Office Suite" off "\Zb\Z6 Optional build-time dependencies - GraphicsMagick/libpng14 [for chalk/krita]  \Zn" \
"Apps/koffice-i18n" "Internationalization files for koffice" off "\Zb\Z6 Required for koffice when \Zb\Z3Additional language support\Zb\Z6 has been selected  \Zn" \
"Apps/ksensors" "A graphical interface for sensors" off "\Zb\Z6 Runtime requirement ap/lm_sensors \Zn" \
"Apps/kscope" "A source-editing environment for C and C-style languages." off "\Zb\Z6 Runtime options cscope [d/cscope], ctags [ap/vim], dot [graphviz] \Zn" \
" Misc/graphviz" "Graph Visualization" off "\Zb\Z6 Runtime option for kscope. pdf/html docs not built by default  \Zn" \
"Apps/kshutdown" "Shutdown utility for TDE" off "\Zb\Z6   \Zn" \
"Apps/ksquirrel" "An image viewer with OpenGL and KIPI support." off "\Zb\Z6 Requires kipi-plugins tdelibkdcraw tdelibkexiv2 tdelibkipi libksquirrel. \Zn" \
"Apps/kvpnc" "TDE frontend for various vpn clients" off "\Zb\Z6 Miscellaneous documentation will be in $(cat $TMPVARS/INSTALL_TDE)/doc/kvpnc-$(cat $TMPVARS/TDEVERSION)  \Zn" \
"Apps/tdektorrent" "A BitTorrent client for TDE" off "\Zb\Z6   \Zn" \
"Apps/kaffeine" "Media player for TDE" off "\Zb\Z6   \Zn" \
"Apps/rosegarden" "Audio sequencer and musical notation editor" off "\Zb\Z6 Requires jack-audio-connection-kit liblo and dssi for proper funtionality \Zn" \
"Apps/kbfx" "Alternate menu for TDE" off "\Zb\Z6   \Zn" \
" Misc/potrace" "For tracing bitmaps to a vector graphics format" off "\Zb\Z6 Required for potracegui \Zn" \
"Apps/potracegui" "A GUI for potrace" off "\Zb\Z6 Requires potrace \Zn" \
"Apps/tde-style-lipstik" "lipstik theme" off "\Zb\Z6   \Zn" \
"Apps/tde-style-qtcurve" "QtCurve theme" off "\Zb\Z6   \Zn" \
"Apps/tdeio-locate" "TDE frontend for the locate command" off "\Zb\Z6   \Zn" \
"Apps/tdesudo" "Graphical frontend for the sudo command" off "\Zb\Z6   \Zn" \
"Apps/twin-style-crystal" "twin theme" off "\Zb\Z6   \Zn" \
"Apps/tdmtheme" "tdm theme editor module" off "\Zb\Z6   \Zn" \
"Apps/kdbg" "GUI for gdb using TDE" off "\Zb\Z6   \Zn" \
"Apps/yakuake" "Quake-style terminal emulator" off "\Zb\Z6   \Zn" \
"Apps/soundkonverter" "frontend to various audio converters" off "\Zb\Z6   \Zn" \
"Apps/krusader" "File manager for TDE" off "\Zb\Z6   \Zn" \
"Apps/piklab" "IDE fot PIC microcontrollers" off "\Zb\Z6   \Zn" \
"Apps/kdbusnotification" "A DBUS notification to TDE interface" off "\Zb\Z6   \Zn" \
"Apps/kvkbd" "A virtual keyboard for TDE" off "\Zb\Z6   \Zn" \
" Misc/inkscape" "SVG editor" off "\Zb\Z6 Requires lxml if online help facility is required. \Zn" \
" Misc/lxml" "Python bindings for libxml2 and libxslt" off "\Zb\Z6 Required to use Inkscape online help \Zn" \
2> $TMPVARS/TDEbuilds
# successful builds are removed from the TDEbuilds list by '$dir ' so add a space to the last entry
# and the " needs to be removed because the Misc entries are double-quoted
sed -i -e 's|$| |' -e 's|"||g' $TMPVARS/TDEbuilds


## only run this if building koffice has been selected
[[ $(sed 's|koffice-||' $TMPVARS/TDEbuilds | grep -o Apps/koffice) ]] && \
{
rm -f $TMPVARS/Krita_OPTS
dialog --nocancel --no-shadow --colors --title " Building chalk in koffice " --item-help --checklist \
"\n
There are three options that can be set up for building the imaging app in koffice.
\n\n
[1] It is called \Zb\Z3chalk\Zn in TDE but is known as \Zb\Z3krita\Zn most other places.
\n\n
[2] .pngs loaded into chalk/krita will crash if it is built with libpng-1.6, but will load if libpng-1.4 is used for the build.
\n
  If libpng is chosen here, it will be added to the build list and the package placed in $TMP - not installed. It will then be installed by koffice.SB if the libpng unversioned headers and libs are not linked to libpng14.
\n
  The koffice.SB will restore those links to libpng16 when the build has finished or failed.
\n\n
[3] GraphicsMagick will enable an extended range of image formats to be loaded and saved. ImageMagick should be an alternative, but building fails with that, so without GM, the range of supported image formats will be limited.
\n
  If GM is chosen here, it will be added to the build list if not already selected or installed." \
30 75 3 \
" krita" "Set the app name to krita" on "\Zb\Z6 otherwise will be \Zb\Z3chalk\Zn" \
" libpng14" "Build with libpng-1.4" on "\Zb\Z6 otherwise will be \Zb\Z3libpng-1.6\Zn" \
" useGM" "Use GraphicsMagick" on "\Zb\Z6  \Zn" \
2> $TMPVARS/Krita_OPTS
## If GM has been selected and isn't in the build list or installed, add it to the build list before koffice
GM_VERSION=$(grep VERSION:- $ROOT/Misc/GraphicsMagick/GraphicsMagick.SlackBuild|cut -d- -f2|cut -d} -f1)
[[ $(cat $TMPVARS/Krita_OPTS) == *useGM* ]] && \
[[ $(cat $TMPVARS/TDEbuilds) != *GraphicsMagick* ]] && \
[[ ! $(ls /var/log/packages/GraphicsMagick-${GM_VERSION}* 2>/dev/null) ]] && \
sed -i 's|Apps/koffice|Misc/GraphicsMagick &|' $TMPVARS/TDEbuilds
## If libpng-1.4 has been selected and hasn't already been built, add it to the build list before koffice
PNG_VERSION=$(grep VERSION:- $ROOT/Misc/libpng/libpng.SlackBuild|cut -d- -f2|cut -d} -f1)
[[ $(cat $TMPVARS/Krita_OPTS) == *libpng14* ]] && \
[[ ! $(ls $LIBPNG_TMP/libpng-${PNG_VERSION}-*-1.txz 2>/dev/null) ]] && \
sed -i 's|Apps/koffice|Misc/libpng &|' $TMPVARS/TDEbuilds
}
}

[[ ! -e $TMPVARS/TDEbuilds ]] && run_dialog


# option to change to stop the build when it fails
if [[ $(cat $TMPVARS/build-new) == no ]] 2> /dev/null ; then
if [[ $(cat $TMPVARS/EXIT_FAIL) == "" ]] ; then
if [[ $(cat $TMPVARS/KEEP_BUILD) == no ]] ; then
dialog --defaultno --yes-label "Stop" --no-label "Continue" --no-shadow --colors --title " Action on failure - 2 " --yesno \
"\n
You have chosen to re-use the TDE build list, which now contains only those programs that failed to build.
\n\n
But this script is set to Continue in the event of a failure, which will delete all but the last build record. It will be easier to investigate each failure if the build is stopped when it fails.
\n\n
Do you still want the build to \Zr\Z4\ZbContinue\Zn at a failure
\n
 or change to \Z1S\Zb\Z0top\Zn ?
\n " \
15 75
[[ $(echo $?) == 0 ]] && echo "exit 1" > $TMPVARS/EXIT_FAIL
fi;fi;fi


dialog --yes-label "Start" --no-label "Abort" --no-shadow --defaultno --colors --title " Start TDE Build " --yesno \
"\n
Setup is complete.
\n\n
 \Z1S\Zb\Z0tart\Zn building the packages or \Zr\Z4\ZbAbort\Zn" \
9 75
[[ $(echo $?) == 1 ]] && echo -e "\n\nBuild aborted\n" && exit 1
echo

######################
# there should be no need to make any changes below

export TDEVERSION=$(cat $TMPVARS/TDEVERSION)
export INSTALL_TDE=$(cat $TMPVARS/INSTALL_TDE)
export COMPILER=$(cat $TMPVARS/COMPILER)
# export TDE_MIRROR=$(cat $TMPVARS/TDE_MIRROR)
export TDE_MIRROR=mirror.ppa.trinitydesktop.org/trinity
export NUMJOBS=$(cat $TMPVARS/NUMJOBS)
export I18N=$(cat $TMPVARS/I18N)
export TQT_DOCS=$(cat $TMPVARS/TQT_DOCS)
export EXIT_FAIL=$(cat $TMPVARS/EXIT_FAIL)
export KEEP_BUILD=$(cat $TMPVARS/KEEP_BUILD)
# these exports are for koffice.SB
[[ $(cat $TMPVARS/Krita_OPTS 2>/dev/null) == *krita* ]] && export REVERT=yes
[[ $(cat $TMPVARS/Krita_OPTS 2>/dev/null) == *libpng14* ]] && export USE_PNG14=yes

# See which compiler was selected and use the appropriate C++ compiler
[[ $(cat $TMPVARS/COMPILER) == gcc ]] && export COMPILER_CXX="g++" || export COMPILER_CXX="clang++"

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
|| { [[ $dir == Apps* ]] && export TDEMIR_SUBDIR="/applications"; } \
|| { [[ $dir == *Misc* ]] && export TDEMIR_SUBDIR="misc"; } # used for untar_fn - leading slash deliberately omitted

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

checkinstall ()
{
## test for what package is being built .. 
## if it's not libpng, test for the package installed
## otherwise test for the libpng package only, not installed
{
{
[[ ${package} != libpng ]] && [[ $(ls /var/log/packages/${package}-*$(eval echo $version)-*-${build}* 2>/dev/null) ]]
} || {
[[ ${package} == libpng ]] && [[ $(ls $LIBPNG_TMP/${package}-$(eval echo $version)-*-${build}*.txz 2>/dev/null) ]]
}
} && \
## if either test is successful, the above will exit 0, then remove 'package' from the build list \
sed -i "s|$dir ||" $TMPVARS/TDEbuilds || \
## if unsuccessful, display error message \
{
echo "
      Error:  ${package} package build failed
      Check the build log $TMP/${package}-build-log
      "
## if koffice was building with libpng14, restore the libpng16 headers for any following builds
[[ ${USE_PNG14:-} == yes ]] && source $ROOT/get-source.sh && libpng16_fn || true
${EXIT_FAIL:-":"}
}
}
# tde-i18n package installation is handled in tde-i18n.SlackBuild because if more than one i18n package is being built, only the last one will be installed by upgradepkg
## tidy-html5 is a special case because the version number is not in the archive name
## create libpng-1.4 package only - it will be installed by the koffice.SB because it overrides libpng headers which for Sl14.2/current point to libpng16.
[[ ${package} == tidy-html5 ]] && version=$(unzip -c tidy-html5-master.zip | grep -A 1 version.txt | tail -n 1)
if [[ $INST == 1 ]] && [[ ${package} != tde-i18n ]] && [[ ${package} != libpng ]]; then upgradepkg --install-new --reinstall $TMP/${package}-$(eval echo $version)-*-${build}*.txz
checkinstall
## test for last language in the I18N list to ensure they've all been built
elif [[ $INST == 1 ]] && [[ ${package} == tde-i18n ]]; then package=${package}-$(cat $TMPVARS/LASTLANG)
checkinstall
elif [[ ${package} == libpng ]]; then checkinstall
fi

  # back to original directory
  cd $ROOT
done
}

build_core || ${EXIT_FAIL:-"true"}

