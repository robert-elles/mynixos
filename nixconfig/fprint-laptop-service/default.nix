# https://unix.stackexchange.com/questions/678609/how-to-disable-fingerprint-authentication-when-laptop-lid-is-closed
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.fprint-laptop-lid;
in {

  options = {
    services.fprint-laptop-lid = {
      enable = mkEnableOption
        (lib.mdDoc "Disable finger print reader when laptop lid is closed.");
    };
  };

  config = mkIf cfg.enable {

    nixpkgs.overlays = [
      (self: super: {
        laptop-lid = pkgs.writeScriptBin "laptoplid" ''
          #!${pkgs.stdenv.shell}

          lock=$HOME/fprint-disabled

          if grep -Fq closed /proc/acpi/button/lid/LID/state &&
             grep -Fxq connected /sys/class/drm/card0-[HD]*/status
          then
            touch "$lock"
            systemctl stop fprintd
            systemctl --runtime mask fprintd
          elif [ -f "$lock" ]
          then
            systemctl unmask fprintd
            systemctl start fprintd
            rm "$lock"
          fi
        '';
      })
    ];

    services.acpid.enable = true;

    environment.etc = {
      "acpi/events/laptop-lid".text = ''
        event=button/lid.*
        action=${pkgs.laptop-lid}/bin/laptoplid
      '';
    };

    systemd.services.fprint-laptop-lid = {
      description = "Disable fprint when laptop lid closes";
      serviceConfig = { ExecStart = "${pkgs.laptop-lid}/bin/laptoplid"; };
      wantedBy = [ "multi-user.target" "suspend.target" ];
      after = [ "suspend.target" ];
    };

  };
}
