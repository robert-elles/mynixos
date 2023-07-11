{ pkgs, ... }:
let
  grampsapi = pkgs.callPackage ../rpi4/gramps-webapi { };
  grampsjs = pkgs.callPackage ../rpi4/gramps.js { };
in
{
  # imports = [ ../rpi4/gramps-webapi ];

  environment.systemPackages = [
    grampsapi
    grampsjs
  ];
}
