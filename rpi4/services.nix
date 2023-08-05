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

  services.samba-wsdd.enable = true;
  services.samba-wsdd.discovery = true;
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = rpi4
      netbios name = rpi4
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.178. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      movies =
        {
          path = "/data/movies";
          writable = true;
          browseable = "yes";
          public = "yes";
          "guest ok" = "yes";
          comment = "Movies";
          "read only" = "no";
          "create mask" = "0775";
          "directory mask" = "0755";
          "force user" = "robert";
          # "force group" = "groupname";
        };
      tvshows =
        {
          path = "/data/tvshows";
          writable = true;
          public = "yes";
          browseable = "yes";
          "guest ok" = "yes";
          comment = "TV Shows";
        };
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


  services.gramps-web.enable = true;
  services.gramps-web.user = "robert";
  services.gramps-web.config-file = "${config.age.secrets.grampsweb_config.path}";
  services.gramps-web.dataDir = "/data/grampsweb";
}
