sd nixos gc

# docker prune and shrink ranchers linux vm afterwards
# Rancher Factory reset unter Troubleshooting löscht großes diff-disk file <- should be obsolete now
docker system prune -af --volumes && rdctl shell -- sudo fstrim -v /mnt/data

uv cache clean

Papierkorb leeren

# Andere
- Programme
- Nix config: uninstall unneeded stuff
-
