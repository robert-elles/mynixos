{ config, lib, pkgs, ... }:
let
  parameters =
    builtins.fromJSON (builtins.readFile /home/robert/code/mynixos/secrets/gitcrypt/nextcloud_params.json);
  myemail = parameters.email;
  admin_user = parameters.admin_user;
  public_hostname = parameters.public_hostname;
in
{

  # ToDo !!!
  # 1. create a user for nextcloud with a fix uid and gid

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
      "audiobooks.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8000";
          proxyWebsockets = true;
        };
      };
      "011235.mercury.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:28981";
          proxyWebsockets = true;
        };
      };
      "paperless.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:28981";
          proxyWebsockets = true;
        };
      };
      "falcon" = {
        enableACME = false;
        forceSSL = false;
        locations = {
          "/jellyfin" = {
            return = "301 http://falcon:8096";
          };
          "/transmission" = {
            return = "301 http://falcon:9091";
          };
          "/torrent" = {
            return = "301 http://falcon:9091";
          };
          "/gramps" = {
            return = "301 http://falcon:5049";
          };
          "/paperless" = {
            return = "301 http://falcon:28981";
          };
          "/books" = {
            return = "301 http://falcon:8083";
          };
          "/audiobooks" = {
            return = "301 http://falcon:8000";
          };
          "/jupyter" = {
            return = "301 http://falcon:8888";
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
      extraTrustedDomains = [ "falcon" ];
      defaultPhoneRegion = "DE";
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";
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
