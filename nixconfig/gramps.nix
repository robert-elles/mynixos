{ ... }:
# let
# grampsapi = pkgs.callPackage ../rpi4/gramps-webapi { };
# grampsjs = pkgs.callPackage ../rpi4/gramps.js { };
# in
{
  imports = [ ../rpi4/web-apps/gramps-web.nix ];

  services.gramps-web.enable = true;
  services.gramps-web.user = "robert";
  services.gramps-web.config-file = "/home/robert/.gramps/config.cfg";
  services.gramps-web.search-idx = "/home/robert/.gramps/indexdir";

  # environment.systemPackages = [
  #   grampsapi
  #   grampsjs
  # ];
}
