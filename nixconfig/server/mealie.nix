{ settings, ... }:
{
  # see tandoor as an alternative
  services.mealie = {
    enable = true;
    package = pkgs.mealie;
    listenAddress = "0.0.0.0";
    port = 3294;
    credentialsFile = config.age.secrets.mealie.path;
    settings = {
      ALLOW_SIGNUP = "false";
      BASE_URL = "https://mealie.${settings.public_hostname}";
      # DATABASE_URL = "sqlite:////data/mealie/mealie.db";
    };
  };
}
