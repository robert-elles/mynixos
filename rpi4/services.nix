{ config, pkgs, lib, ... }: {

  services.jellyfin.enable = true;
  services.jellyfin.user = "robert";

  services.minidlna = {
    enable = true;
    settings = {
      media_dir = [ "/data/movies" "/data/tvshows" ];
      db_dir = "/data/minidlna_db"; # create for user minidlna
      inotify = "yes";
    };
  };
}
