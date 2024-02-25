{ config, pkgs, ... }:
let
  parameters =
    builtins.fromJSON (builtins.readFile /home/robert/code/mynixos/secrets/gitcrypt/nextcloud_params.json);
  admin_user = parameters.admin_user;
  public_hostname = parameters.public_hostname;
in
{

  # ToDo !!!
  # 1. create a user for nextcloud with a fix uid and gid

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28; # check update instructions before update
    hostName = "${public_hostname}";
    # Use HTTPS for links
    https = true;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
    datadir = "/data/nextcloud";
    settings = {
      trusted_domains = [ "falcon" ];
      # Further forces Nextcloud to use HTTPS
      overwriteprotocol = "https";
      default_phone_region = "DE";
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
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
