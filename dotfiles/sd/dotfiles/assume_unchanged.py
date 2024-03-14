#!/usr/bin/env python3

import os
import argparse
from pathlib import Path

config = [
    "kdeglobals",
    "kglobalshortcutsrc",
    "plasma-org.kde.plasma.desktop-appletsrc",
    "plasmashellrc",
    "gtkrc",
    "gtkrc-2.0",
    "kconf_updaterc",
    "spectaclerc",
    "bluedevilglobalrc",
    "systemsettingsrc",
    "ktimezonedrc",
    "kactivitymanagerd-switcher",
    "kactivitymanagerd-pluginsrc",
    "dolphinrc",
    "katerc"
]

local_share = [
    "krunnerstaterc",
    "user-places.xbel",
]

git_assume_unchanged = "git update-index --assume-unchanged"
git_assume_unchanged_disable = "git update-index --no-assume-unchanged"

flake_location = os.environ.get("FLAKE")

files = []
for filename in config:
    files.append(f"{flake_location}/../../dotfiles/.config/{filename}")
for filename in local_share:
    files.append(f"{flake_location}/../../dotfiles/.local/share/{filename}")

# change working directory to the flake location
os.chdir(Path(flake_location))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('undo', nargs="?", default=False)
    assume_changed = parser.parse_args().undo
    if assume_changed:
        for file in files:
            os.system(f"{git_assume_unchanged_disable} {file}")
    else:
        for file in files:
            os.system(f"{git_assume_unchanged} {file}")


if __name__ == '__main__':
    main()
