{ pkgs, ... }: {

  services.postgresql = {
    enable = true;
    dataDir = "/data/psql_db_data";
    package = pkgs.postgresql_14;
    # Ensure the database, user, and permissions always exist
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      # ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      ensureDBOwnership = true;
    }];
  };
}
