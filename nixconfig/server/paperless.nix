{ config, pkgs, ... }:
{

  age.secrets = {
    paperless_password = {
      file = ../../secrets/agenix/paperless_password.age;
      mode = "777";
      owner = "paperless";
      group = "paperless";
    };
  };

  services.paperless = {
    enable = true;
    dataDir = "/fastdata/paperless/data";
    mediaDir = "/data/paperless/media";
    consumptionDir = "/data/paperless/consumption";
    user = "paperless";
    address = "0.0.0.0";
    passwordFile = "${config.age.secrets.paperless_password.path}";
  };

  systemd.timers."paperless_backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "90m";
      # OnCalendar = "*-*-* 4:00:00 Europe/Berlin";
      Unit = "paperless_backup.service";
    };
  };

  systemd.services."paperless_backup" = {
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync -rvha --delete /fastdata/paperless/data/ /data2/paperless/data/
      ${pkgs.rsync}/bin/rsync -rvha --delete /data/paperless/media/ /data2/paperless/media/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
