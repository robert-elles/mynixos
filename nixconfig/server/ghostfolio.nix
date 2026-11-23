{ pkgs, settings, config, ... }:
let
  network = "ghostfolio";

  # Static IPs on the ghostfolio network (DNS disabled, see below).
  postgresIp = "10.90.0.5";
  redisIp = "10.90.0.6";
in
{
  virtualisation.oci-containers.containers = {
    ghostfolio = {
      image = "docker.io/ghostfolio/ghostfolio:3.100.0";
      # Only reachable via the acmeproxy public vhost
      # (ghostfolio.r3mus.mywire.org), not directly.
      ports = [ "127.0.0.1:9022:3333" ];
      # All sensitive values (POSTGRES_PASSWORD, REDIS_PASSWORD,
      # ACCESS_TOKEN_SALT, JWT_SECRET_KEY, DATABASE_URL) come from the
      # agenix env file. DATABASE_URL must point at the static postgres IP
      # and contain the real password (no shell expansion happens inside a
      # container env), so the env file carries the fully-resolved value:
      #   DATABASE_URL=postgresql://ghostfolio:<pw>@10.90.0.5:5432/ghostfolio?connect_timeout=300
      environment = {
        REDIS_HOST = redisIp;
        REDIS_PORT = "6379";
        PORT = "3333";
      };
      environmentFiles = [ config.age.secrets.ghostfolio_env.path ];
      dependsOn = [ "ghostfolio-postgres" "ghostfolio-redis" ];
      networks = [ network ];
      volumes = [ "/fastdata/ghostfolio:/var/lib/ghostfolio" ];
    };

    ghostfolio-postgres = {
      image = "docker.io/library/postgres:16-alpine";
      environmentFiles = [ config.age.secrets.ghostfolio_env.path ];
      networks = [ network ];
      extraOptions = [ "--ip=${postgresIp}" ];
      volumes = [ "/fastdata/ghostfolio/pgdata:/var/lib/postgresql/data" ];
    };

    ghostfolio-redis = {
      image = "docker.io/library/redis:8-alpine";
      environmentFiles = [ config.age.secrets.ghostfolio_env.path ];
      networks = [ network ];
      extraOptions = [ "--ip=${redisIp}" ];
      # $REDIS_PASSWORD is expanded by /bin/sh (present in the alpine image)
      # so the password never appears in the container inspect output.
      cmd = [ "/bin/sh" "-c" ''exec redis-server --requirepass "$REDIS_PASSWORD"'' ];
    };
  };

  # Ghostfolio, postgres and redis need to reach each other on a user-defined
  # network (the default bridge has no inter-container routing). DNS is
  # disabled to avoid aardvark-dns binding UDP/53 and colliding with coredns
  # (dns.nix). Static IPs are used instead - see gramps-web.nix for the same
  # pattern.
  systemd.services."podman-network-${network}" = {
    description = "Create the ${network} podman network";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ config.virtualisation.podman.package ];
    script = ''
      podman network exists ${network} || podman network create --subnet 10.90.0.0/24 --disable-dns ${network}
    '';
  };

  systemd.services."podman-ghostfolio".after = [ "podman-network-${network}.service" ];
  systemd.services."podman-ghostfolio".requires = [ "podman-network-${network}.service" ];
  systemd.services."podman-ghostfolio-postgres".after = [ "podman-network-${network}.service" ];
  systemd.services."podman-ghostfolio-postgres".requires = [ "podman-network-${network}.service" ];
  systemd.services."podman-ghostfolio-redis".after = [ "podman-network-${network}.service" ];
  systemd.services."podman-ghostfolio-redis".requires = [ "podman-network-${network}.service" ];

  systemd.timers."ghostfolio_backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "90m";
      Unit = "ghostfolio_backup.service";
    };
  };

  systemd.services."ghostfolio_backup" = {
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync -rvha --delete /fastdata/ghostfolio/ /data2/ghostfolio/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
