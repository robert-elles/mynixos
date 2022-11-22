# mynixos
My NixOs configuration

## Install

`cd /etc/nixos/`

`git clone https://github.com/robert-elles/mynixos.git`

`nixos-rebuild switch`

`nixos-rebuild boot --flake /etc/nixos/mynixos`

### Install  kuelap settings

link shell_extras.sh to ~/.config/plasma-workspace/env/

`ln -s /etc/nixos/mynixos/shell_extras.sh ~/.config/plasma-workspace/env/`

source to xprofile:

`echo "source /etc/nixos/mynixos/shell_extras.sh" >> ~/.xprofile`


## Links
Nix Channel Status: https://status.nixos.org/
Nix PR Tracker: https://nixpk.gs/pr-tracker.html?pr=151023
Run non-nixos executables: https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos

- https://github.com/NixOS/nixpkgs/issues/169193

## Logs

journalctl --since "5 min ago"
journalctl -u mopidy
journalctl -eu bluetooth

## Useful commands

### Garbage collect nix:

`nix-collect-garbage -d`

then run

nixos-rebuild switch


### Format nix code

nixfmt file.nix

### Install package from unstable

It is possible to have multiple nix-channels simultaneously. To add the unstable channel with the specifier unstable,

sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable

After updating the channel

sudo nix-channel --update nixos-unstable


# Show hide terminal
https://github.com/noctuid/tdrop
https://github.com/gotbletu/shownotes/blob/master/any_term_dropdown.sh


## Fix zoom after update:

`rm -rf ~/.cache/*qt* ~/.cache/zoom* ~/.cache/*qml*`
