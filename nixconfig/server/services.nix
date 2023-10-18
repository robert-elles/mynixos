{ ... }: {

  services.eternal-terminal.enable = true;

  # port is 8096
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
}
