{ settings, ... }:
{
  services.hister = {
    enable = true;
    port = 9018;
    openFirewall = true;
    settings.server = {
      address = "0.0.0.0:9018";
      base_url = "http://${settings.hostname}:9018";
    };
  };
}
