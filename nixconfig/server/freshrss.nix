{ config, pkgs, settings, ... }:
let host = "freshrss.${settings.public_hostname2}";
in {
  services.freshrss = {
    enable = true;
    # database.port = 3306;
    baseUrl = "https://freshrss.${settings.public_hostname2}";
    virtualHost = "freshrss.${settings.public_hostname2}";
    # authType = "http_auth";
    passwordFile = config.age.secrets.freshrss_password.path;
    defaultUser = "robert";
    api.enable = true;
    # authType = "http_auth";
  };

  services.rss-bridge = {
    enable = true;
    virtualHost = "rss.${settings.public_hostname2}";
    config = {
      system.enabled_bridges = [ "*" ];
      error = {
        output = "http";
        report_limit = 5;
      };
      FileCache = { enable_purge = true; };
    };
  };

  services.nginx.virtualHosts = {
    "freshrss.${settings.public_hostname2}" = {
      enableACME = true;
      forceSSL = true;
      # locations."/" = {
      #   proxyPass = "http://localhost:3001";
      #   # proxyWebsockets = true;
      # };
    };
  };
}
