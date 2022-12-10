{
  description = "veloxchem-hpc";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "mach-nix";
    mach-nix.inputs.flake-utils.follows = "flake-utils";
    mach-nix.inputs.nixpkgs.follows = "nixpkgs";
    mach-nix.inputs.pypi-deps-db.follows = "pypi-deps-db";
    pypi-deps-db.url = "github:DavHau/pypi-deps-db";
    pypi-deps-db.inputs.mach-nix.follows = "mach-nix";
    pypi-deps-db.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, pypi-deps-db }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonEnv = mach-nix.lib."${system}".mkPython {
          requirements = builtins.readFile ./requirements.txt + ''
            # additional dependencies for local work
            jupyterlab
            pandas
          '';
        };
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [ ];
          buildInputs = [ pythonEnv ];
        };
      });
}
