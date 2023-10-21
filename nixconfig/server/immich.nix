{ ... }:
{

  fileSystems."/var/lib/immich" = {
    device = "/data/immich";
    options = [ "bind" ];
    neededForBoot = false;
    noCheck = true;
  };

  services.nginx.virtualHosts."falcon".locations."/immich".return = "301 http://falcon:3000";

  services.immich = {
    enable = true;

    postgres = {
      host = "";
      port = "";
    };
  };
}
