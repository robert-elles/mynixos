{ settings, ... }:
{
  services.hister = {
    enable = true;
    port = 9018;
    openFirewall = true;
    settings.server = {
      address = "0.0.0.0:9018";
      # Must match the URL the browser uses: hister rejects /search
      # requests whose Origin differs from base_url in scheme/host/port.
      base_url = "https://hister.${settings.public_hostname2}";
    };
  };
}
