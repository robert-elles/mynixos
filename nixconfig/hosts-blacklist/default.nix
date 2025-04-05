{ pkgs, ... }:
let
  hosts-blacklist = with pkgs;
    stdenv.mkDerivation rec {
      version = "3.12.2";
      name = "stevenblack-hosts-${version}";
      whitelist = ./whitelist;
      src = fetchFromGitHub {
        owner = "StevenBlack";
        repo = "hosts";
        rev = version;
        sha256 = "sha256-ZrYN2XIjiL/G37zKvvp50QiFnFqhby8H+d/HwkwaCFY=";
        meta = {
          description = "Unified hosts file with base extensions";
          homepage = "https://github.com/StevenBlack/hosts";
        };
      };
      buildInputs = with python3Packages; [
        python
        requests
        flake8
      ];
      buildPhase = ''
        python updateHostsFile.py --auto --noupdate --whitelist $whitelist
      '';
      installPhase = ''
        mkdir -p $out/
        cp hosts $out/
      '';
    };
in
{

  environment.systemPackages = [ hosts-blacklist ];

  networking.extraHosts = builtins.readFile ("${hosts-blacklist}/hosts");
}
