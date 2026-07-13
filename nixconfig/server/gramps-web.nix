{ pkgs, settings, config, ... }:
let
  # static IP for gramps-web-redis on the gramps-web network - see the
  # --disable-dns note below for why this can't be a container-name lookup
  redisIp = "10.89.0.5";
  grampsEnv = {
    GRAMPSWEB_TREE = "Gramps Web";
    # needed to build correct links (e.g. password reset) in notification e-mails
    GRAMPSWEB_BASE_URL = "https://${settings.hostname}:9016";
    GRAMPSWEB_CELERY_CONFIG__broker_url = "redis://${redisIp}:6379/0";
    GRAMPSWEB_CELERY_CONFIG__result_backend = "redis://${redisIp}:6379/0";
    GRAMPSWEB_RATELIMIT_STORAGE_URI = "redis://${redisIp}:6379/1";
  };
  grampsVolumes = [
    "/fastdata/grampsweb/users:/app/users" # user database
    "/fastdata/grampsweb/index:/app/indexdir" # search index
    "/fastdata/grampsweb/thumb_cache:/app/thumbnail_cache"
    "/fastdata/grampsweb/cache:/app/cache" # export/report caches
    "/fastdata/grampsweb/secret:/app/secret" # flask secret
    "/fastdata/grampsweb/db:/root/.gramps/grampsdb" # gramps database
    "/fastdata/grampsweb/media:/app/media"
    "/fastdata/grampsweb/tmp:/tmp"
  ];
  network = "gramps-web";
in
{

  virtualisation.oci-containers.containers = {
    gramps-web = {
      image = "ghcr.io/gramps-project/grampsweb:26.6.2";
      # only reachable via the local nginx HTTPS front below, not directly
      ports = [ "127.0.0.1:19016:5000" ];
      environment = grampsEnv;
      dependsOn = [ "gramps-web-redis" ];
      networks = [ network ];
      volumes = grampsVolumes;
    };

    gramps-web-celery = {
      image = "ghcr.io/gramps-project/grampsweb:26.6.2";
      environment = grampsEnv;
      cmd = [ "celery" "-A" "gramps_webapi.celery" "worker" "--loglevel=INFO" "--concurrency=2" ];
      dependsOn = [ "gramps-web" "gramps-web-redis" ];
      networks = [ network ];
      volumes = grampsVolumes;
    };

    gramps-web-redis = {
      image = "docker.io/valkey/valkey:8-alpine";
      networks = [ network ];
      extraOptions = [ "--ip=${redisIp}" ];
    };
  };

  # gramps-web and its celery worker need to reach redis on a user-defined
  # network (the default bridge network has no inter-container routing) -
  # create it before any of the containers start. This system's
  # oci-containers backend is podman (the nixpkgs default for
  # stateVersion >= 22.05), so the network must be created via podman, not
  # docker - a podman container cannot join a network created with the
  # docker CLI.
  #
  # DNS (aardvark-dns) is disabled on this network: podman would otherwise
  # bind the network gateway IP on UDP/53, which collides with coredns
  # (nixconfig/server/dns.nix) listening on 0.0.0.0:53 and makes the
  # container fail to start with "address already in use". Since this is
  # the only custom podman network in this repo, name resolution is
  # unneeded anyway - gramps-web-redis gets a static IP (redisIp above)
  # instead.
  systemd.services."podman-network-${network}" = {
    description = "Create the ${network} podman network";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ config.virtualisation.podman.package ];
    script = ''
      podman network exists ${network} || podman network create --subnet 10.89.0.0/24 --disable-dns ${network}
    '';
  };

  systemd.services."podman-gramps-web".after = [ "podman-network-${network}.service" ];
  systemd.services."podman-gramps-web".requires = [ "podman-network-${network}.service" ];
  systemd.services."podman-gramps-web-celery".after = [ "podman-network-${network}.service" ];
  systemd.services."podman-gramps-web-celery".requires = [ "podman-network-${network}.service" ];
  systemd.services."podman-gramps-web-redis".after = [ "podman-network-${network}.service" ];
  systemd.services."podman-gramps-web-redis".requires = [ "podman-network-${network}.service" ];

  # HTTPS front for gramps-web, local network only: reuses the same
  # local-CA-signed host cert as mealie (see secrets/local-ca/ca.crt and
  # nixconfig/server/mealie.nix), since it already covers this hostname.
  services.nginx.virtualHosts."gramps-web-tls" = {
    serverName = settings.hostname;
    serverAliases = [ "${settings.hostname}.local" ];
    onlySSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 9016;
        ssl = true;
      }
    ];
    sslCertificate = ../../secrets/local-ca/mealie-fullchain.crt;
    sslCertificateKey = config.age.secrets.mealie_tls_key.path;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19016";
      proxyWebsockets = true;
    };
  };

  systemd.timers."gramps_web_backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "90m";
      Unit = "gramps_web_backup.service";
    };
  };

  systemd.services."gramps_web_backup" = {
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync -rvha --delete /fastdata/grampsweb/ /data2/grampsweb/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
