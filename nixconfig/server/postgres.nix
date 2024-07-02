{ pkgs, ... }: {

  services.postgresql = {
    enable = true;
    dataDir = "/fastdata/psql_db_data";
    package = pkgs.postgresql_14;
    # Ensure the database, user, and permissions always exist
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      # ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      ensureDBOwnership = true;
    }];
    settings = {
      shared_buffers = 262144;
      effective_cache_size = 524288;
      # work_mem = "32MB";
      maintenance_work_mem = 32768;
      # checkpoint_segments = 64;
      # checkpoint_timeout = "15min";
    };
  };
}
