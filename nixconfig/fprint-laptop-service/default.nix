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

    services.acpid.enable = true;

    environment.etc = {
      "acpi/events/laptop-lid".text = ''
        event=button/lid.*
        action=/etc/acpi/laptop-lid.sh
      '';
    };

    systemd.services.fprint-laptop-lid = {
      description = "Disable fprint when laptop lid closes";
      serviceConfig = { ExecStart = "${./laptop-lid.sh}"; };
      wantedBy = [ "multi-user.target" "suspend.target" ];
      after = [ "suspend.target" ];
    };

  };
}
