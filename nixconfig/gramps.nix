{ pkgs, ... }:
let
  grampsapi = pkgs.callPackage ../rpi4/gramps-webapi { };
in
{
  # imports = [ ../rpi4/gramps-webapi ];

  environment.systemPackages = [ grampsapi ];
}
