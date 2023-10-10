{ config, ... }: {


  imports = [ ./web-apps/gramps-web.nix ];

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

  services.nfs.server = {
    enable = true;
    exports = ''
      /export         192.168.178.0/24(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0) 2003:d1:4708:4400::/64(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
      /export/movies    192.168.178.0/24(insecure,rw,sync,no_subtree_check) 2003:d1:4708:4400::/64(insecure,rw,sync,no_subtree_check)
      /export/tvshows    192.168.178.0/24(insecure,rw,sync,no_subtree_check) 2003:d1:4708:4400::/64(insecure,rw,sync,no_subtree_check)
    '';
  };

  # bind mounts for nfs share
  fileSystems."/export/movies" = {
    device = "/data/movies";
    options = [ "bind" ];
  };
  fileSystems."/export/tvshows" = {
    device = "/data/tvshows";
    options = [ "bind" ];
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

  services.paperless = {
    enable = true;
    dataDir = "/data/paperless/data";
    mediaDir = "/data/paperless/media";
    user = "paperless";
    passwordFile = "${config.age.secrets.paperless_password.path}";
  };

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


  services.gramps-web.enable = true;
  services.gramps-web.user = "robert";
  services.gramps-web.config-file = "${config.age.secrets.grampsweb_config.path}";
  services.gramps-web.dataDir = "/data/grampsweb";
}
