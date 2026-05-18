{
  config,
  pkgs,
  pkgs-pin,
  settings,
  ...
}:
let
  parameters = builtins.fromJSON (
    builtins.readFile (settings.system_repo_root + "/secrets/gitcrypt/params.json")
  );
  admin_user = parameters.admin_user;
in
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
    package = pkgs.nextcloud33; # check update instructions before update
    extraApps = {
      inherit (pkgs.nextcloud33Packages.apps)
        news
        contacts
        calendar
        # tasks
        ;
    };
    settings = {
      loglevel = 3; # 3 = error, 2 = warning
      trusted_domains = [ settings.hostname ];
      overwriteprotocol = "http";
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
      adminpassFile = config.age.secrets.nextcloud_adminpass.path;
      adminuser = admin_user;
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
