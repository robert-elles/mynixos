# mynixos
My NixOs configuration

## Install

`cd /etc/nixos/`

`git clone https://github.com/robert-elles/mynixos.git`

`ln -s ./mynixos/configuration.nix ./`

`nixos-rebuild switch`

Helpful Links:
- https://ghedam.at/24353/tutorial-getting-started-with-home-manager-for-nix
- Flakes: https://www.tweag.io/blog/2020-07-31-nixos-flakes/

## Links
Nix Channel Status: https://status.nixos.org/
Nix PR Tracker: https://nixpk.gs/pr-tracker.html?pr=151023
Run non-nixos executables: https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos

## ToDo

- check hardware acceleration is working: https://nixos.wiki/wiki/Accelerated_Video_Playback
- TLP or auto cpu freq https://github.com/AdnanHodzic/auto-cpufreq
- systemd-swap and zram
- i3 theming

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
