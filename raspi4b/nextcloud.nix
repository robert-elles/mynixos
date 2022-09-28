{ config, lib, pkgs, ... }:
let
  parameters =
    builtins.fromJSON (builtins.readFile /etc/nixos/mynixos/raspi4b/rpi4.json);
  myemail = parameters.email;
  admin_user = parameters.admin_user;
  public_hostname = parameters.public_hostname;
in {

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
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud24; # check update instructions before update
    hostName = "${public_hostname}";
    # Use HTTPS for links
    https = true;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
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