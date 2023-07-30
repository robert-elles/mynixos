{ config, lib, pkgs, ... }:
let
  parameters =
    builtins.fromJSON (builtins.readFile /home/robert/code/mynixos/rpi4/rpi4.json);
  myemail = parameters.email;
  admin_user = parameters.admin_user;
  public_hostname = parameters.public_hostname;
in
{

  security.acme = {
    acceptTerms = true;
    defaults.email = myemail;
  };

  # ssl reverse proxy
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
    virtualHosts = {
      "${public_hostname}" = {
        forceSSL = true;
        ## LetsEncrypt
        enableACME = true;
      };
      "calibre.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:8083";
      };
      "rpi4" = {
        enableACME = false;
        forceSSL = false;
        locations = {
          "/jellyfin" = {
            return = "301 http://rpi4:8096";
          };
          "/transmission" = {
            return = "301 http://rpi4:9091";
          };
          "/gramps" = {
            return = "301 http://rpi4:5049";
          };
        };
      };
    };
  };

  services.nextcloud = {
    enable = true;
    enableBrokenCiphersForSSE = false;
    package = pkgs.nextcloud27; # check update instructions before update
    hostName = "${public_hostname}";
    # Use HTTPS for links
    https = true;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
    datadir = "/data/nextcloud";
    config = {
      extraTrustedDomains = [ "rpi4" ];
      defaultPhoneRegion = "DE";
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = config.age.secrets.dbpass.path;
      #      dbpassFile = "${pkgs.writeText "dbpass" "test123"}";
      adminpassFile = config.age.secrets.nextcloud_adminpass.path;
      #      adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
      adminuser = admin_user;
    };
  };

  services.postgresql = {
    enable = true;
    dataDir = "/data/psql_db_data";
    package = pkgs.postgresql_14;
    # Ensure the database, user, and permissions always exist
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }];
  };

  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
