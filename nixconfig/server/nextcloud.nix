{
  config,
  pkgs,
  pkgs-pin,
  settings,
  ...
}:
{

  services.redis.servers.nextcloud = {
    enable = true;
  };
  # services.memcached = {
  #   enabled = true;
  # };
  # services.nextcloud.caching.memcached = true;
  services.nextcloud.caching.apcu = true;
  services.nextcloud.caching.redis = true;
  services.nextcloud.configureRedis = true;
  # ToDo !!!
  # 1. create a user for nextcloud with a fix uid and gid

  services.nextcloud = {
    enable = true;
    hostName = settings.hostname;
    # Use HTTPS for links
    https = false;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
    datadir = "/data/nextcloud";
    maxUploadSize = "5G";
    package = pkgs.nextcloud35; # check update instructions before update
    extraAppsEnable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        # news
        contacts
        calendar
        mail
        # tasks
        ;
    };
    settings = {
      loglevel = 3; # 3 = error, 2 = warning
      # Nextcloud rejects any Host it does not know with "Access through
      # untrusted domain", so every name it can be reached under has to be
      # listed: the bare hostname (port 9000) plus the mDNS and internal-DNS
      # aliases fronted by nginx (see acmeproxy.nix).
      trusted_domains = [
        settings.hostname
        "nextcloud.local"
        "nextcloud.${settings.internal_domain}"
        "nextcloud.${settings.public_hostname2}"
      ];
      # The alias vhosts terminate TLS and proxy to 127.0.0.1:9000 with
      # X-Forwarded-Proto, but nextcloud only honours that header from a
      # trusted proxy - without this it would emit http:// links on the
      # https pages. Plain access on :9000 has no such header and still
      # comes out as http, so both entrypoints generate correct URLs.
      # (Replaces a hardcoded overwriteprotocol = "http".)
      trusted_proxies = [
        "127.0.0.1"
        "::1"
      ];
      default_phone_region = "DE";
      maintenance_window_start = "04:00";
      memcache.local = "OCMemcacheAPCu";
      # memcache.distributed = "\OC\Memcache\Redis";
      memcache.locking = "OCMemcacheRedis";
      settings.enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
      ];
    };
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = config.age.secrets.dbpass.path;
    };
    phpOptions = {
      "opcache.enable" = "1";
      "opcache.interned_strings_buffer" = "23";
      "opcache.max_accelerated_files" = "10000";
      "opcache.memory_consumption" = "128";
      "opcache.save_comments" = "1";
      "opcache.revalidate_freq" = "60";
      "opcache.jit" = "1255";
      "opcache.jit_buffer_size" = "128M";
      "apc.enable_cli" = "1";
    };
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  services.nginx.virtualHosts."${settings.hostname}" = {
    listen = [
      {
        addr = "0.0.0.0";
        port = 9000;
      }
    ];
  };
}
