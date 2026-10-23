{ settings, ... }:
{
  # Bitwarden-compatible password manager. Only listens on loopback; reached
  # through the nginx vhosts generated from local-aliases.nix (acmeproxy.nix).
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    # nightly sqlite-safe copy of the vault (the live db is in /var/lib/vaultwarden)
    backupDir = "/data/vaultwarden-backup";
    config = {
      # Must match the URL used in the browser extensions. The public-domain
      # name carries the Let's Encrypt wildcard, so no CA has to be installed
      # on the clients.
      DOMAIN = "https://vaultwarden.${settings.public_hostname2}";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 9020;
      # Set to false after the first account exists.
      SIGNUPS_ALLOWED = false;
    };
  };
}
