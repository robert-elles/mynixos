{
  config,
  pkgs,
  settings,
  ...
}:
let
  host = "freshrss.${settings.public_hostname2}";
in
{
  services.freshrss = {
    enable = true;
    # database.port = 3306;
    baseUrl = "https://freshrss.${settings.public_hostname2}";
    virtualHost = "freshrss.${settings.public_hostname2}";
    # authType = "http_auth";
    passwordFile = 
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
