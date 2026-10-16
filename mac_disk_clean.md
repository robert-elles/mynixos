#!/usr/bin/env bash

sd nixos gc

# docker prune and shrink ranchers linux vm afterwards
# Rancher Factory reset unter Troubleshooting löscht großes diff-disk file <- should be obsolete now
docker system prune -af --volumes && rdctl shell -- sudo fstrim -v /mnt/data

brew cleanup --prune=all

uv cache prune

npm cache clean --force

rm -rf ~/.gradle/caches

go clean -cache -modcache -testcache

rm -rf ~/Library/Caches/node-gyp

# logs
rm -rf ~/Library/Logs/Google ~/Library/Logs/JetBrains \
       ~/Library/Logs/OneDrive ~/Library/Logs/camunda-modeler

Papierkorb leeren

# Andere
- Programme
- Nix config: uninstall unneeded stuff
-
