{ ... }:
{

  fileSystems."/var/lib/immich" = {
    device = "/data/immich";
    options = [ "bind" ];
    neededForBoot = false;
    noCheck = true;
  };

  # services.nginx.virtualHosts."falcon".locations."/immich".return = "301 http://falcon:3000";

  services.immich = {
    enable = true;

    secretsFile = config.age.secrets.immich_secrets.path;

    settings = {
      externalDomain = ""; # Domain for publicly shared links, including http(s)://.
    };

    port = 2283;
    host = "0.0.0.0";

    mediaLocation = "/var/lib/immich";

    # postgres = {
    #   host = "";
    #   port = "";
    # };
  };
}
