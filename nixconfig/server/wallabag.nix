{ pkgs, settings, config, ... }: {

  # Ensure wallabag database and user exist in PostgreSQL
  services.postgresql = {
    ensureDatabases = [ "wallabag" ];
    ensureUsers = [{
      name = "wallabag";
      ensureDBOwnership = true;
    }];
  };

  virtualisation.oci-containers.containers = {
    wallabag = {
      image = "wallabag/wallabag:2.6.14";
      ports = [ "3727:80" ];
      environment = {
        #   SYMFONY__ENV__DATABASE_DRIVER = "pdo_pgsql";
        #   SYMFONY__ENV__DATABASE_HOST = "localhost";
        #   SYMFONY__ENV__DATABASE_PORT = "5432";
        #   SYMFONY__ENV__DATABASE_NAME = "wallabag";
        #   SYMFONY__ENV__DATABASE_USER = "wallabag";
        #   SYMFONY__ENV__DATABASE_PASSWORD = "";
        #   SYMFONY__ENV__DATABASE_CHARSET = "utf8";
        #   SYMFONY__ENV__DATABASE_TABLE_PREFIX = "wallabag_";
        #   SYMFONY__ENV__MAILER_DSN = "smtp://127.0.0.1";
        #   SYMFONY__ENV__FROM_EMAIL = "wallabag@example.com";
        SYMFONY__ENV__DOMAIN_NAME =
          "https://wallabag.${settings.public_hostname2}";
        #   SYMFONY__ENV__SERVER_NAME = "wallabag";
      };
      volumes = [
        "/var/lib/wallabag/images:/var/www/wallabag/web/assets/images"
        "/var/lib/wallabag/data:/var/www/wallabag/data"
      ];
      # extraOptions = [
      #   "--restart=unless-stopped"
      #   "--network=host"
      # ];
    };

  };
}
