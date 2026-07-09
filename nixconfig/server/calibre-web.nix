{ pkgs-pin, lib, ... }:
{

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     calibre-web = prev.calibre-web.overrideAttrs (old: {
  #       postPatch = old.postPatch + ''
  #         substituteInPlace setup.cfg \
  #           --replace "requests>=2.11.1,<2.29.0" "requests"
  #       '';
  #     });
  #   })
  # ];

  fileSystems."/var/lib/calibre-web" = {
    device = "/data/calibre-web";
    fsType = "none";
    options = [
      "bind"
      "nofail"
      "async"
    ];
    neededForBoot = false;
    noCheck = true;
  };

  # The upstream module adds ReadWritePaths including the calibreLibrary path.
  # That path contains a space ("Calibre Library"), which systemd misparsed as
  # two separate entries, causing namespace setup to fail (226/NAMESPACE).
  # The library only needs read access, so restricting ReadWritePaths to the
  # data dir is correct and safe.
  systemd.services.calibre-web.serviceConfig.ReadWritePaths = lib.mkForce [ "/var/lib/calibre-web" ];

  services.calibre-web = {
    enable = true;
    package = pkgs-pin.calibre-web;
    listen.port = 9015;
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
