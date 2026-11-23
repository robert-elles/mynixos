{ pkgs, settings, config, ... }:
# Hardened OpenClaw deployment.
#
# Isolation goals: even if the AI agent is fully compromised (prompt
# injection, malicious skill, ...), it can only affect its own container:
#   - no host home directory / no host filesystem mounts besides its own
#     dedicated data dir (/var/lib/openclaw)
#   - no access to the host docker socket (cannot spawn sibling containers)
#   - no host network; gateway only reachable on localhost
#   - all capabilities dropped, no-new-privileges, non-root user
#   - resource limits so it cannot starve the host
{
  virtualisation.oci-containers.containers.openclaw = {
    image = "ghcr.io/openclaw/openclaw:latest";
    autoStart = true;

    # Gateway only reachable via the local nginx HTTPS front below,
    # not directly. Redirect hub entry: /openclaw in acmeproxy.nix
    ports = [ "127.0.0.1:19017:18789" ];

    # The ONLY host path visible inside the container. The agent's
    # workspace, config and sessions all live here.
    volumes = [ "/var/lib/openclaw:/home/node/.openclaw" ];

    environment = {
      # Container only sees its own workspace
      OPENCLAW_WORKSPACE = "/home/node/.openclaw/workspace";
    };

    extraOptions = [
      # non-root user baked into the image
      "--user=1000:1000"

      # privilege escalation barriers
      "--cap-drop=ALL"
      "--security-opt=no-new-privileges:true"

      # read-only root fs; writable scratch space only in tmpfs
      "--read-only"
      "--tmpfs=/tmp:rw,noexec,nosuid,size=512m"

      # resource limits
      "--memory=8g"
      "--cpus=4"
      "--pids-limit=512"

    ];
  };

  # Keep gateway.controlUi.allowedOrigins in the runtime config
  # (openclaw.json, a mutable onboarding-managed file) declaratively in sync
  # with the reverse-proxy origins this deployment is reachable under, without
  # freezing the rest of the file (token, wizard state, pairing records).
  # Runs before the container starts so the gateway always boots with the
  # current allowlist; idempotent on every rebuild.
  systemd.services.openclaw-allowed-origins = {
    description = "Sync OpenClaw gateway.controlUi.allowedOrigins from Nix config";
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-openclaw.service" ];
    path = [ pkgs.jq ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      cfg=/var/lib/openclaw/openclaw.json
      touch "$cfg"
      jq '.gateway.controlUi.allowedOrigins = ($origins | fromjson)' \
        --arg origins "$ALLOWED_ORIGINS_JSON" \
        "$cfg" > "$tmp" && mv "$tmp" "$cfg"
      # (onboarding/wizard updates, config hot-reload), so restore the
      # ownership and tight mode jq's temp-file mv would have reset.
      chown 1000:1000 "$cfg"
      chmod 600 "$cfg"
    '';
    environment.ALLOWED_ORIGINS_JSON = builtins.toJSON [
      "https://${settings.hostname}:9017"
      "https://openclaw.${settings.public_hostname2}"
    ];
  };

  # HTTPS front for openclaw, local network only: reuses the same
  # local-CA-signed host cert as mealie (see secrets/local-ca/ca.crt and
  # nixconfig/server/mealie.nix), since it already covers this hostname.
  services.nginx.virtualHosts."openclaw-tls" = {
    serverName = settings.hostname;
    serverAliases = [ "${settings.hostname}.local" ];
    onlySSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 9017;
        ssl = true;
      }
    ];
    sslCertificate = ../../secrets/local-ca/mealie-fullchain.crt;
    sslCertificateKey = config.age.secrets.mealie_tls_key.path;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19017";
      proxyWebsockets = true;
    };
  };

  # Optional: outbound internet access is needed for LLM API calls.
  # The container sits on the default docker bridge, which is NATed -
  # it can reach the internet but is NOT reachable from the LAN and
  # cannot reach other host services except via the host gateway IP.
  # If you also want to block it from reaching your LAN services,
  # uncomment:
  networking.firewall.extraCommands = ''
    iptables -I DOCKER-USER -i br-+ -d 192.168.0.0/16 -j DROP
    iptables -I DOCKER-USER -i br-+ -d 10.0.0.0/8 -j DROP
  '';
}
