{ pkgs, ... }: {

  services.postgresql = {
    enable = true;
    # enableTCPIP = true;
    # authentication = pkgs.lib.mkOverride 10 ''
    #   #...
    #   #type database DBuser origin-address auth-method
    #   # ipv4
    #   host  all      all     127.0.0.1/32   trust
    #   # ipv6
    #   host all       all     ::1/128        trust
    # '';
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
