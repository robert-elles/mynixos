{
  description = "Application packaged using poetry2nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    {
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          poetry2nix = prev.poetry2nix.overrideScope' (p2nixfinal: p2nixprev: {
            # pyfinal & pyprev refers to python packages
            defaultPoetryOverrides = (p2nixprev.defaultPoetryOverrides.extend (pyfinal: pyprev:
              {
                ## dodge infinite recursion ##
                setuptools = prev.python310Packages.setuptools.override {
                  inherit (pyfinal)
                    bootstrapped-pip
                    pipInstallHook
                    setuptoolsBuildHook
                  ;
                };

                setuptools-scm = prev.python310Packages.setuptools-scm.override {
                  inherit (pyfinal)
                    packaging
                    typing-extensions
                    tomli
                    setuptools;
                };

                pip = prev.python310Packages.pip.override {
                  inherit (pyfinal)
                    bootstrapped-pip
                    mock
                    scripttest
                    virtualenv
                    pretend
                    pytest
                    pip-tools
                  ;
                };
                ## dodge infinite recursion (end) ##

                comm = pyprev.comm.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.hatchling
                  ]);
                });

                ebooklib = pyprev.ebooklib.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.setuptools
                  ]);
                });

                nbclient = pyprev.nbclient.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.hatchling
                  ]);
                });

                packaging = pyprev.packaging.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.flit-core
                  ]);
                });

                pykson = pyprev.pykson.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.setuptools
                  ]);
                  src = final.fetchFromGitHub {
                    owner = "sinarezaei";
                    repo = "pykson";
                    rev = "master";
                    sha256 = "sha256-hyW6cemGNTBD0HUFwBCTmt3WHcmAYZAb9rjNlrJY1hs=";
                  };
                });

                jupyter-events = pyprev.jupyter-events.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.hatchling
                  ]);
                });

                jupyter-server-terminals = pyprev.jupyter-server-terminals.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.hatchling
                  ]);
                });

                rfc3986-validator = pyprev.rfc3986-validator.overridePythonAttrs (old: rec {
                  propagatedBuildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.propagatedBuildInputs or [ ]) ++ [
                    pyfinal.setuptools
                  ]);
                });
              }
            ));
          });
        })
        (final: prev: {
          # The application
          myapp = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
          };
          # The env
          myenv = prev.poetry2nix.mkPoetryEnv {
            projectDir = ./.;
          };
        })
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlay ];
        };
      in
      {
        #packages.default = pkgs.myapp;
        #packages.myenv = pkgs.myenv;
        packages.poetry = nixpkgs.legacyPackages.${system}.python310Packages.poetry;
        #packages.poetry = pkgs.myenv.pkgs.poetry;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            #(python310.withPackages (ps: with ps; [ poetry ]))
            myenv
          ];
        };
      }));
}