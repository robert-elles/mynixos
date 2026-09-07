{ pkgs, settings, config, ... }:
{

  virtualisation.oci-containers.containers = {
    vikunja = {
      image = "docker.io/vikunja/vikunja:2.6";
      # Only reachable via the local nginx HTTPS front below, not directly.
      # Redirect hub entry: /vikunja in acmeproxy.nix
      ports = [ "127.0.0.1:19008:3456" ];
      environment = {
        VIKUNJA_DATABASE_PATH = "/app/vikunja/files/vikunja.db";
        VIKUNJA_FRONTEND_SCHEME = "https";
        VIKUNJA_SERVICE_PUBLICURL = "https://${settings.hostname}:9008";
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
      volumes = [ "/fastdata/vikunja:/app/vikunja/files" ];
    };
  };

  # HTTPS front for vikunja, local network only: reuses the same
  # local-CA-signed host cert as mealie (see secrets/local-ca/ca.crt and
  # nixconfig/server/mealie.nix), since it already covers this hostname.
  services.nginx.virtualHosts."vikunja-tls" = {
    serverName = settings.hostname;
    serverAliases = [ "${settings.hostname}.local" ];
    onlySSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 9008;
        ssl = true;
      }
    ];
    sslCertificate = ../../secrets/local-ca/mealie-fullchain.crt;
    sslCertificateKey = config.age.secrets.mealie_tls_key.path;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19008";
      proxyWebsockets = true;
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
