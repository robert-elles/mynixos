# Migration Plan: Falcon → Leopard

## Overview

Leopard (TUXEDO laptop, AMD Ryzen 9 + NVIDIA GPU) becomes the new home server, replacing Falcon (Dell XPS 13). Leopard keeps all its existing laptop/gaming features AND gains all server modules. External hard disks physically move from Falcon to Leopard.

---

## External Drives (physical move, no copying needed)

The three USB drives mount by label via `disks.nix` — just unplug from falcon, plug into leopard.

| Label | Mount | Contents |
|-------|-------|----------|
| `white` | `/data` | Nextcloud data, Paperless media, Music, Calibre-Web, MiniDLNA DB, Immich backup, Wallabag backup |
| `silver` | `/data2` | Movies, TV shows, Downloads, Transmission, NFS exports, Samba share, backup copies (Paperless, Vikunja, Music) |
| `black` | `/data3` | Games (NFS export) |

Verify labels before disconnecting from falcon:
```bash
lsblk -o NAME,LABEL,FSTYPE,SIZE,MOUNTPOINT
```

---

## Data to Copy (on falcon's internal SSD)

### `/fastdata/` — databases and app state (CRITICAL)

| Path | Service | Notes |
|------|---------|-------|
| `/fastdata/psql_db_data` | PostgreSQL | Hosts DBs for Nextcloud, Wallabag, Immich |
| `/fastdata/paperless/data` | Paperless | Config + SQLite database |
| `/fastdata/vikunja` | Vikunja | Files + SQLite database |

### `/var/lib/*` — service state directories

| Path | Service | Priority |
|------|---------|----------|
| `/var/lib/immich` | Immich photos + thumbnails | Critical |
| `/var/lib/elasticsearch` | Elasticsearch indices | Medium (can reindex from Paperless) |
| `/var/lib/jellyfin` | Jellyfin config + metadata | Medium |
| `/var/lib/freshrss` | FreshRSS config + feeds DB | Medium |
| `/var/lib/mealie` | Mealie recipes DB | Medium |
| `/var/lib/audiobookshelf` | Audiobookshelf | Bind mount from `/data/audiobookshelf` — on external drive |
| `/var/lib/calibre-web` | Calibre-Web | Bind mount from `/data/calibre-web` — on external drive |
| `/var/lib/nextcloud` | Nextcloud PHP state | Low (regenerated on setup) |
| `/var/lib/redis-nextcloud` | Redis cache | Skip (ephemeral) |

### Docker volumes (under `/var/lib/docker/volumes/`)

| Volume | Service |
|--------|---------|
| `wallabag_images` | Wallabag |
| `wallabag_data` | Wallabag |
| `wallabag_var` | Wallabag |

---

## Step-by-Step Migration

### 1. Pre-migration on leopard (before stopping falcon)

```bash
# Create /fastdata on leopard's internal SSD
sudo mkdir -p /fastdata

# Ensure git-crypt key exists
ls ~/.ssh/gitcrypt_mynixos_key

# Ensure agenix identity exists
ls ~/.ssh/id_ed25519

# Set leopard's static IP in router DHCP reservation (192.168.178.38)
```

### 2. Stop services on falcon (consistent data snapshot)

```bash
# On falcon:
sudo systemctl isolate maintenance-network.target
```

### 3. Rsync data from falcon to leopard

```bash
# Run from leopard. Use --numeric-ids to preserve uid/gid across machines.

# /fastdata (PostgreSQL, Paperless data, Vikunja)
sudo rsync -avP --numeric-ids falcon:/fastdata/ /fastdata/

# /var/lib service directories
sudo rsync -avP --numeric-ids falcon:/var/lib/immich/ /var/lib/immich/
sudo rsync -avP --numeric-ids falcon:/var/lib/elasticsearch/ /var/lib/elasticsearch/
sudo rsync -avP --numeric-ids falcon:/var/lib/jellyfin/ /var/lib/jellyfin/
sudo rsync -avP --numeric-ids falcon:/var/lib/freshrss/ /var/lib/freshrss/
sudo rsync -avP --numeric-ids falcon:/var/lib/mealie/ /var/lib/mealie/

# Docker volumes (wallabag)
sudo rsync -avP --numeric-ids falcon:/var/lib/docker/volumes/ /var/lib/docker/volumes/
```

### 4. Connect external drives to leopard

Plug in the three USB drives (white, silver, black). Verify:
```bash
lsblk -o NAME,LABEL,FSTYPE,SIZE,MOUNTPOINT
```

### 5. Build and switch on leopard

```bash
cd ~/code/mynixos
git-crypt unlock ~/.ssh/gitcrypt_mynixos_key
nixos-rebuild switch --impure --flake ~/code/mynixos/machines/leopard |& nom
```

### 6. Post-switch verification

```bash
# Check all services started
systemctl --failed

# Check key services individually
systemctl status postgresql nextcloud-setup nginx docker immich-server

# Check drives mounted
df -h /data /data2 /data3

# Check Nextcloud
curl -s -o /dev/null -w "%{http_code}" https://PUBLIC_HOSTNAME

# Check PostgreSQL
sudo -u postgres psql -l
```

### 7. Network cutover

- Update router port forwarding: all ports from falcon's IP (192.168.178.25) → leopard's IP (192.168.178.38)
- ddclient (dyndns.nix) will automatically update public DNS records
- Internal DNS via coredns resolves to `settings.server_ip` (192.168.178.38)

### 8. Return falcon to normal (optional)

```bash
# On falcon:
sudo systemctl isolate default.target
```

---

## Checklist

- [ ] Set leopard's static IP (192.168.178.38) in router DHCP reservation
- [ ] Verify `~/.ssh/gitcrypt_mynixos_key` exists on leopard
- [ ] Verify `~/.ssh/id_ed25519` on leopard matches `secrets/agenix/secrets.nix`
- [ ] Create `/fastdata` directory on leopard
- [ ] Stop falcon services (`systemctl isolate maintenance-network.target`)
- [ ] Rsync `/fastdata/` from falcon
- [ ] Rsync `/var/lib/immich/` from falcon
- [ ] Rsync `/var/lib/elasticsearch/` from falcon
- [ ] Rsync `/var/lib/jellyfin/` from falcon
- [ ] Rsync `/var/lib/freshrss/` from falcon
- [ ] Rsync `/var/lib/mealie/` from falcon
- [ ] Rsync `/var/lib/docker/volumes/` from falcon
- [ ] Physically connect white, silver, black drives to leopard
- [ ] Verify drive labels with `lsblk`
- [ ] `nixos-rebuild switch` on leopard
- [ ] Verify services with `systemctl --failed`
- [ ] Update router port forwarding
- [ ] Verify public DNS resolves correctly
- [ ] Test Nextcloud, Immich, Paperless from external network
