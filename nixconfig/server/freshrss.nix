{
  config,
  pkgs,
  settings,
  ...
}:
{
  services.freshrss = {
    enable = true;
    # database.port = 3306;
    baseUrl = "https://freshrss.${settings.public_hostname2}";
    virtualHost = "freshrss.${settings.public_hostname2}";
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
