{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, fetchFromGitHub ? pkgs.fetchFromGitHub
}:
let
  # fromNode2nix = import ./node_deps.nix {
  fromNode2nix = import ./gen/composition.nix {
    inherit pkgs;
  };
  nodeDependencies = fromNode2nix.shell.nodeDependencies;
  # nodeDependencies = "";
in
stdenv.mkDerivation rec {

  pname = "Gramps.js";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "gramps-project";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-7uCuMPDsLxAcv+x4kKswCgNxK8uVpBsMJfHngw9rptw=";
  };

  nativeBuildInputs = with pkgs; [
    nodejs_18
    nodePackages.rimraf
    nodePackages.rollup
  ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
     PATH="${nodeDependencies}/bin:$PATH"

    runHook preBuild

    export HOME=$PWD/home
    mkdir $HOME
    # npm run test
    npm run build

    runHook postBuild
  '';

  installPhase = ''
    mkdir $out
    # cp -r cypress/videos $out/
  '';

}
