{ config, pkgs, settings, ... }:
let
  parameters =
    builtins.fromJSON (builtins.readFile (settings.system_repo_root + "/secrets/gitcrypt/params.json"));
  admin_user = parameters.admin_user;
  public_hostname = parameters.public_hostname;
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
    package = pkgs.nextcloud31; # check update instructions before update
    hostName = "${public_hostname}";
    # Use HTTPS for links
    https = true;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
    datadir = "/data/nextcloud";
    maxUploadSize = "5G";
    # extraApps = {
    #   inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
    # };
    settings = {
      loglevel = 3; # 3 = error, 2 = warning
      trusted_domains = [ "falcon" ];
      # Further forces Nextcloud to use HTTPS
      overwriteprotocol = "https";
      default_phone_region = "DE";
      maintenance_window_start = "04:00";
      memcache.local = "\OC\Memcache\APCu";
      # memcache.distributed = "\OC\Memcache\Redis";  
      memcache.locking = "\OC\Memcache\Redis";
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




