{ settings, pkgs, pkgs-pin, ... }: {

  services.nginx.virtualHosts = {
    "mealie.${settings.public_hostname2}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3294";
        # proxyWebsockets = true;
      };
    };
  };
  # see tandoor as an alternative
  services.mealie = {
    enable = true;
    package = pkgs-pin.mealie;
    listenAddress = "0.0.0.0";
    port = 3294;
    # credentialsFile = config.age.secrets.mealie.path;
    settings = {
      ALLOW_SIGNUP = "false";
      BASE_URL = "https://mealie.${settings.public_hostname2}";
      # DATABASE_URL = "sqlite:////data/mealie/mealie.db";
    };
  };
}
