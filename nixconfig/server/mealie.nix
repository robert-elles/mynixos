{ settings, pkgs, pkgs-pin, config, ... }: {

  # see tandoor as an alternative
  services.mealie = {
    enable = true;
    package = pkgs-pin.mealie;
    # only reachable via the local nginx HTTPS front below, not directly
    listenAddress = "127.0.0.1";
    port = 19004;
    # credentialsFile = config.age.secrets.mealie.path;
    settings = {
      ALLOW_SIGNUP = "false";
      BASE_URL = "https://${settings.hostname}:9004";
      # DATABASE_URL = "sqlite:////data/mealie/mealie.db";
    };
  };

  # HTTPS front for mealie, local network only: cert is signed by a
  # self-managed local CA (see secrets/local-ca/ca.crt) rather than a
  # publicly trusted one, so it never needs internet-facing ACME challenges.
  services.nginx.virtualHosts."mealie-tls" = {
    serverName = settings.hostname;
    serverAliases = [ "${settings.hostname}.local" ];
    onlySSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 9004;
        ssl = true;
      }
    ];
    sslCertificate = ../../secrets/local-ca/mealie-fullchain.crt;
    sslCertificateKey = config.age.secrets.mealie_tls_key.path;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19004";
      proxyWebsockets = true;
    };
  };
}
