{ ... }:
{

  fileSystems."/var/lib/audiobookshelf" = {
    device = "/data/audiobookshelf";
    fsType = "none";
    options = [
      "bind"
      "nofail"
      "async"
    ];
    neededForBoot = false;
    noCheck = true;
  };

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 9005;
    dataDir = "audiobookshelf";
  };
}
