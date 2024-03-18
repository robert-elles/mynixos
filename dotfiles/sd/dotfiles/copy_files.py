#!/usr/bin/env python3

# script to copy  the  config  files  from  the  home  directory  to  the  dotfiles  directory

from pathlib import Path
import shutil
import os
from distutils.dir_util import copy_tree

plasma_setting_files = """
".config/akregatorrc"
".config/baloofileinformationrc"
".config/baloofilerc"
".config/bluedevilglobalrc"
".config/device_automounter_kcmrc"
".config/dolphinrc"
".config/filetypesrc"
".config/gtkrc"
".config/gtkrc-2.0"
".config/kactivitymanagerd-pluginsrc"
".config/kactivitymanagerd-statsrc"
".config/kactivitymanagerd-switcher"
".config/kactivitymanagerdrc"
".config/katemetainfos"
".config/katerc"
".config/kateschemarc"
".config/katevirc"
".config/kcmfonts"
".config/kcminputrc"
".config/kconf_updaterc"
".config/kded5rc"
".config/kdeglobals"
".config/kgammarc"
".config/kglobalshortcutsrc"
".config/khotkeysrc"
".config/kmixrc"
".config/konsolerc"
".config/kscreenlockerrc"
".config/ksmserverrc"
".config/ksplashrc"
".config/ktimezonedrc"
".config/kwinrc"
".config/kwinrulesrc"
".config/kxkbrc"
".config/partitionmanagerrc"
".config/plasma-localerc"
".config/plasma-nm"
".config/plasma-org.kde.plasma.desktop-appletsrc"
".config/plasmanotifyrc"
".config/plasmarc"
".config/plasma-localerc"
".config/plasmashellrc"
".config/PlasmaUserFeedback"
".config/plasmawindowed-appletsrc"
".config/plasmawindowedrc"
".config/powermanagementprofilesrc"
".config/spectaclerc"
".config/startkderc"
".config/systemsettingsrc"
".config/Trolltech.conf"
".config/user-dirs.dirs"
".config/user-dirs.locale"
".local/share/krunnerstaterc"
".local/share/user-places.xbel"
".local/share/user-places.xbel.bak"
".local/share/user-places.xbel.tbcache"

".local/share/applications/playerctl.desktop"
".local/share/applications/playerctl-2.desktop"
".local/share/applications/playerctl-4.desktop"
"""

plasma_setting_dirs = """
".config/gtk-3.0"
".config/gtk-4.0"
".config/xsettingsd"
".config/autostart
".kde"
"""

home = "/home/robert/"
dest_base = "/home/robert/code/mynixos/dotfiles/"

remove_files = True


def touch(config_file):
    basedir = os.path.dirname(config_file)
    if not os.path.exists(basedir):
        os.makedirs(basedir)
    with open(config_file, 'a'):
        os.utime(basedir, None)


for line in plasma_setting_files.splitlines():
    filename = line.strip().replace('"', '')
    if not filename:
        continue
    file = home + filename
    src_path = Path(file)
    dest_dir = dest_base + filename
    if src_path.is_file():
        if not os.path.exists(dest_dir):
            try:
                shutil.copyfile(file, dest_dir)
                if remove_files:
                    os.remove(file)
            except IOError as io_err:
                os.makedirs(os.path.dirname(dest_dir))
                shutil.copyfile(file, dest_dir)
                if remove_files:
                    os.remove(file)
    else:
        print("does not exist but will be created: " + filename)
    touch(dest_dir)

for line in plasma_setting_dirs.splitlines():
    dir_name = line.strip().replace('"', '')
    if not dir_name:
        continue
    print(dir_name)
    src_dir = home + dir_name
    src_path = Path(src_dir)
    if src_path.is_dir():
        dest_dir = dest_base + dir_name
        if not os.path.exists(dest_dir):
            copy_tree(src_dir, dest_dir)
            if remove_files:
                shutil.rmtree(src_dir)
    else:
        print("does not exist: " + src_dir)
