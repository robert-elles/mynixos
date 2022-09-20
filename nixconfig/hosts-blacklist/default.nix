{ config, pkgs, lib, ... }:
let
  hosts-blacklist = with pkgs;
    stdenv.mkDerivation rec {
      version = "3.11.17";
      name = "stevenblack-hosts-${version}";
      whitelist = ./whitelist;
      src = fetchFromGitHub {
        owner = "StevenBlack";
        repo = "hosts";
        rev = version;
        sha256 = "087i7729vrhnapis5qk88lz4f3alnlnlnqzfm53kmxx0q2zxd4rh";
        meta = with lib; {
          description = "Unified hosts file with base extensions";
          homepage = "https://github.com/StevenBlack/hosts";
        };
      };
      buildInputs =
        [ python3 python39Packages.requests python39Packages.flake8 ];
      buildPhase = ''
        python3 testUpdateHostsFile.py
        python3 updateHostsFile.py --auto --noupdate --whitelist $whitelist
      '';
      installPhase = ''
        mkdir -p $out/
        cp hosts $out/
      '';
    };
in {

  environment.systemPackages = with pkgs; [ hosts-blacklist ];

  networking.extraHosts = builtins.readFile ("${hosts-blacklist}/hosts");
}
