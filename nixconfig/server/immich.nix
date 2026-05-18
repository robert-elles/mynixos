{ pkgs-pin, settings, ... }:
{

  # fileSystems."/var/lib/immich" = {
  #   device = "/data/immich";
  #   options = [
  #     "bind"
  #     "nofail"
  #     "async"
  #   ];
  #   neededForBoot = false;
  #   noCheck = true;
  # };

  # services.nginx.virtualHosts."falcon".locations."/immich".return = "301 http://falcon:3000";

  services.immich = {
    enable = true;

    # secretsFile = config.age.secrets.immich_secrets.path;

    settings = {
      server.externalDomain = "http://${settings.hostname}:9007";
    };

    port = 9007;
    host = "0.0.0.0";

    # package = pkgs-pin.immich;a

    database = {
      host = "/run/postgresql";
    };

    # mediaLocation = "/home/robert/Nextcloud/Pictures/";
    mediaLocation = "/fastdata/immich";

    machine-learning.environment = {
      # MACHINE_LEARNING_CACHE_FOLDER = "/var/cache/immich";
      MPLCONFIGDIR = "/var/cache/immich/matplotlib";
      HF_HOME = "/var/cache/immich/models";
    };

    # postgres = {
    #   host = "";
    #   port = "";
    # };
  };
}
