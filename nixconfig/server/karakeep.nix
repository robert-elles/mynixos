{ settings, ... }:
{

  services.nginx.virtualHosts = {
    "${settings.hostname}" = {
      locations."/karakeep" = {
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
