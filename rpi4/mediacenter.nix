{ lib, pkgs, ... }: {

  # boot.plymouth.enable = true;
  # boot.plymouth.theme = "breeze";

  services.xserver.enable = true;
  services.xserver.displayManager.autoLogin.user = "robert";
  services.xserver.displayManager.autoLogin.enable = true;

  # xfce
  services.xserver.displayManager.defaultSession = "kodi";
  services.xserver.desktopManager.xfce.enable = false;

  # kde
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # kodi
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (p: with p; [ netflix youtube arteplussept ]);

  # programs.kdeconnect.enable = true;

  # environment.systemPackages = with pkgs; [
  # widevine-cdm
  # chromium
  # firefox
  # ];
}
