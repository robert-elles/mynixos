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

  nixpkgs.overlays = [
    (final: prev: {
      calibre-web = prev.calibre-web.overrideAttrs (old: {
        postPatch = old.postPatch + ''
          substituteInPlace setup.cfg \
            --replace "requests>=2.11.1,<2.29.0" "requests"
        '';
      });
    })
  ];

  fileSystems."/var/lib/calibre-web" = {
    device = "/data/calibre-web";
    options = [ "bind" ];
    neededForBoot = false;
    noCheck = true;
  };

  services.calibre-web = {
    enable = true;
    listen.port = 8083;
    listen.ip = "0.0.0.0";
    user = "nextcloud";
    dataDir = "calibre-web"; # /var/lib/calibre-web/datadir
    options = {
      # calibreLibrary = /data/calibre/library;
      calibreLibrary = "/data/nextcloud/data/robert/files/Documents/Books/Calibre Library";
      # enableBookUploading = true;
    };
  };
}
