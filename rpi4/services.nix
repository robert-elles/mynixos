{ config, pkgs, lib, ... }: {
  services.jellyfin.enable = true;
  services.jellyfin.user = "robert";
}
