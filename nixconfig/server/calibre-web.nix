{ ... }: {

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
    dataDir = "/var/lib/calibre-web"; # /var/lib/calibre-web/datadir
    options = {
      # calibreLibrary = /data/calibre/library;
      calibreLibrary = "/data/nextcloud/data/robert/files/Documents/Books/Calibre Library";
      # enableBookUploading = true;
    };
  };
}
