{ ... }: {

  services.eternal-terminal.enable = true;

  # port is 8096
  services.jellyfin.enable = true;

  services.minidlna = {
    enable = true;
    settings = {
      media_dir = [ "/data2/movies" "/data2/tvshows" ];
      db_dir = "/data/minidlna_db"; # create for user minidlna
      inotify = "yes";
    };
  };

  virtualisation.oci-containers.containers.jdownloader = {
    image = "jlesage/jdownloader-2";
    ports = [ "5800:5800" ];
    environment = {
      LANG = "de_DE.UTF-8";
      TZ = "Europe/Berlin";
      KEEP_APP_RUNNING = "1";
    };
    volumes = [ "/data2/downloads:/output:rw" ];
  };

  # users.users.robert.extraGroups = [ "davfs2" ];
  # services.davfs2 = {
  #   enable = true;
  #   # extraConfig = ''
  #   #   use_locks 0
  #   # '';
  # };

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
