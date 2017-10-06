**Building TDE R14.0.4 on the Raspberry Pi3**

BUILD-TDE.sh has been set up with an option to build TDE on the Raspberry Pi3, with [Sarpi](http://sarpi.fatdog.eu/index.php?p=home) supplied kernel/modules/firmware.

All packages build on Slackware current, but because the gcc version is 7.x.x, there have been a number of patches to the source code. Building on Slackware 14.2 has not been completely tested.

Build times are as shown, with the number of parallel jobs set at 8 [1], and with one internationalization locale being included. The build was run with the top off the Pi casing, and the cpu temperature generally remained below 80 °C, occasionally peaking at about 82.5 °C without heatsinks. All four cpus ran @ 1200MHz [2].

<hr>

[1] This may not be the optimum. Based on a sample, builds may be quicker or slower at -j6, some with little difference at -j4, so YMMV. I assume this is because performance is degraded at temperatures in excess of [80 °C](https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md)

[2]
`echo ondemand > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor` if needed.

[3]
Avahi-tqt needs libdaemon and avahi packages installed, and these can be built on the Pi from the SlackBuilds.org scripts.

[4]
inkscape needs too much memory for a build with more than one make process, and using swap slows the build, so the build was done with 'make -j1'.

**Build times**

<pre>
<b>Required</b>:
tqt3                   50:39
tqtinterface            4:26
arts                    6:47
dbus-tqt                  24
dbus-1-tqt                51
libart_lgpl               35
tqca-tls                  22
tdelibs                52:12
tdebase                54:47
                                   2:51:03

<b>Core</b>:
tdeutils               12:29
tdemultimedia          43:46
tdeartwork              4:53
tdegraphics            21:21
tdegames               14:21
libcaldav               1:51
libcarddav              1:18
tdepim               1:00:09
tdeaddons               8:46
tdesdk                 24:38
tdevelop               41:40
tdetoys                 2:13
tdeedu                 36:07
tdewebdev              23:48
tidy-html5              1:19
speex                     47
tdenetwork             38:49
tdeadmin                6:31
tdeaccessibility       10:27
tde-i18n               13:42
                                   6:08:55        8:59:58

<b>Apps/Libs/Misc</b>:
GraphicsMagick          7:08
abakus                  1:05
avahi-tqt [3]           2:16
digikam                32:17
dolphin                 1:18
graphviz               21:36
gtk-qt-engine             46
gtk3-tqt-engine         2:35
inkscape             3:11:11 [4]
k9copy                  5:27
kaffeine                6:28
kbfx                    2:03
kbookreader             1:45
kdbg                    2:26
kdbusnotification       1:36
kile                    5:40
kipi-plugins           13:02
knemo                   2:46
knights                 2:45
knmap                   2:09
koffice              3:40:32
koffice-i18n            1:08
krusader                8:23
kscope                  3:16
ksensors                2:24
kshutdown               2:24
ksquirrel               5:37
kvkbd                   1:51
kvpnc                   8:14
libksquirrel           11:54
libmp4v2                3:21
libpng                    39
lxml                    9:00
moodbar                   37
piklab                 19:18
potrace                 1:09
potracegui              1:53
rosegarden             28:04
soundkonverter          4:42
tde-style-lipstik       1:50
tde-style-qtcurve       1:25
tdeamarok               9:30
tdefilelight              49
tdegwenview             5:31
tdegwenview-i18n        2:20
tdeio-locate              37
tdek3b                  9:25
tdek3b-i18n               30
tdektorrent            13:04
tdelibkdcraw            2:42
tdelibkexiv2            1:51
tdelibkipi              2:25
tdesudo                 1:31
tdmtheme                1:35
twin-style-crystal      1:55
xmedcon                 1:58
yakuake                 2:09
yauap                      5
                                  11:41:57       20:41:55
</pre>



