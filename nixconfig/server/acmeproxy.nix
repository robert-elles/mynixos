{ settings, ... }:
let
  hostname = settings.hostname;
  mkRedirect = port: { return = "301 http://${hostname}:${toString port}"; };
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
          "/mealie" = mkRedirect 9004;
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
          "/storage" = mkRedirect 9999;
        };
      };
    };
  };
}
