{ ... }:
{
  services.spliit = {
    enable = true;
    settings = {
      PORT = 37463;
      ADDRESS = "0.0.0.0";
      POSTGRES_PRISMA_URL = null;
      POSTGRES_URL_NON_POOLING = null;

    };
    database = {
      createLocally = true;
      # hostname = "localhost";
      name = "spliit";
      user = "spliit";
      # passwordFile = /run/secrets/spliit-postgres-password;
    };
    # secretFile = /run/secrets/spliit-secret-settings;
  };
}
