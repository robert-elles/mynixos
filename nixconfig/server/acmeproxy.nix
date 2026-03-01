{ settings, ... }:
let
  myemail = settings.email;
  public_hostname = settings.public_hostname;
  public_hostname2 = settings.public_hostname2;
  hostname = settings.hostname;
  # mercury_hostname = settings.mercury_hostname;
in
{

  security.acme = {
    acceptTerms = true;
    defaults.email = myemail;
  };

  # ssl reverse proxy
  services.nginx = {
    enable = true;
    clientMaxBodySize = "0"; # 0 means no limit
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
      "${public_hostname2}" = {
        forceSSL = true;
        ## LetsEncrypt
        enableACME = true;
      };
      # "calibre.${public_hostname}" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/".proxyPass = "http://localhost:8083";
      # };
      "audiobooks.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8000";
          proxyWebsockets = true;
        };
      };
      # "${mercury_hostname}.${public_hostname}" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/" = {
      #     proxyPass = "http://localhost:9000";
      #     proxyWebsockets = true;
      #   };
      # };
      "paperless.${public_hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:28981";
          proxyWebsockets = true;
        };
      };
      "jellyfin.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8096";
          proxyWebsockets = true;
        };
      };
      "pdf.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:2600";
          proxyWebsockets = true;
        };
      };
      "vikunja.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:3456";
          # proxyWebsockets = true;
        };
      };
      # "renaissance.${public_hostname}" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/" = {
      #     proxyPass = "http://127.0.0.1:2500";
      #   };
      # };
      # "auth.${public_hostname2}" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/" = {
      #     proxyPass = "http://127.0.0.1:4800";
      #   };
      # };
      # "playlist.${public_hostname2}" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/" = {
      #     root = "/web/playlist";
      #   };
      # };
      "chat.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9092";
          proxyWebsockets = true;
        };
      };
      "immich.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283";
          proxyWebsockets = true;
        };
      };
      "navidrome.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:4533";
          proxyWebsockets = true;
        };
      };
      "wallabag.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3727";
        };
      };
      "vogesen.${public_hostname2}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:7222";
        };
      };
      "${hostname}" = {
        enableACME = false;
        forceSSL = false;
        locations = {
          "/jellyfin" = {
            return = "301 http://${hostname}:8096";
          };
          "/transmission" = {
            return = "301 http://${hostname}:9091";
          };
          "/torrent" = {
            return = "301 http://${hostname}:9091";
          };
          "/gramps" = {
            return = "301 http://${hostname}:5049";
          };
          "/paperless" = {
            return = "301 http://${hostname}:28981";
          };
          "/books" = {
            return = "301 http://${hostname}:8083";
          };
          "/audiobooks" = {
            return = "301 http://${hostname}:8000";
          };
          "/jupyter" = {
            return = "301 http://${hostname}:8888";
          };
        };
      };
    };
  };
}
