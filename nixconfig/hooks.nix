{ pkgs, ... }: {

  systemd.services.shutdownHook = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "robert";
      RemainAfterExit = true;
      ExecStop = ''
        systemctl --user stop easyeffects
      '';
    };
  };

  systemd.services.startupHook = {
    wantedBy = [ "multi-user.target" ];
    after = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "robert";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.bluez}/bin/bluetoothctl power on
      '';
    };
  };
}
