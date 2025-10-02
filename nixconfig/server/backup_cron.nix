{ ... }:
{
  systemd.timers."backup_cron" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30m";
      OnUnitActiveSec = "90m";
      OnCalendar = "*-*-* 4:00:00 Europe/Berlin";
      Unit = "backup_cron.service";
    };
  };

  # Todo:
  # - Navidrome database
  systemd.services."backup_cron" = {
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync -rvhta --delete /var/lib/immich/ /data/immich/
      ${pkgs.rsync}/bin/rsync -rvhta --delete /var/lib/wallabag/ /data/wallabag/
      ${pkgs.rsync}/bin/rsync -rvhta --delete /data/music/ /data2/music/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
