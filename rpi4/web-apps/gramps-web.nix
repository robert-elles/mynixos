{ config, lib }:
let
  cfg = config.services.calibre-web;
  inherit (lib) mkIf mkEnableOption;
in
{
  options = {
    services.calibre-web = {
      enable = mkEnableOption (lib.mdDoc "Calibre-Web");
    };
  };

  config = mkIf cfg.enable { };
}
