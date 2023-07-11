# See https://johns.codes/blog/building-typescript-node-apps-with-nix
# https://nixos.org/manual/nixpkgs/stable/#language-javascript
{ lib, stdenv, fetchFromGitHub, buildNpmPackage, nodejs }:
# let
#   # python = python3;
# in
buildNpmPackage rec {
  # stdenv.mkDerivation rec {
  pname = "Gramps.js";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "gramps-project";
    # repo = "Gramps.js";
    repo = pname;
    rev = "v${version}";
    # hash = "sha256-7uCuMPDsLxAcv+x4kKswCgNxK8uVpBsMJfHngw9rptw=";
    sha256 = "sha256-7uCuMPDsLxAcv+x4kKswCgNxK8uVpBsMJfHngw9rptw=";
  };

  # npmDepsHash = lib.fakeSha256;

  forceGitDeps = true;

  # buildInputs = [ nodejs ];

  # buildPhase = ''
  #   # each phase has pre/postHooks. When you make your own phase be sure to still call the hooks
  #   runHook preBuild
  #   npm ci
  #   npm run build
  #   runHook postBuild
  # '';

  # installPhase = ''
  #   runHook preInstall
  #   cp -r node_modules $out/node_modules
  #   cp package.json $out/package.json
  #   cp -r dist $out/dist
  #   runHook postInstall
  # '';


  meta = with lib; {
    description = "Web frontend for the Gramps genealogical research system Resources";
    homepage = "https://github.com/gramps-project/Gramps.js";
    # license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ robert ];
    # platforms = platforms.all;
  };
}
