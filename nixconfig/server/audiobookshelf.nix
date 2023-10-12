{ ... }:
{

  fileSystems."/var/lib/audiobookshelf" = {
    device = "/data/audiobookshelf";
    options = [ "bind" ];
    neededForBoot = false;
    noCheck = true;
  };

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 8000;
    dataDir = "audiobookshelf";
  };
}
