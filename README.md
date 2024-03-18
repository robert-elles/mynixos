# mynixos
My NixOs configuration

## Install

`cd /home/robert/code`

`git clone https://github.com/robert-elles/mynixos.git`

`nixos-rebuild switch`

`nixos-rebuild boot --flake ~/code/mynixos`


## Links
- [Nix Channel Status](https://status.nixos.org/)
- [Nix PR Tracker](https://nixpk.gs/pr-tracker.html?pr=151023)
- [Run non-nixos executables](https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos)

- https://github.com/NixOS/nixpkgs/issues/169193

## Logs

journalctl --since "5 min ago"
journalctl -u mopidy
journalctl -eu bluetooth

## Useful commands

### GitCrypt - Unlock this repos gpg encrypted secrets

`git-crypt unlock ~/.ssh/gitcrypt_mynixos_key`

`git-crypt status -e`


# Show hide terminal
https://github.com/noctuid/tdrop
https://github.com/gotbletu/shownotes/blob/master/any_term_dropdown.sh


## Fix zoom after update:

`rm -rf ~/.cache/*qt* ~/.cache/zoom* ~/.cache/*qml*`
