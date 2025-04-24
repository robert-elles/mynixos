{}: {
  services.shiori = {
    enable = true;
    port = 8080;
    databaseUrl = "postgres:///shiori?host=/run/postgresql";
    # environmentFile
  };
}
