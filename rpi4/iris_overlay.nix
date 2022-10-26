final: prev: {
  mopidy-iris = prev.mopidy-iris.overrideAttrs (old: rec {
    version = "3.63.0";
    src = prev.python3Packages.fetchPypi {
      inherit version;
      pname = old.pname;
      sha256 = "Za/znP+V0NRitZk+vN9f1MwdDJ3yalv2tSWSW9LWMUA=";
    };
  });
}
