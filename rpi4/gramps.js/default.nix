{ lib, python3, fetchFromGitHub }:
let
  python = python3;
in
python.pkgs.buildPythonApplication rec {
  pname = "gramp";
  version = "0.6.20";

  src = fetchFromGitHub {
    owner = "janeczku";
    repo = "calibre-web";
    rev = version;
    hash = "sha256-0lArY1aTpO4sgIVDSqClYMGlip92f9hE/L2UouTLK8Q=";
  };


  meta = with lib; {
    description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
    homepage = "https://github.com/janeczku/calibre-web";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ robert ];
    platforms = platforms.all;
  };
}
