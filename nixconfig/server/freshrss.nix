{
  config,
  pkgs,
  settings,
  ...
}:
let
  host = settings.public_hostname2;
  domain = "freshrss.${host}";
  patched-rss-bridge = pkgs.rss-bridge.overrideAttrs (oldAttrs: {
    patches = [
      ../../patches/rss-bridge-4820.patch
      ../../patches/rss-bridge-4821.patch
      ../../patches/kleinanzeigen-detect.patch
    ];
  });
in
{
  services.freshrss = {
    enable = true;
    # database.port = 3306;
    baseUrl = "https://${domain}";
    virtualHost = "${domain}";
    # authType = "http_auth";
    passwordFile = config.age.secrets.freshrss_password.path;
    defaultUser = "robert";
    api.enable = true;
    # extensions = [ pkgs.freshrss-extensions.youtube ];
    # authType = "http_auth";
    extensions = [
      (
        let
          freshrss-extensions-src = pkgs.fetchFromGitHub {
            owner = "DevonHess";
            repo = "FreshRSS-Extensions";
            rev = "299c1febc279be77fa217ff5c2965a620903b974";
            hash = "sha256-++kgbrGJohKeOeLjcy7YV3QdCf9GyZDtbntlFmmIC5k=";
          };
        in
        pkgs.freshrss-extensions.buildFreshRssExtension {
          FreshRssExtUniqueId = "RSS-Bridge";
          pname = "rss-bridge";
          version = "1.1";
          src = freshrss-extensions-src;
          sourceRoot = "${freshrss-extensions-src.name}/xExtension-RssBridge";
        }
      )
    ];
  };

  services.rss-bridge = {
    enable = true;
    package = patched-rss-bridge;
    virtualHost = "rss.${host}";
    config = {
      system.enabled_bridges = [ "*" ];
      error = {
        output = "http";
        report_limit = 5;
      };
      FileCache = {
        enable_purge = true;
      };
    };
  };

  services.nginx.virtualHosts = {
    "${domain}" = {
      enableACME = true;
      forceSSL = true;
      # locations."/" = {
      #   proxyPass = "http://localhost:3001";
      #   # proxyWebsockets = true;
      # };
    };
  };
}
