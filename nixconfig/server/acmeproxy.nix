{ settings, config, lib, ... }:
let
  hostname = settings.hostname;
  mkRedirect = port: { return = "301 http://${hostname}:${toString port}"; };

  aliases = import ./local-aliases.nix;

  # Shared local-CA cert (see secrets/local-ca/ca.crt); its SAN list covers
  # every "<name>.local" alias below, so devices that trust that CA get no
  # hostname-mismatch warning.
  mkAliasVhost = a: {
    onlySSL = true;
    sslCertificate = ../../secrets/local-ca/mealie-fullchain.crt;
    sslCertificateKey = config.age.secrets.mealie_tls_key.path;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString a.port}${a.path or ""}";
      proxyWebsockets = true;
    };
  };
in
{

  security.acme = {
    acceptTerms = true;
    defaults.email = settings.email;
  };

  # local reverse proxy / redirect hub
  services.nginx = {
    enable = true;
    clientMaxBodySize = "0"; # 0 means no limit
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "${hostname}" = {
        enableACME = false;
        forceSSL = false;
        locations = {
          "/nextcloud" = mkRedirect 9000;
          "/paperless" = mkRedirect 9001;
          "/navidrome" = mkRedirect 9002;
          "/jellyfin" = mkRedirect 9003;
          "/mealie" = {
            return = "301 https://${hostname}:9004";
          };
          "/audiobooks" = mkRedirect 9005;
          "/wallabag" = mkRedirect 9006;
          "/immich" = mkRedirect 9007;
          "/vikunja" = mkRedirect 9008;
          "/freshrss" = mkRedirect 9009;
          "/rssbridge" = mkRedirect 9010;
          "/remote" = {
            return = "301 http://${hostname}:9011/guacamole/";
          };
          "/sunshine" = mkRedirect 9012;
          "/fazcast" = mkRedirect 9013;
          "/newscast" = mkRedirect 9014;
          "/calibre" = mkRedirect 9015;
          "/gramps" = {
            return = "301 https://${hostname}:9016";
          };
          "/openclaw" = {
            return = "301 https://${hostname}:9017";
          };
          "/hister" = mkRedirect 9018;
          "/storage" = mkRedirect 9999;
        };
      };
    } // lib.listToAttrs (map (a: lib.nameValuePair "${a.name}.local" (mkAliasVhost a)) aliases);
  };
}
