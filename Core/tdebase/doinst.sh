# Save old config files:
if [ ! -L etc/X11/tdm ]; then
  if [ -d etc/X11/tdm ]; then
    mkdir -p etc/tde/tdm
    cp -a etc/X11/tdm/* etc/tde/tdm
    rm -rf etc/X11/tdm
    ( cd etc/X11 ; ln -sf /etc/tde/tdm tdm )
  fi
elif [ ! -e etc/X11/tdm ]; then
  mkdir -p etc/X11
  ( cd etc/X11 ; ln -sf /etc/tde/tdm tdm )
fi


config() {
  NEW="$1"
  OLD="`dirname $NEW`/`basename $NEW .new`"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
config etc/tde/tdm/tdmrc.new
config etc/tde/tdm/backgroundrc.new

# Update the desktop database:
if [ -x usr/bin/update-desktop-database ]; then
  chroot . /usr/bin/update-desktop-database ${INSTALL_TDE}/share/applications > /dev/null 2>&1
fi

# Update hicolor theme cache:
if [ -d usr/share/icons/hicolor ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    chroot . /usr/bin/gtk-update-icon-cache -f -t ${INSTALL_TDE}/share/icons/hicolor 1> /dev/null 2> /dev/null
  fi
fi

# Update the mime database:
if [ -x usr/bin/update-mime-database ]; then
  chroot . /usr/bin/update-mime-database ${INSTALL_TDE}/share/mime >/dev/null 2>&1
fi


# update PATH
# upgradepkg runs this twice, so even though $TQTDIR/bin will be
# a new PATH, it needs to be tested for the second run
if ! grep ${INSTALL_TDE}/bin /etc/profile
then
echo "PATH=\$PATH:${INSTALL_TDE}/bin:$TQTDIR/bin" >> /etc/profile
else
if ! grep $TQTDIR/bin /etc/profile
then
echo "PATH=\$PATH:$TQTDIR/bin" >> /etc/profile
fi
fi


# update MANPATH
if ! grep ${INSTALL_TDE}/man /etc/profile
then
echo "export MANPATH=\$MANPATH:${INSTALL_TDE}/man" >> /etc/profile
fi


## you may not want to do this ##
# start a 'konsole' with system-wide profile
[[ ! $(grep -x "source /etc/profile" $HOME/.bashrc ) ]] && echo "source /etc/profile" >> $HOME/.bashrc || true
# don't want this
sed -i 's|source /etc/profile.d/mc.sh|#source /etc/profile.d/mc.sh|' $HOME/.bashrc || true
