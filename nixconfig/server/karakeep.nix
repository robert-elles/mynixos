{ settings, ... }:
{

  services.nginx.virtualHosts = {
    "karakeep.${settings.public_hostname2}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5200";
        # proxyWebsockets = true;
      };
    };
  };

  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = "5200";
      DISABLE_SIGNUPS = "true";
    };
  };
}
