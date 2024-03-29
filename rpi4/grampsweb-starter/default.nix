{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, ... }:
let
  gramps-webapi = pkgs.callPackage ../gramps-webapi { };
  script = pkgs.writeShellApplication {
    name = "grampsweb_starter";
    text = ''
      ${gramps-webapi.python.pkgs.gunicorn}/bin/gunicorn --workers=4 -b 0.0.0.0:5049 gramps_webapi.wsgi:app
    '';
  };
in
stdenv.mkDerivation {
  name = "grampsweb_starter";
  src = script;
  installPhase = ''
    mkdir -p $out/
    cp -r * $out/
  '';

  nativeBuildInputs = with pkgs; [
    wrapGAppsHook
    gobject-introspection
  ];
}
