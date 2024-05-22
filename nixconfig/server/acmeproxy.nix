{ ... }:
let
  parameters =
    builtins.fromJSON (builtins.readFile /home/robert/code/mynixos/secrets/gitcrypt/nextcloud_params.json);
  myemail = parameters.email;
  public_hostname = parameters.public_hostname;
  mercury_hostname = parameters.mercury_hostname;
in
{

  security.acme = {
    acceptTerms = true;
    defaults.email = myemail;
  };

  # ssl reverse proxy
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
    virtualHosts = {
      "${public_hostname}" = {
        forceSSL = true;
        ## LetsEncrypt
        enableACME = true;
      };
      "calibre.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:8083";
      };
      "audiobooks.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8000";
          proxyWebsockets = true;
        };
      };
      "${mercury_hostname}.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:9000";
          proxyWebsockets = true;
        };
      };
      # "paperless.${public_hostname}" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/" = {
      #     proxyPass = "http://localhost:28981";
      #     proxyWebsockets = true;
      #   };
      # };
      "renaissance.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2500";
        };
      };
      "falcon" = {
        enableACME = false;
        forceSSL = false;
        locations = {
          "/jellyfin" = {
            return = "301 http://falcon:8096";
          };
          "/transmission" = {
            return = "301 http://falcon:9091";
          };
          "/torrent" = {
            return = "301 http://falcon:9091";
          };
          "/gramps" = {
            return = "301 http://falcon:5049";
          };
          "/paperless" = {
            return = "301 http://falcon:28981";
          };
          "/books" = {
            return = "301 http://falcon:8083";
          };
          "/audiobooks" = {
            return = "301 http://falcon:8000";
          };
          "/jupyter" = {
            return = "301 http://falcon:8888";
          };
        };
      };
    };
  };
}
