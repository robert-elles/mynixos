{ pkgs, settings, ... }: {


  virtualisation.oci-containers.containers = {
    vikunja = {
      # image = "docker.io/vikunja/vikunja:latest";
      image = "vikunja/vikunja:latest";
      ports = [ "3456:3456" ];
      environment = {
        VIKUNJA_DATABASE_PATH = "/app/vikunja/files/vikunja.db";
        # VIKUNJA_FRONTEND_SCHEME = "https";
        VIKUNJA_SERVICE_PUBLICURL = "vikunja.${settings.public_hostname2}";
        # VIKUNJA_SERVICE_PUBLICURL: http://<the public url where Vikunja is reachable>
        # VIKUNJA_DATABASE_HOST: db
        # VIKUNJA_DATABASE_PASSWORD: changeme
        # VIKUNJA_DATABASE_TYPE: mysql
        # VIKUNJA_DATABASE_USER: vikunja  
        # VIKUNJA_DATABASE_DATABASE: vikunja
        # VIKUNJA_SERVICE_JWTSECRET: <a super secure random secret>
      };
      # memoryLimit = "1G";
      # cpuQuota = 100000;
      # cpuPeriod = 100000;
      # restartPolicy = "always";
      volumes = [
        "/fastdata/vikunja:/app/vikunja/files"
      ];
    };
  };

  # services.vikunja = {
  #   enable = true;
  #   frontendScheme = "https";
  #   frontendHostname = "vikunja.${settings.public_hostname2}";
  #   database.path = "/fastdata/vikunja/vikunja.db";
  #   # config.yaml
  #   # environmentFiles = [ "" ];
  # };

  systemd.timers."vikunja_backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "90m";
      # OnCalendar = "*-*-* 4:00:00 Europe/Berlin";
      Unit = "vikunja_backup.service";
    };
  };

  systemd.services."vikunja_backup" = {
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync -rvha --delete /fastdata/vikunja/ /data2/vikunja/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
