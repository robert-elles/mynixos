{ pkgs-pin, lib, ... }:
{

  # Upstream calibre-web's pyproject.toml declares the entry point
  # "calibreweb.__main__:main", but nixpkgs' postPatch only creates
  # calibreweb/__init__.py (from cps.py) and calibreweb/cps/ (from cps/),
  # never a calibreweb/__main__.py. The wrapped binary therefore fails at
  # startup with "ModuleNotFoundError: No module named 'calibreweb.__main__'".
  # __init__.py already contains the correct sys.path hack plus `main`, so
  # duplicating it as __main__.py satisfies the entry point without touching
  # any other packaging logic.
  nixpkgs.overlays = [
    (final: prev: {
      calibre-web = prev.calibre-web.overrideAttrs (old: {
        postPatch =
          old.postPatch
          + ''
            cp src/calibreweb/__init__.py src/calibreweb/__main__.py
          '';
      });
    })
  ];

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
    # package = pkgs-pin.calibre-web;
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
