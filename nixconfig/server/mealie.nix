{ settings, pkgs, pkgs-pin, ... }: {

  # see tandoor as an alternative
  services.mealie = {
    enable = true;
    package = pkgs-pin.mealie;
    listenAddress = "0.0.0.0";
    port = 9004;
    # credentialsFile = config.age.secrets.mealie.path;
    settings = {
      ALLOW_SIGNUP = "false";
      BASE_URL = "http://${settings.hostname}:9004";
      # DATABASE_URL = "sqlite:////data/mealie/mealie.db";
    };
  };
}
