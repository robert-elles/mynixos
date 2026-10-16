{ settings, config, lib, ... }:
let
  hostname = settings.hostname;
  internalDomain = settings.internal_domain;
  # Publicly registered (dynu) domain, used only to obtain a real
  # certificate; the names still resolve to the LAN address (dns.nix).
  publicDomain = settings.public_hostname2;

  aliases = import ./local-aliases.nix;

  # The reverse-proxy half of a service vhost, shared by both name schemes
  # below. `scheme = "https"` for the few backends that speak TLS
  # themselves (sunshine); their certs are self-signed, so verification is
  # off.
  mkProxyLocation = a: {
    "/" = {
      proxyPass = "${a.scheme or "http"}://127.0.0.1:${toString a.port}${a.path or ""}";
      proxyWebsockets = true;
      extraConfig = lib.optionalString (a.scheme or "http" == "https") ''
        proxy_ssl_verify off;
      '';
    };
  };

  # Private names, served with the local CA (see secrets/local-ca/ca.crt);
  # its SAN list covers every "<name>.local" and "<name>.${internalDomain}"
  # below, so devices that trust that CA get no hostname-mismatch warning.
  #
  #   <name>.local    - mDNS, published by the sidecar in mdns.nix
  #   <name>.${internalDomain} - internal DNS zone served by coredns
  #                     (dns.nix), for clients using leopard as resolver
  mkAliasVhost = a: {
    serverAliases = [ "${a.name}.${internalDomain}" ];
    onlySSL = true;
    sslCertificate = ../../secrets/local-ca/mealie-fullchain.crt;
    sslCertificateKey = config.age.secrets.mealie_tls_key.path;
    locations = mkProxyLocation a;
  };

  # Public name, served with the Let's Encrypt wildcard. Same backend, but
  # the cert chains to a public root, so no CA has to be installed on the
  # client - which is the only thing that works reliably on android apps
  # and firefox. The name resolves to the LAN address via dns.nix.
  mkPublicVhost = a: {
    onlySSL = true;
    useACMEHost = publicDomain;
    locations = mkProxyLocation a;
  };
in
{

  security.acme = {
    acceptTerms = true;
    defaults.email = settings.email;

    # One wildcard for every service, via the dns-01 challenge: lego writes
    # a _acme-challenge TXT record through dynu's API and Let's Encrypt
    # reads it from dynu's nameservers. Nothing here is ever contacted from
    # the internet, so no port forwarding is needed and the services stay
    # LAN-only - see the split-horizon zone in dns.nix, which answers these
    # names with the LAN address instead of the public one.
    #
    # A wildcard also keeps the individual service names out of the public
    # Certificate Transparency logs; only "*.${publicDomain}" is published.
    certs.${publicDomain} = {
      domain = publicDomain;
      extraDomainNames = [ "*.${publicDomain}" ];
      # nginx serves the cert, so it has to be able to read the key.
      group = "nginx";
      dnsProvider = "dynu";
      # dynu's lego provider only reads DYNU_API_KEY (it has no "_FILE"
      # variant), so the secret is passed as an EnvironmentFile rather than
      # through credentialFiles.
      environmentFile = config.age.secrets.dynu_api_key.path;
      # Resolve the challenge against dynu directly: coredns on this host is
      # authoritative for this zone (split horizon) and would never see the
      # TXT record, so the self-check has to bypass it.
      dnsResolver = "ns1.dynu.com:53";
    };
  };

  # local reverse proxy / redirect hub
  services.nginx = {
    enable = true;
    clientMaxBodySize = "0"; # 0 means no limit
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "${hostname}" = {
        enableACME = false;
        forceSSL = false;
        # One redirect per alias, derived from the same list as the vhosts
        # below, so the hub cannot drift out of sync with the real backends
        # the way a hand-maintained port list does. feishin is not in that
        # list (it is served from the store, not proxied - see music.nix),
        # so it gets its entry here.
        locations =
          lib.listToAttrs (
            map (
              a: lib.nameValuePair "/${a.name}" { return = "301 https://${a.name}.${internalDomain}"; }
            ) aliases
          )
          // {
            "/feishin" = {
              return = "301 https://feishin.${internalDomain}";
            };
          };
      };
    }
    // lib.listToAttrs (map (a: lib.nameValuePair "${a.name}.local" (mkAliasVhost a)) aliases)
    // lib.listToAttrs (
      map (a: lib.nameValuePair "${a.name}.${publicDomain}" (mkPublicVhost a)) aliases
    );
  };
}
