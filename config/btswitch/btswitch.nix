{ config, pkgs, ... }:
let btswitch = pkgs.writeScriptBin "btswitch" (builtins.readFile ./btswitch);
in {

  systemd.user.services.pipewire-pulse-bt-switch = {
    enable = true;
    description = "Pipewire Pulse Server Auto Switch to Bluetooth";
    serviceConfig = { ExecStart = "btswitch"; };
    wantedBy = [ "default.target" ];
  };

  #  systemd.services.pipewire-pulse-bt-switch.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="input",ATTRS{phys}=="04:21:44:62:CC:49",ATTR{name}=="Soundcore Liberty Air 2",ACTION=="add",TAG+="systemd",ENV{SYSTEMD_USER_WANTS}+="pipewire-pulse-bt-switch.service"
  '';

  environment.systemPackages = [ btswitch ];
}
