# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS configuration repository managing multiple machines (falcon, leopard, bear, panther, ray) using Nix flakes. The primary machine is "falcon" - a server/workstation running various self-hosted services including Nextcloud, Immich, Paperless, and many others.

## Key Commands

### Building and Deploying

```bash
# Rebuild and switch (from anywhere, uses $FLAKE env var)
rebuildswitch

# Rebuild for next boot
rebuildboot

# Test rebuild without switching boot config
rebuildtest

# Manual rebuild commands
nixos-rebuild switch --impure --flake $FLAKE |& nom
sudo sh -c 'nixos-rebuild boot --impure --flake ~/code/mynixos/machines/falcon |& nom'
```

The `$FLAKE` environment variable is automatically set to `${settings.system_repo_root}/machines/${settings.hostname}` in `nixconfig/common.nix:152`.

### Git-Crypt (Secret Management)

```bash
# Unlock encrypted secrets
git-crypt unlock ~/.ssh/gitcrypt_mynixos_key

# Check encryption status
git-crypt status -e
```

Secrets are stored in:
- `secrets/gitcrypt/` - Git-crypt encrypted files (e.g., `params.json` with hostnames/emails)
- `secrets/agenix/` - Age-encrypted secrets for runtime use

### Viewing Logs

```bash
journalctl --since "5 min ago"
journalctl -u <service-name>  # e.g., -u mopidy
journalctl -eu bluetooth
journal_errors  # Show priority 3 (error) logs
```

## Architecture

### Repository Structure

```
mynixos/
├── machines/          # Per-machine flake configurations
│   ├── falcon/       # Main server (x86_64-linux)
│   ├── leopard/      # Build machine
│   ├── bear/
│   ├── panther/
│   └── ray/
├── nixconfig/        # Shared configuration modules
│   ├── common.nix    # Base system config (SSH, nix settings, users)
│   ├── home.nix      # Home-manager config (shell aliases, dotfiles)
│   ├── system.nix    # Boot loader and networking
│   ├── dotfiles.nix  # Dotfile persistence using impermanence
│   ├── server/       # Service-specific configurations
│   └── ...           # GUI, laptop, desktop configs
├── dotfiles/         # Version-controlled dotfiles (symlinked via impermanence)
├── secrets/          # Encrypted secrets (gitcrypt + agenix)
├── patches/          # NixOS patches applied to nixpkgs
├── scripts/          # Utility scripts
└── docker/           # Docker compose configurations
```

### Flake Architecture

Each machine has its own `flake.nix` in `machines/<hostname>/` that:

1. **Defines inputs**: nixpkgs (usually master branch), home-manager, nixos-hardware, agenix, impermanence, and a private repo (mynixos-private)
2. **Creates a settings object**: Includes hostname, system architecture, repo root path, and sensitive parameters loaded from `secrets/gitcrypt/params.json`
3. **Applies patches**: Uses `pkgs.applyPatches` to patch nixpkgs (see `machines/falcon/flake.nix:47-54`)
4. **Imports modules**: Combines common configs from `nixconfig/` with machine-specific `hardware.nix`

Example settings structure (from `machines/falcon/flake.nix:38-45`):
```nix
settings = {
  inherit system system_repo_root hostname;
  public_hostname = parameters.public_hostname;   # from encrypted params.json
  public_hostname2 = parameters.public_hostname2;
  email = parameters.email;
  email2 = parameters.email2;
};
```

### Configuration Layers

1. **Machine-specific** (`machines/<hostname>/flake.nix`):
   - Hardware config
   - Enabled services
   - Machine-specific settings (IPs, display manager, etc.)

2. **Common system** (`nixconfig/common.nix`, `nixconfig/system.nix`):
   - Base packages (vim, git, htop, ripgrep, etc.)
   - SSH, boot loader, nix settings
   - User definitions (robert, uid 1000)
   - Timezone (automatic via localtimed)
   - Locale (de_DE.UTF-8 with en_US.UTF-8 override)

3. **Home-manager** (`nixconfig/home.nix`):
   - Shell configuration (fish is default, zsh also configured)
   - Shell aliases (rebuild commands, termcopy for kitty ssh, etc.)
   - Dotfile management
   - Programs: atuin, starship, tmux, btop, direnv, lazygit

4. **Service modules** (`nixconfig/server/*.nix`):
   - Self-contained service configs
   - Most services read secrets from `secrets/gitcrypt/params.json`
   - Services use agenix for runtime secrets (passwords, keys)

### Dotfile Persistence

Uses the `impermanence` module to persist specific dotfiles from `dotfiles/` directory:
- Directories: `sd/`, `.config/kitty`, `.config/easyeffects`
- Files: KDE configs, application launchers, fish completions
- Configured in `nixconfig/dotfiles.nix`


## Self-Hosted Services

Leopard runs multiple Docker-based and native NixOS services. Key service modules in `nixconfig/server/`:

- **nextcloud.nix** - Nextcloud with PostgreSQL, Redis caching, APCu
- **immich.nix** - Photo management
- **paperless.nix** - Document management
- **freshrss.nix** - RSS reader
- **mealie.nix** - Recipe manager
- **wallabag.nix** - Read-it-later service
- **calibre-web.nix** - Ebook library
- **stirlingpdf.nix** - PDF tools
- **audiobookshelf.nix** - Audiobook/podcast server
- **dawarich.nix** - Location tracking
- **open-webui.nix** - AI chat interface

Database services:
- **postgres.nix** - Shared PostgreSQL for multiple services
- **elastic.nix** - Elasticsearch

Infrastructure:
- **dns.nix** - DNS server configuration
- **nfs.nix** - NFS shares
- **samba.nix** - Samba file sharing
- **acmeproxy.nix** - ACME certificate proxy
- **dyndns.nix** - Dynamic DNS updates
`

### Shell Aliases

Defined in `nixconfig/home.nix:21-45`, notable aliases:
- `rebuildswitch`, `rebuildboot`, `rebuildtest` - NixOS rebuild commands with `nom` output
- `termcopy` - Kitty SSH with terminal info copy
- `captiveportal` - Open router captive portal in browser
- `journal_errors` - Show error-level journal entries
- `pwrestart` - Restart PipeWire
- `adb` - Android Debug Bridge with custom home dir

### Patching nixpkgs

Patches in `patches/` are applied to nixpkgs at the flake level (see `machines/falcon/flake.nix:47-54`). Currently applied:
- `423867.patch` - Dawarich support

### Pinned Packages

Some packages use a pinned nixpkgs version via `nixpkgs_pin` input for stability.

## Cursor Configuration

The `.cursor/rules/nixos-rules.mdc` contains a single rule: "don't ask to run the rebuild of the nix config". This means you should execute rebuild commands directly without asking for permission.

## Notes for Development

- User "robert" (uid 1000) is the primary user in group wheel with passwordless sudo
- Default shell is fish, but zsh is also configured
- The system uses automatic timezone detection via `localtimed`
- Boot loader keeps only 3 configurations (`boot.loader.systemd-boot.configurationLimit = 3`)
- Nix experimental features (flakes, nix-command) are enabled
- The repo must be unlocked with git-crypt before nixos-rebuild will work


## Remote server leopard

Transfer updated config to leopard home server:

`sd leopard syncbuild`

then ssh to leopard and run to rebuild:

`ssh -t leopard "sudo nixos-rebuild switch --impure --flake \$FLAKE 2>&1 | cat"`