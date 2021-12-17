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

## ToDo

- check hardware acceleration is working: https://nixos.wiki/wiki/Accelerated_Video_Playback
- TLP or auto cpu freq https://github.com/AdnanHodzic/auto-cpufreq
- systemd-swap and zram
- i3 theming

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
