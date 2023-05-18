{ config, pkgs, ... }: {

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

  # fileSystems."/data/calibre/library" = {
  #   device = "/data/nextcloud/data/robert/files/Documents/Books/Calibre Library/";
  #   options = [ "bind" ];
  #   neededForBoot = false;
  #   noCheck = true;
  # };

  users.users.robert.extraGroups = [ "davfs2" ];
  services.davfs2 = {
    enable = true;
    extraConfig = ''
      use_locks 0
    '';
  };


  # services.autofs = {
  #   enable = true;
  #   autoMaster =
  #     let
  #       mapConf = pkgs.writeText "auto" ''
  #         nextcloud -fstype=davfs,conf=/path/to/davfs/conf,uid=myuid :https\:nextcloud.domain/remote.php/webdav/
  #       '';
  #     in
  #     ''
  #       /home/directory/mounts file:${mapConf}
  #     '';
  # };

  # services.calibre-web = {
  #   enable = true;
  #   # user = ;
  #   dataDir = /data/calibre-web/datadir;
  #   options = {
  #     # calibreLibrary = /data/calibre/library;
  #     # enableBookUploading = true;
  #   };
  # };
}
