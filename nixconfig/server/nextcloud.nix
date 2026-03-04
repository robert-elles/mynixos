{ config, pkgs, pkgs-pin, settings, ... }:
let
  parameters = builtins.fromJSON (builtins.readFile
    (settings.system_repo_root + "/secrets/gitcrypt/params.json"));
  admin_user = parameters.admin_user;
  public_hostname = parameters.public_hostname;
in {

  services.redis.servers.nextcloud = { enable = true; };
  # services.memcached = {
  #   enabled = true;
  # };
  # services.nextcloud.caching.memcached = true;
  # ToDo !!!
  # 1. create a user for nextcloud with a fix uid and gid

  services.nextcloud = let
    ncVersion = "33";
    ncPkg = builtins.getAttr "nextcloud${ncVersion}" pkgs;
    ncApps = (builtins.getAttr "nextcloud${ncVersion}Packages" pkgs).apps;
  in {
    enable = true;
    caching.apcu = true;
    caching.redis = true;
    configureRedis = true;
    hostName = "${public_hostname}";
    # Use HTTPS for links
    https = true;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
    datadir = "/data/nextcloud";
    maxUploadSize = "5G";
    package = ncPkg; # check update instructions before update
    extraApps = {
      inherit (ncApps)
        # news # not available for NC 33
        contacts calendar
        # tasks
      ;
    };
    settings = {
      loglevel = 3; # 3 = error, 2 = warning
      trusted_domains = [ settings.hostname ];
      # Further forces Nextcloud to use HTTPS
      overwriteprotocol = "https";
      default_phone_region = "DE";
      maintenance_window_start = "04:00";
      memcache.local = "OCMemcacheAPCu";
      # memcache.distributed = "\OC\Memcache\Redis";
      memcache.locking = "OCMemcacheRedis";
      # redis = {
      #   host = "/var/run/redis-nextcloud/redis.sock";
      #   port = 0;
      #   timeout = 0.0;
      # };
      # redis = ''array(
      #   'host' => '/var/run/redis-nextcloud/redis.sock',
      #   'port' => 0,
      #   'timeout' => 0.0,
      #     ),
      # '';
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
}
