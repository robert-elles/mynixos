{ pkgs ? import <nixpkgs> { } }:
let
  python = pkgs.python3;
  pythonPackages = python.pkgs;
in
pythonPackages.buildPythonPackage rec {

  pname = "gramps";
  version = "5.1.6";

  format = "other";

  src = pkgs.fetchFromGitHub {
    owner = "gramps-project";
    repo = "gramps";
    rev = "v${version}";
    sha256 = "sha256-BerkDXdFYfZ3rV5AeMo/uk53IN2U5z4GFs757Ar26v0=";
  };

  # nativeBuildInputs = with python.pkgs; [
  # ];

  # propagatedBuildInputs = with python.pkgs; [
  # ];

  # Upstream repo doesn't provide any tests.
  doCheck = false;

  installPhase = ''
    mkdir -p $out/gramps
    cp -dr --no-preserve='ownership' ./gramps $out/gramps
  '';

  meta = {
    description = "A RESTful web API for Gramps";
    homepage = "https://github.com/gramps-project/gramps/";
    # license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ robert ];
    # platforms = platforms.all;
  };
}
